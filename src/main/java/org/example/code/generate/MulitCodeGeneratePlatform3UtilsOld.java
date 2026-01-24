package org.example.code.generate;

import freemarker.template.Template;
import org.dromara.hutool.core.date.DateTime;
import org.dromara.hutool.core.date.DateUtil;
import org.dromara.hutool.core.regex.ReUtil;
import org.dromara.hutool.core.text.StrUtil;
import org.example.code.generate.utils.StringUtils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * 描述：代码生成器
 * Created by Ay on 2017/5/1.
 */
public class MulitCodeGeneratePlatform3UtilsOld {

    private final String AUTHOR = "zy";
    private final String CURRENT_DATE = DateUtil.formatDateTime(DateTime.now());
    private final String URL = "jdbc:mysql://127.0.0.1:8806/aaa?useUnicode=true&characterEncoding=utf-8&allowMultiQueries=true";
    private final String USER = "root";
    private final String PASSWORD = "root";
//    private final String DRIVER = "com.mysql.jdbc.Driver";
    private final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private final String diskPath = "D://test/";

    // private final String packageName = "com.zchg.commbiz.energyex";
    private final String packageName = "com.zchg.platform.service.center.visitor.management";
    /** 是否生成目录结构 */
    private boolean genFolder = true;
    /** 是否生成baseModel */
    private boolean genBaseModel = false;

    private String tableNames = "hv_visitor";
    // private String tableNames = "hy_energy_classification";
    //private String tableNames = "hy_energy_device_year,hy_energy_device_month,hy_energy_device_hour,hy_energy_device_day,hy_energy_device,hy_energy_classification,hy_energy_cal_year,hy_energy_cal_month,hy_energy_cal_hour,hy_energy_cal_device,hy_energy_cal_define,hy_energy_cal_day";
    private String packageFolder = coverPackage2Folder(packageName);
    //遍历中获取
    private String tableAnnotation;
    private String tableName;
    private String ClassName;


    public Connection getConnection() throws Exception{
        Class.forName(DRIVER);
        Properties props =new Properties();
        props.setProperty("user", USER);
        props.setProperty("password", PASSWORD);
        props.setProperty("remarks", "true"); //设置可以获取remarks信息 
        props.setProperty("useInformationSchema", "true");//设置可以获取tables remarks信息

        Connection connection= DriverManager.getConnection(URL, props);
        return connection;
    }

    public static void main(String[] args) throws Exception{
        MulitCodeGeneratePlatform3UtilsOld codeGenerateUtils = new MulitCodeGeneratePlatform3UtilsOld();
        codeGenerateUtils.generate();
    }

    public void generate() throws Exception{
        try {
            Connection connection = getConnection();
            DatabaseMetaData databaseMetaData = connection.getMetaData();

            //生成具体表
            String[] tableNameArr = tableNames.split(",");
            List<String> tableNameListTemp = Arrays.asList(tableNameArr);
            List<String> tableNameList = new ArrayList();
            for (String table : tableNameListTemp) {
                if(table!=null && !table.equals("")) {
                    String ttable= table.trim();
                    tableNameList.add(ttable);
                }
            }

            System.out.println("tableNameList="+tableNameList);
            ResultSet resultSet = databaseMetaData.getTables(null, "%", "%", new String[] { "TABLE" });
            while (resultSet.next()) {
                tableName=resultSet.getString("TABLE_NAME");
                tableAnnotation = resultSet.getString("REMARKS");

                if(tableNameList.contains(tableName)) { //包含则生成
                    //System.out.println("tableName="+tableName+"-tableAnnotation="+tableAnnotation);
                    ClassName = replaceUnderLineAndUpperCase(tableName);
                    generateTableCode(databaseMetaData);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }finally{

        }
    }

    private void generateTableCode(DatabaseMetaData databaseMetaData) throws Exception {
        List<GenTableColumn> columnClassList = getColumns(databaseMetaData, tableName);

        if (!columnClassList.isEmpty()) {
            //
//            generateBaseModelFile(columnClassList);
//            //生成Model文件
            generateEntityFile(columnClassList);
            generateDtoFile(columnClassList);
//            //生成Mapper文件
//            generateMapperFile(columnClassList);
//            //生成Dao文件
            generateDaoFile();
//            //生成服务层接口文件
            generateServiceInterfaceFile();
//            //生成服务实现层文件
            generateServiceImplFile();
//            //生成Controller层文件
//            generateControllerFile();
        }
    }

    private List<GenTableColumn> getColumns(DatabaseMetaData databaseMetaData, String tableName) throws Exception {

        ResultSet resultSet = databaseMetaData.getColumns(null,"%", tableName,"%");

    	 GenTableColumn columnClass = null;
    	 List<GenTableColumn> columnClassList = new ArrayList<>();
         while(resultSet.next()){
             //id字段略过
             //if(resultSet.getString("COLUMN_NAME").equals("id")) continue;
             columnClass = new GenTableColumn();
             //获取字段名称
             columnClass.setColumnName(resultSet.getString("COLUMN_NAME"));
             //获取字段类型
             columnClass.setColumnType(resultSet.getString("TYPE_NAME"));
             //转换字段名称，如 sys_name 变成 sysName
             columnClass.setCamelCaseColumnName(StringUtils.toCamelCase(resultSet.getString("COLUMN_NAME")));
             //转换字段名称，如 sys_name 变成 SysName
             columnClass.setCapitalizeCamelCaseColumnName(StringUtils.toCapitalizeCamelCase(resultSet.getString("COLUMN_NAME")));
             columnClass.setUpperCaseWithUnderscoreColumnName(StrUtil.toUpperCase(resultSet.getString("COLUMN_NAME")));
             //字段在数据库的注释
             String columnComment = forSchemaDescription(resultSet.getString("REMARKS"));
             columnClass.setColumnComment(columnComment);
             columnClassList.add(columnClass);
         }
		return columnClassList;
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

        // 2. 替换所有换行符为空格（Hutool 6.0 写法）
        result = replaceNewLines(result);

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

    private static String replaceNewLines(String text) {
        // 方法1：链式调用 replace
        return text.replace("\r\n", " ")
                   .replace("\n", " ")
                   .replace("\r", " ");

        // 方法2：使用正则表达式
        // return ReUtil.replaceAll(text, "[\r\n]+", " ");

        // 方法3：逐个替换
        // String result = text;
        // result = StrUtil.replace(result, "\r\n", " ");
        // result = StrUtil.replace(result, "\n", " ");
        // result = StrUtil.replace(result, "\r", " ");
        // return result;
    }

    private void generateEntityFile(List<GenTableColumn> columnClassList) throws Exception{
    	String folderPath = "";
    	if(genFolder){
    		folderPath = packageFolder+"/entity/";
    		createPackageFolder(folderPath);
    	}

        final String suffix = ".java";
        final String path = diskPath + folderPath + ClassName + suffix;
        final String templateName = "entity.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        dataMap.put("tableColumns",columnClassList);
        dataMap.put("genBaseModel", genBaseModel);
        generateFileByTemplate(templateName,mapperFile,dataMap);
    }

    private void generateDtoFile(List<GenTableColumn> columnClassList) throws Exception{
        String folderPath = "";
        if(genFolder){
            folderPath = packageFolder+"/dto/";
            createPackageFolder(folderPath);
        }

        final String suffix = ".java";
        final String path = diskPath + folderPath + ClassName+"DTO" + suffix;
        final String templateName = "DTO.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        dataMap.put("tableColumns",columnClassList);
        dataMap.put("genBaseModel", genBaseModel);
        generateFileByTemplate(templateName,mapperFile,dataMap);
    }

    private void generateBaseModelFile(List<GenTableColumn> columnClassList) throws Exception{
        if(!genBaseModel){
            return;
        }
        String folderPath = "";
        if(genFolder){
            folderPath = packageFolder+"/entity/base/";
            createPackageFolder(folderPath);
        }
        final String suffix = ".java";
        final String path = diskPath + folderPath + "Base" + ClassName + suffix;
        final String templateName = "BaseModel.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        dataMap.put("tableColumns",columnClassList);
        generateFileByTemplate(templateName,mapperFile,dataMap);
    }

    private void generateControllerFile() throws Exception{
    	String folderPath = "";
    	if(genFolder){
    		folderPath = packageFolder+"/controller/";
    		createPackageFolder(folderPath);
    	}

        final String suffix = "Controller.java";
        final String path = diskPath + folderPath + ClassName + suffix;
        final String templateName = "Controller.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        generateFileByTemplate(templateName,mapperFile,dataMap);
    }

    private void generateServiceImplFile() throws Exception{
    	String folderPath = "";
    	if(genFolder){
    		folderPath = packageFolder+"/service/impl/";
    		createPackageFolder(folderPath);
    	}

        final String suffix = "ServiceImpl.java";
        final String path = diskPath + folderPath + ClassName + suffix;
        final String templateName = "ServiceImpl.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        generateFileByTemplate(templateName,mapperFile,dataMap);
    }

    private void generateServiceInterfaceFile() throws Exception{
    	String folderPath = "";
    	if(genFolder){
    		folderPath = packageFolder+"/service/";
    		createPackageFolder(folderPath);
    	}

        final String prefix = "";
        final String suffix = "Service.java";
        final String path = diskPath + folderPath + prefix + ClassName + suffix;
        final String templateName = "Service.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        generateFileByTemplate(templateName,mapperFile,dataMap);
    }

    private void generateDaoFile() throws Exception{
    	String folderPath = "";
    	if(genFolder){
    		folderPath = packageFolder+"/dao/";
    		createPackageFolder(folderPath);
    	}

        final String suffix = "Repository.java";
        final String path = diskPath + folderPath + ClassName + suffix;
        final String templateName = "DAO.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        generateFileByTemplate(templateName,mapperFile,dataMap);

    }

    private void generateFileByTemplate(final String templateName,File file,Map<String,Object> dataMap) throws Exception{
        Template template = FreeMarkerTemplateUtils.getTemplate(templateName);
        FileOutputStream fos = new FileOutputStream(file);
        dataMap.put("tableName",tableName);
        dataMap.put("upperCaseTableName",StrUtil.toUpperCase(tableName));
        dataMap.put("ClassName",
                    ClassName);
        dataMap.put("author",AUTHOR);
        dataMap.put("date",CURRENT_DATE);
        dataMap.put("packageName",packageName);
        dataMap.put("tableAnnotation",tableAnnotation);
        Writer out = new BufferedWriter(new OutputStreamWriter(fos, "utf-8"),10240);
        template.process(dataMap,out);
    }

    public String replaceUnderLineAndUpperCase(String str){
        StringBuffer sb = new StringBuffer();
        sb.append(str);
        int count = sb.indexOf("_");
        while(count!=0){
            int num = sb.indexOf("_",count);
            count = num + 1;
            if(num != -1){
                char ss = sb.charAt(count);
                char ia = (char) (ss - 32);
                sb.replace(count , count + 1,ia + "");
            }
        }
        String result = sb.toString().replaceAll("_","");
        return StringUtils.capitalize(result);
    }

    private String coverPackage2Folder(String packageName){
    	return StringUtils.replace(packageName, ".", "/");
    }

    private int createDirectory(String descDirName) {
		String descDirNames = descDirName;
		if (!descDirNames.endsWith(File.separator)) {
			descDirNames = descDirNames + File.separator;
		}
		File descDir = new File(descDirNames);
		if (descDir.exists()) {	// 已存在
			return 2;
		}
		// 创建目录
		if (descDir.mkdirs()) {	//创建成功
			return 1;
		} else {	//创建失败
			return 0;
		}
	}

    private void createPackageFolder(String folderPath){
    	String dirPath = diskPath + folderPath;
		int createFlag = createDirectory(dirPath);
		if(createFlag == 0){
			throw new RuntimeException("目录：" + dirPath + " 创建失败");
		}
    }

}
