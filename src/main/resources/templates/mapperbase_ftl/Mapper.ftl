<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="${package_name}.dao.${table_name}Dao">
	<resultMap id="BaseResultMap"
		type="${package_name}.entity.${table_name}">
		<#if model_column?exists>
	        <#list model_column as model>
		    <result column="${model.columnName}" property="${model.camelCaseColumnName?uncap_first}" />
	        </#list>
	    </#if>
	</resultMap>

	<sql id="Base_Column_List">
		<#if model_column?exists>
			<#assign columnField>
		<#list model_column as model>${model.columnName}, </#list>
			</#assign>
			${columnField?substring(0, columnField?last_index_of(","))}
	    </#if>
	</sql>

</mapper>
