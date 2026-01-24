package ${packageName}.entity;

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

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

/**
 *
 * ${tableAnnotation}实体类
 */
@Entity
@Table(name = "${upperCaseTableName}")
@Data
@Schema(description = "${tableAnnotation}")
public class ${ClassName} {

<#if genBaseModel==false>
<#list tableColumns as model>
<#if model_index==0>
<#if model.camelCaseColumnName=="id">
    @Id
</#if>
</#if>
<#if model.camelCaseColumnName!="id">
</#if>
    @Schema(description = "${model.columnComment}")
    @Column(name = "${model.upperCaseWithUnderscoreColumnName}",
    nullable = false)
	private ${model.fieldType} ${model.camelCaseColumnName?uncap_first};
</#list>

</#if>
}
