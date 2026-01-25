package org.example.code.generate.domain;

public class GenTable {

    /** 数据库字段名称 **/
    private String tableName;
    /** 数据库字段类型 **/
    private String columnType;
    /** 数据库字段首字母小写且去掉下划线字符串 **/
    private String changeColumnName;
    /** 数据库字段注释 **/
    private String columnComment;
}
