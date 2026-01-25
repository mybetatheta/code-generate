package ${packageName}.domain.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.clt.matlink.common.domain.entity.BaseEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

<#-- 导入BigDecimal -->
<#assign hasBigDecimal = false>
<#list tableColumns as column>
    <#if column.fieldType == "BigDecimal">
        <#assign hasBigDecimal = true>
        <#break>
    </#if>
</#list>
<#if hasBigDecimal>
import java.math.BigDecimal;
</#if>
<#-- 智能导入日期类 -->
<#assign dateImports = []>
<#list tableColumns as column>
    <#if column.fieldType == "Date">
        <#if !dateImports?seq_contains("java.util.Date")>
            <#assign dateImports = dateImports + ["java.util.Date"]>
        </#if>
    <#elseif column.fieldType == "LocalDateTime">
        <#if !dateImports?seq_contains("java.time.LocalDateTime")>
            <#assign dateImports = dateImports + ["java.time.LocalDateTime"]>
        </#if>
    <#elseif column.fieldType == "LocalDate">
        <#if !dateImports?seq_contains("java.time.LocalDate")>
            <#assign dateImports = dateImports + ["java.time.LocalDate"]>
        </#if>
    <#elseif column.fieldType == "LocalTime">
        <#if !dateImports?seq_contains("java.time.LocalTime")>
            <#assign dateImports = dateImports + ["java.time.LocalTime"]>
        </#if>
    </#if>
</#list>
<#list dateImports as import>
import ${import};
</#list>
/**
 *
 * ${tableAnnotation}实体类
 */
@Data
@TableName("${upperCaseTableName}")
@Schema(description = "${tableAnnotation}")
public class ${ClassName} extends BaseEntity {

<#list tableColumns as model>
<#-- 排除 createTime、updateTime、delFlag 字段 -->
    <#if model.camelCaseColumnName != "createTime"
    && model.camelCaseColumnName != "updateTime"
    && model.camelCaseColumnName != "delFlag">
        <#if model_index == 0>
            <#if model.camelCaseColumnName == "id">

            </#if>
        </#if>
    @Schema(description = "${model.columnComment}")
    private ${model.fieldType} ${model.camelCaseColumnName?uncap_first};
    </#if>
</#list>
}
