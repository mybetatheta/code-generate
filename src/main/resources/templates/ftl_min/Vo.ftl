package ${packageName}.domain.vo;

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
 * ${tableAnnotation}Vo
 */
@Data
@Schema(description = "${tableAnnotation}")
public class ${ClassName}Vo {

<#if genBaseModel==false>
<#list tableColumns as model>
    @Schema(description = "${model.columnComment}")
	private ${model.fieldType} ${model.camelCaseColumnName?uncap_first};
</#list>

</#if>
}
