package org.example.code.generate;

import lombok.Data;

/**
 * 数据库字段封装类
 */
@Data
public class GenTableColumn {

	/** 数据库字段名称 **/
	private String columnName;
	/** 数据库字段类型 **/
	private String columnType;
	/** 数据库字段首字母小写且去掉下划线字符串（小驼峰） **/
	private String camelCaseColumnName;
	/** 数据库字段首字母大写写且去掉下划线字符串（大驼峰） **/
	private String capitalizeCamelCaseColumnName;
	/**
	 * 数据库字段不去下划线全大写
	 * 示例：user_name → USER_NAME
	 */
	private String upperCaseWithUnderscoreColumnName;
	/** 数据库字段注释 **/
	private String columnComment;
	/** Java字段类型 **/
	private String fieldType;
	/** 是否可为空 **/
	private Boolean nullable = true;
	/** 是否主键 **/
	private Boolean primaryKey = false;
	/** 是否自增 **/
	private Boolean autoIncrement = false;
	/** 字段默认值 **/
	private String defaultValue;
	/** 字段排序位置 **/
	private Integer sort;

	/** 是否适合作为查询字段 */
	private Boolean queryable = true;
	/** 查询类型（用于 @HyQuery 注解） */
	private String queryType;

	/**
	 * 判断是否适合作为查询字段
	 */
	public boolean isQueryable() {
		// 大文本字段不适合作为查询条件
		if (columnType != null && (
				columnType.toLowerCase().contains("text") ||
						columnType.toLowerCase().contains("blob") ||
						columnType.toLowerCase().contains("clob"))) {
			return false;
		}

		// 一些特殊字段名不适合作为查询条件
		String lowerName = columnName != null ? columnName.toLowerCase() : "";
		if (lowerName.contains("content") ||
				lowerName.contains("file") ||
				lowerName.contains("image") ||
				lowerName.contains("password") ||
				lowerName.contains("token") ||
				lowerName.contains("avatar") ||
				lowerName.contains("icon") ||
				lowerName.contains("attachment")) {
			return false;
		}

		return queryable;
	}

	/**
	 * 获取查询类型
	 */
	public String getQueryType() {
		if (queryType != null) {
			return queryType;
		}

		// 智能判断查询类型
		String lowerName = columnName != null ? columnName.toLowerCase() : "";

		if (lowerName.contains("name") ||
				lowerName.contains("title") ||
				lowerName.contains("remark") ||
				lowerName.contains("description") ||
				lowerName.contains("keyword")) {
			return "INNER_LIKE";
		}

		String lowerType = fieldType != null ? fieldType.toLowerCase() : "";
		if (lowerType.contains("date") || lowerType.contains("time")) {
			return "BETWEEN";
		}

		return "EQUAL";
	}

	public String getFieldType() {
		// 如果已经设置了fieldType，直接返回
		if (fieldType != null && !fieldType.equals("unknown")) {
			return fieldType;
		}

		if (columnType == null) {
			return "String";
		}

		columnType = columnType.toLowerCase();
		if (columnType.contains("varchar") || columnType.contains("char")) {
			return "String";
		} else if (columnType.equals("int") || columnType.equals("tinyint")) {
			return "Integer";
		} else if (columnType.contains("bigint")) {
			return "Long";
		} else if (columnType.contains("double")) {
			return "Double";
		} else if (columnType.contains("float")) {
			return "Float";
		} else if (columnType.contains("date")) {
			return "Date";
		} else if (columnType.contains("datetime") || columnType.contains("timestamp")) {
			return "LocalDateTime";
		} else if (columnType.contains("time")) {
			return "LocalTime";
		} else if (columnType.contains("decimal") || columnType.contains("numeric")) {
			return "BigDecimal";
		} else if (columnType.contains("boolean") || columnType.contains("bool")) {
			return "Boolean";
		} else if (columnType.contains("text")) {
			return "String";
		}
		return "String";
	}
}