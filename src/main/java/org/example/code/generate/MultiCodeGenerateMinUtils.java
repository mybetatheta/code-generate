package org.example.code.generate;

import freemarker.template.Template;
import org.dromara.hutool.core.date.DateTime;
import org.dromara.hutool.core.date.DateUtil;
import org.dromara.hutool.core.regex.ReUtil;
import org.dromara.hutool.core.text.StrUtil;
import org.example.code.generate.domain.GenTableColumn;
import org.example.code.generate.utils.FreeMarkerTemplateMinUtils;
import org.example.code.generate.utils.StringUtils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

/**
 * 代码生成器 - 优化版
 */
public class MultiCodeGenerateMinUtils {

    private final String AUTHOR = "min";
    private final String CURRENT_DATE = DateUtil.formatDateTime(DateTime.now());
    private final String URL = "jdbc:mysql://127.0.0.1:3306/matlink_db?useUnicode=true&characterEncoding=utf-8&allowMultiQueries=true";
    private final String USER = "root";
    private final String PASSWORD = "root";
    private final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private final String diskPath = "D://test/";
    private final String packageName = "com.clt.matlink.modules.test";

    /** 是否生成目录结构 */
    private boolean genFolder = true;
    /** 是否生成baseModel */
    private boolean genBaseModel = false;

    /** 要生成代码的表名，多个用逗号分隔 */
    private String tableNames = "clt_material_task,clt_material_task_detail";

    private String packageFolder = coverPackage2Folder(packageName);

    public Connection getConnection() throws Exception {
        Class.forName(DRIVER);
        Properties props = new Properties();
        props.setProperty("user", USER);
        props.setProperty("password", PASSWORD);
        props.setProperty("remarks", "true");
        props.setProperty("useInformationSchema", "true");
        // 添加关键参数，确保 getSchema() 和 getCatalog() 正常工作
        props.setProperty("nullCatalogMeansCurrent", "true");
        props.setProperty("serverTimezone", "Asia/Shanghai");
        props.setProperty("useSSL", "false");

        return DriverManager.getConnection(URL, props);
    }

    public static void main(String[] args) throws Exception {
        MultiCodeGenerateMinUtils codeGenerateUtils = new MultiCodeGenerateMinUtils();
        codeGenerateUtils.generate();
    }

    public void generate() throws Exception {
        try (Connection connection = getConnection()) {
            DatabaseMetaData databaseMetaData = connection.getMetaData();

            // 获取当前数据库名（schema）
            String currentSchema = getCurrentSchema(connection);
            System.out.println("当前数据库（schema）: " + currentSchema);

            // 处理要生成代码的表
            Set<String> targetTables = parseTableNames(tableNames);
            System.out.println("要生成代码的表: " + targetTables);

            // 获取所有表
            try (ResultSet resultSet = databaseMetaData.getTables(null, "%", "%", new String[]{"TABLE"})) {
                while (resultSet.next()) {
                    String tableName = resultSet.getString("TABLE_NAME");
                    String tableAnnotation = resultSet.getString("REMARKS");

                    if (targetTables.contains(tableName)) {
                        System.out.println("正在生成表: " + tableName + " - " + tableAnnotation);

                        String className = replaceUnderLineAndUpperCase(tableName);
                        generateTableCode(connection, databaseMetaData, tableName, className, tableAnnotation, currentSchema);
                    }
                }
            }

            System.out.println("代码生成完成！输出目录: " + diskPath);
        } catch (Exception e) {
            throw new RuntimeException("代码生成失败", e);
        }
    }

    /**
     * 生成单个表的代码
     */
    private void generateTableCode(Connection connection, DatabaseMetaData databaseMetaData,
                                   String tableName, String className, String tableAnnotation,
                                   String schema) throws Exception {
        // 获取表的所有列
        List<GenTableColumn> columnClassList = getColumns(connection, schema, tableName);

        if (columnClassList.isEmpty()) {
            System.out.println("警告: 表 " + tableName + " 没有找到任何列，跳过生成");
            return;
        }

        System.out.println("表 " + tableName + " 找到 " + columnClassList.size() + " 列");

        // 设置数据模型
        Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("tableName", tableName);
        dataMap.put("upperCaseTableName", StrUtil.toUpperCase(tableName));
        dataMap.put("ClassName", className);
        // 添加这两个关键变量
        String classNameLower = StrUtil.lowerFirst(className);  // 首字母小写："hvVisitor"
        dataMap.put("className", classNameLower);         // 用于 ${className}
        dataMap.put("classNameLower", classNameLower);    // 用于 ${classNameLower}

        dataMap.put("author", AUTHOR);
        dataMap.put("date", CURRENT_DATE);
        dataMap.put("packageName", packageName);
        dataMap.put("tableAnnotation", tableAnnotation);
        dataMap.put("tableColumns", columnClassList);
        dataMap.put("genBaseModel", genBaseModel);

        // 生成各种文件
        generateEntityFile(dataMap);
        generateVoFile(dataMap);
        generateFormFile(dataMap);  // 新增：生成Query类
        generateMapperFile(dataMap);
        generateServiceInterfaceFile(dataMap);
        generateServiceImplFile(dataMap);
        generateControllerFile(dataMap);

    }

    /**
     * 获取表的列信息（优化版）
     */
    private List<GenTableColumn> getColumns(Connection connection, String schema, String tableName) throws Exception {
        List<GenTableColumn> columnClassList = new ArrayList<>();

        // 方法1：使用 INFORMATION_SCHEMA（更可靠）
        List<GenTableColumn> columnsFromInfoSchema = getColumnsFromInformationSchema(connection, schema, tableName);
        if (!columnsFromInfoSchema.isEmpty()) {
            return columnsFromInfoSchema;
        }

        // 方法2：回退到 DatabaseMetaData
        try (ResultSet resultSet = connection.getMetaData().getColumns(null, schema, tableName, "%")) {
            while (resultSet.next()) {
                GenTableColumn column = buildColumnFromResultSet(resultSet);
                columnClassList.add(column);
            }
        }

        return columnClassList;
    }

    /**
     * 使用 INFORMATION_SCHEMA 获取列信息（推荐）
     */
    private List<GenTableColumn> getColumnsFromInformationSchema(Connection connection,
                                                                 String schema,
                                                                 String tableName) throws Exception {
        List<GenTableColumn> columns = new ArrayList<>();

        // 如果 schema 为空，尝试获取当前数据库
        if (StrUtil.isBlank(schema)) {
            schema = getCurrentSchema(connection);
        }

        if (StrUtil.isBlank(schema)) {
            System.out.println("无法确定数据库名，使用 DatabaseMetaData 方式");
            return columns;
        }

        String sql = """
            SELECT 
                COLUMN_NAME,
                DATA_TYPE,
                COLUMN_TYPE,
                IS_NULLABLE,
                COLUMN_DEFAULT,
                COLUMN_COMMENT,
                CHARACTER_MAXIMUM_LENGTH,
                NUMERIC_PRECISION,
                NUMERIC_SCALE,
                COLUMN_KEY,
                EXTRA,
                ORDINAL_POSITION
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = ?
              AND TABLE_NAME = ?
            ORDER BY ORDINAL_POSITION
            """;

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, schema);
            pstmt.setString(2, tableName);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    GenTableColumn column = buildColumnFromInfoSchema(rs);
                    columns.add(column);
                }
            }
        } catch (Exception e) {
            System.out.println("使用 INFORMATION_SCHEMA 查询失败，回退到 DatabaseMetaData: " + e.getMessage());
        }

        return columns;
    }

    /**
     * 从 INFORMATION_SCHEMA 结果集构建列对象
     */
    private GenTableColumn buildColumnFromInfoSchema(ResultSet rs) throws Exception {
        GenTableColumn column = new GenTableColumn();

        String columnName = rs.getString("COLUMN_NAME");
        column.setColumnName(columnName);
        column.setColumnType(rs.getString("DATA_TYPE"));

        // 处理注释
        String remarks = rs.getString("COLUMN_COMMENT");
        column.setColumnComment(forSchemaDescription(remarks));

        // 名称转换
        column.setCamelCaseColumnName(StringUtils.toCamelCase(columnName));
        column.setCapitalizeCamelCaseColumnName(StringUtils.toCapitalizeCamelCase(columnName));
        column.setUpperCaseWithUnderscoreColumnName(StrUtil.toUpperCase(columnName));

        // 映射 Java 类型
        String dataType = rs.getString("DATA_TYPE");
        String fieldType = mapJdbcTypeToJavaType(dataType);
        column.setFieldType(fieldType);

        // 设置查询类型（关键！）
        column.setQueryType(getQueryType(column));

        // 设置其他属性
        column.setNullable("YES".equals(rs.getString("IS_NULLABLE")));
        column.setDefaultValue(rs.getString("COLUMN_DEFAULT"));
        column.setPrimaryKey("PRI".equals(rs.getString("COLUMN_KEY")));
        column.setAutoIncrement(rs.getString("EXTRA").contains("auto_increment"));
        column.setSort(rs.getInt("ORDINAL_POSITION"));

        return column;
    }

    /**
     * 辅助方法：获取查询类型
     */
    private String getQueryType(GenTableColumn column) {
        return column.getQueryType(); // 调用 GenTableColumn 的 getQueryType() 方法
    }

    /**
     * 从 DatabaseMetaData 结果集构建列对象
     */
    private GenTableColumn buildColumnFromResultSet(ResultSet rs) throws Exception {
        GenTableColumn column = new GenTableColumn();

        String columnName = rs.getString("COLUMN_NAME");
        column.setColumnName(columnName);
        column.setColumnType(rs.getString("TYPE_NAME"));

        // 处理注释
        String remarks = rs.getString("REMARKS");
        column.setColumnComment(forSchemaDescription(remarks));

        // 名称转换
        column.setCamelCaseColumnName(StringUtils.toCamelCase(columnName));
        column.setCapitalizeCamelCaseColumnName(StringUtils.toCapitalizeCamelCase(columnName));
        column.setUpperCaseWithUnderscoreColumnName(StrUtil.toUpperCase(columnName));

        // 映射 Java 类型
        String dataType = rs.getString("TYPE_NAME");
        column.setFieldType(mapJdbcTypeToJavaType(dataType));

        // 设置是否可为空
        int nullable = rs.getInt("NULLABLE");
        column.setNullable(nullable == DatabaseMetaData.columnNullable);

        return column;
    }

    /**
     * 映射 JDBC 类型到 Java 类型
     */
    private String mapJdbcTypeToJavaType(String jdbcType) {
        if (StrUtil.isBlank(jdbcType)) {
            return "String";
        }

        jdbcType = jdbcType.toUpperCase();

        switch (jdbcType) {
            case "VARCHAR":
            case "CHAR":
            case "TEXT":
            case "MEDIUMTEXT":
            case "LONGTEXT":
                return "String";

            case "INT":
            case "TINYINT":
            case "SMALLINT":
            case "MEDIUMINT":
                return "Integer";

            case "BIGINT":
                return "Long";

            case "DECIMAL":
            case "NUMERIC":
                return "BigDecimal";

            case "FLOAT":
                return "Float";

            case "DOUBLE":
                return "Double";

            case "BOOLEAN":
            case "BIT":
                return "Boolean";

            case "DATE":
            case "DATETIME":
            case "TIMESTAMP":
            case "TIME":
                return "Date";
            // case "DATE":
            //     return "LocalDate";
            //
            // case "DATETIME":
            // case "TIMESTAMP":
            //     return "LocalDateTime";
            //
            // case "TIME":
            //     return "LocalTime";

            default:
                return "String";
        }
    }

    /**
     * 获取当前 schema（数据库名）
     */
    private String getCurrentSchema(Connection connection) throws Exception {
        // 方法1：使用 getCatalog()（添加 nullCatalogMeansCurrent=true 后应该可用）
        String catalog = connection.getCatalog();
        if (StrUtil.isNotBlank(catalog)) {
            return catalog;
        }

        // 方法2：查询 SELECT DATABASE()
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT DATABASE()")) {
            if (rs.next()) {
                return rs.getString(1);
            }
        }

        // 方法3：从 URL 解析
        String url = connection.getMetaData().getURL();
        if (url.contains("/")) {
            String[] parts = url.split("/");
            if (parts.length >= 4) {
                String dbPart = parts[3];
                int questionIndex = dbPart.indexOf('?');
                return questionIndex > 0 ? dbPart.substring(0, questionIndex) : dbPart;
            }
        }

        return null;
    }

    /**
     * 处理数据库注释，生成适合 @Schema description 的字符串
     */
    public static String forSchemaDescription(String comment) {
        if (StrUtil.isBlank(comment)) {
            return "";
        }

        // 1. 去除首尾空白
        String result = StrUtil.trim(comment);

        // 2. 替换所有换行符为空格
        result = result.replace("\r\n", " ")
                       .replace("\n", " ")
                       .replace("\r", " ");

        // 3. 合并多个空格
        result = ReUtil.replaceAll(result, "\\s+", " ");

        // 4. 转义双引号
        result = StrUtil.replace(result, "\"", "\\\"");

        // 5. 限制长度
        if (StrUtil.length(result) > 200) {
            result = StrUtil.sub(result, 0, 197) + "...";
        }

        return result;
    }

    /**
     * 解析表名字符串
     */
    private Set<String> parseTableNames(String tableNamesStr) {
        Set<String> tables = new LinkedHashSet<>();
        if (StrUtil.isBlank(tableNamesStr)) {
            return tables;
        }

        String[] tableArray = tableNamesStr.split(",");
        for (String table : tableArray) {
            String trimmed = StrUtil.trim(table);
            if (StrUtil.isNotBlank(trimmed)) {
                tables.add(trimmed);
            }
        }

        return tables;
    }

    /**
     * 生成实体类文件
     */
    private void generateEntityFile(Map<String, Object> dataMap) throws Exception {
        String folderPath = genFolder ? packageFolder + "/domain/entity/" : "";
        createPackageFolder(folderPath);

        String className = (String) dataMap.get("ClassName");
        String path = diskPath + folderPath + className + ".java";

        generateFileByTemplate("entity.ftl", new File(path), dataMap);
        System.out.println("生成实体类: " + className + ".java");
    }

    /**
     * 生成 Vo 文件
     */
    private void generateVoFile(Map<String, Object> dataMap) throws Exception {
        String folderPath = genFolder ? packageFolder + "/domain/vo/" : "";
        createPackageFolder(folderPath);

        String className = (String) dataMap.get("ClassName");
        String path = diskPath + folderPath + className + "Vo.java";

        generateFileByTemplate("Vo.ftl", new File(path), dataMap);
        System.out.println("生成 Vo: " + className + "Vo.java");
    }

    /**
     * 生成 Form 查询类文件
     */
    private void generateFormFile(Map<String, Object> dataMap) throws Exception {
        String folderPath = genFolder ? packageFolder + "/domain/form/" : "";
        createPackageFolder(folderPath);

        String className = (String) dataMap.get("ClassName");
        String path = diskPath + folderPath + className + "Form.java";

        generateFileByTemplate("Form.ftl", new File(path), dataMap);
        System.out.println("生成 Form 类: " + className + "From.java");
    }

    /**
     * 生成 DAO/Mapper/Repository 文件
     */
    private void generateMapperFile(Map<String, Object> dataMap) throws Exception {
        String folderPath = genFolder ? packageFolder + "/mapper/" : "";
        createPackageFolder(folderPath);

        String className = (String) dataMap.get("ClassName");
        String path = diskPath + folderPath + className + "Mapper.java";

        generateFileByTemplate("Mapper.ftl", new File(path), dataMap);
        System.out.println("生成 Mapper: " + className + "Mapper.java");
    }

    /**
     * 生成 Service 接口文件
     */
    private void generateServiceInterfaceFile(Map<String, Object> dataMap) throws Exception {
        String folderPath = genFolder ? packageFolder + "/service/" : "";
        createPackageFolder(folderPath);

        String className = (String) dataMap.get("ClassName");
        String path = diskPath + folderPath + className + "Service.java";

        generateFileByTemplate("Service.ftl", new File(path), dataMap);
        System.out.println("生成 Service 接口: " + className + "Service.java");
    }

    /**
     * 生成 Service 实现文件
     */
    private void generateServiceImplFile(Map<String, Object> dataMap) throws Exception {
        String folderPath = genFolder ? packageFolder + "/service/impl/" : "";
        createPackageFolder(folderPath);

        String className = (String) dataMap.get("ClassName");
        String path = diskPath + folderPath + className + "ServiceImpl.java";

        generateFileByTemplate("ServiceImpl.ftl", new File(path), dataMap);
        System.out.println("生成 Service 实现: " + className + "ServiceImpl.java");
    }

    private void generateControllerFile(Map<String, Object> dataMap) throws Exception{
        String folderPath = "";
        if(genFolder){
            folderPath = packageFolder+"/controller/";
            createPackageFolder(folderPath);
        }

        String className = (String) dataMap.get("ClassName");
        String path = diskPath + folderPath + className + "Controller.java";

        generateFileByTemplate("Controller.ftl", new File(path), dataMap);
        System.out.println("生成 Controller 实现: " + className + "Controller.java");
    }

    /**
     * 使用模板生成文件
     */
    private void generateFileByTemplate(final String templateName, File file,
                                        Map<String, Object> dataMap) throws Exception {
        Template template = FreeMarkerTemplateMinUtils.getTemplate(templateName);

        try (FileOutputStream fos = new FileOutputStream(file);
             Writer out = new BufferedWriter(new OutputStreamWriter(fos, "utf-8"), 10240)) {
            template.process(dataMap, out);
        }
    }

    /**
     * 下划线转驼峰并首字母大写
     */
    public String replaceUnderLineAndUpperCase(String str) {
        return StringUtils.capitalize(StringUtils.toCamelCase(str));
    }

    /**
     * 包名转文件夹路径
     */
    private String coverPackage2Folder(String packageName) {
        return StrUtil.replace(packageName, ".", "/");
    }

    /**
     * 创建目录
     */
    private int createDirectory(String descDirName) {
        String descDirNames = descDirName;
        if (!descDirNames.endsWith(File.separator)) {
            descDirNames = descDirNames + File.separator;
        }

        File descDir = new File(descDirNames);
        if (descDir.exists()) {
            return 2; // 已存在
        }

        // 创建目录
        return descDir.mkdirs() ? 1 : 0; // 1:创建成功, 0:创建失败
    }

    /**
     * 创建包文件夹
     */
    private void createPackageFolder(String folderPath) {
        if (!genFolder) {
            return;
        }

        String dirPath = diskPath + folderPath;
        int createFlag = createDirectory(dirPath);
        if (createFlag == 0) {
            throw new RuntimeException("目录创建失败: " + dirPath);
        }
    }
}