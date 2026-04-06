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
import com.zchg.platform.common.core.utils.HyServletUtils;
import com.zchg.platform.common.core.utils.WebFrameworkUtils;
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
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Data;

import java.util.Objects;
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
    <#assign hasCreateTime = false>
    <#list tableColumns as column>
        <#if column.camelCaseColumnName == "createTime">
            <#assign hasCreateTime = true>
            <#break>
        </#if>
    </#list>
    <#assign hasCreateUserId = false>
    <#list tableColumns as column>
        <#if column.camelCaseColumnName == "createUserId">
            <#assign hasCreateUserId = true>
            <#break>
        </#if>
    </#list>
    <#assign hasFlag = false>
    <#list tableColumns as column>
        <#if column.camelCaseColumnName == "flag">
            <#assign hasFlag = true>
            <#break>
        </#if>
    </#list>

    @PrePersist
    void initProperty() {
    <#if hasCreateTime>
        if(this.createTime == null){
            this.createTime = System.currentTimeMillis();
        }
    </#if>
    <#if hasCreateUserId>
        if(this.createUserId == null){
            this.createUserId = WebFrameworkUtils.getUserId(Objects.requireNonNull(HyServletUtils.getRequest()));
        }
    </#if>
    <#if hasFlag>
        if(this.flag == null){
            this.flag = 0;
        }
    </#if>
    }


</#if>
}
