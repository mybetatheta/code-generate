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

	<!-- 查询所有记录 -->
	<select id="findAll" resultMap="BaseResultMap">
		select
		<include refid="Base_Column_List" />
		from ${table_name_small}
	</select>

	<!-- 根据ID删除 -->
	<delete id="deleteById" parameterType="java.lang.Long">
		delete from ${table_name_small} where
		id=${"#"}{id}
	</delete>

	<!-- 插入 -->
	<insert id="insert"
		parameterType="${package_name}.entity.${table_name}"
		useGeneratedKeys="true" keyProperty="id">
		insert into ${table_name_small}
		<trim prefix="(" suffix=")" suffixOverrides=",">
			<#list model_column as c>
			<if test="${c.camelCaseColumnName?uncap_first} != null">
				${c.columnName},
			</if>
			</#list>
		</trim>
		<trim prefix="values (" suffix=")" suffixOverrides=",">
			<#list model_column as c>
			<if test="${c.camelCaseColumnName?uncap_first} != null">
				${"#"}{${c.camelCaseColumnName?uncap_first}},
			</if>
			</#list>
		</trim>  
	</insert>

	<!-- 更新 -->
	<update id="update"
		parameterType="${package_name}.entity.${table_name}">
		update ${table_name_small}
		set
		<trim prefix="" suffix="" suffixOverrides=",">		
			<#list model_column as c>
				<#if c.camelCaseColumnName?uncap_first != "id">
			<if test="${c.camelCaseColumnName?uncap_first} != null">
				${c.columnName} = ${"#"}{${c.camelCaseColumnName?uncap_first}},
			</if>
				</#if>
			</#list>
		</trim>
		where id=${"#"}{id}
	</update>
</mapper>
