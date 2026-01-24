package org.example.code.generate;

import freemarker.template.Template;
import org.dromara.hutool.core.date.DateTime;
import org.dromara.hutool.core.date.DateUtil;
import org.springframework.util.StringUtils;

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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 描述：代码生成器
 * Created by Ay on 2017/5/1.
 */
public class CodeGenerateUtils {

    private final String AUTHOR = "zy";
    //private final String CURRENT_DATE = "2017/05/03";
    private final String CURRENT_DATE = DateUtil.formatDateTime(DateTime.now());
    private final String tableName = "hy_short_message_config";
    private final String packageName = "com.zchg.smartView.shortMessageConfig";
    private final String tableAnnotation = "报警布防";
    //private final String URL = "jdbc:mysql://192.168.0.212:3306/hy_smart_74?useUnicode=true&characterEncoding=utf-8&allowMultiQueries=true";
    private final String URL = "jdbc:mysql://192.168.0.212:3306/t100019?useUnicode=true&characterEncoding=utf-8&allowMultiQueries=true";
    private final String USER = "root";
    private final String PASSWORD = "root";
    private final String DRIVER = "com.mysql.jdbc.Driver";
    private final String diskPath = "D://test/";
    private final String changeTableName = replaceUnderLineAndUpperCase(tableName);
    
    private final String packageFolder = coverPackage2Folder(packageName);
    private final boolean genFolder = true;	//是否生成目录结构

    public Connection getConnection() throws Exception{
        Class.forName(DRIVER);
        Connection connection= DriverManager.getConnection(URL, USER, PASSWORD);
        return connection;
    }

    public static void main(String[] args) throws Exception{
        CodeGenerateUtils codeGenerateUtils = new CodeGenerateUtils();
        codeGenerateUtils.generate();
    }

    public void generate() throws Exception{
        try {
            Connection connection = getConnection();
            DatabaseMetaData databaseMetaData = connection.getMetaData();
            ResultSet resultSet = databaseMetaData.getColumns(null,"%", tableName,"%");
            
            List<GenTableColumn> columnClassList = getColumns(resultSet);
            
            if (!columnClassList.isEmpty()) {
            	//生成Model文件
            	generateModelFile(columnClassList);
            	//生成Mapper文件
            	generateMapperFile(columnClassList);
            	//生成Dao文件
            	generateDaoFile();
            	//生成服务层接口文件
            	generateServiceInterfaceFile();
            	//生成服务实现层文件
            	generateServiceImplFile();
            	//生成Controller层文件
            	generateControllerFile();
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }finally{

        }
    }

    private List<GenTableColumn> getColumns(ResultSet resultSet) throws Exception {
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
             //转换字段名称，如 sys_name 变成 SysName
             columnClass.setCapitalizeCamelCaseColumnName(replaceUnderLineAndUpperCase(resultSet.getString("COLUMN_NAME")));
             //字段在数据库的注释
             columnClass.setColumnComment(resultSet.getString("REMARKS"));
             columnClassList.add(columnClass);
         }
		return columnClassList;
	}
    
    private void generateModelFile(List<GenTableColumn> columnClassList) throws Exception{
    	String folderPath = "";
    	if(genFolder){
    		folderPath = packageFolder+"/entity/";
    		createPackageFolder(folderPath);
    	}
    	
        final String suffix = ".java";
        final String path = diskPath + folderPath + changeTableName + suffix;
        final String templateName = "entity.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        dataMap.put("model_column",columnClassList);
        generateFileByTemplate(templateName,mapperFile,dataMap);

    }

    private void generateControllerFile() throws Exception{
    	String folderPath = "";
    	if(genFolder){
    		folderPath = packageFolder+"/controller/";
    		createPackageFolder(folderPath);
    	}
    	
        final String suffix = "Controller.java";
        final String path = diskPath + folderPath + changeTableName + suffix;
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
        final String path = diskPath + folderPath + changeTableName + suffix;
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
        final String path = diskPath + folderPath + prefix + changeTableName + suffix;
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
    	
        final String suffix = "Dao.java";
        final String path = diskPath + folderPath + changeTableName + suffix;
        final String templateName = "DAO.ftl";
        File mapperFile = new File(path);
        Map<String,Object> dataMap = new HashMap<>();
        generateFileByTemplate(templateName,mapperFile,dataMap);

    }

    private void generateMapperFile(List<GenTableColumn> columnClassList) throws Exception{
        final String suffix = "Mapper.xml";
        final String path = diskPath + changeTableName + suffix;
        final String templateName = "Mapper.ftl";
        File mapperFile = new File(path);
       
        Map<String,Object> dataMap = new HashMap<>();
        dataMap.put("model_column",columnClassList);
        generateFileByTemplate(templateName,mapperFile,dataMap);

    }

    private void generateFileByTemplate(final String templateName,File file,Map<String,Object> dataMap) throws Exception{
        Template template = FreeMarkerTemplateUtils.getTemplate(templateName);
        FileOutputStream fos = new FileOutputStream(file);
        dataMap.put("table_name_small",tableName);
        dataMap.put("table_name",changeTableName);
        dataMap.put("author",AUTHOR);
        dataMap.put("date",CURRENT_DATE);
        dataMap.put("package_name",packageName);
        dataMap.put("table_annotation",tableAnnotation); 
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
