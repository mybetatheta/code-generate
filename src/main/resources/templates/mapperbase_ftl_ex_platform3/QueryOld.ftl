package ${packageName}.query;

import com.zchg.platform.common.core.annotation.HyQuery;
import com.zchg.platform.common.core.group.GetPageGroup;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
<#-- 智能导入 -->
<#assign hasDate = false>
<#assign hasLocalDate = false>
<#assign hasLocalDateTime = false>
<#assign hasLocalTime = false>
<#assign hasBigDecimal = false>
<#list tableColumns as column>
    <#if column.queryable>
        <#if column.fieldType == "Date">
            <#assign hasDate = true>
        <#elseif column.fieldType == "LocalDate">
            <#assign hasLocalDate = true>
        <#elseif column.fieldType == "LocalDateTime">
            <#assign hasLocalDateTime = true>
        <#elseif column.fieldType == "LocalTime">
            <#assign hasLocalTime = true>
        <#elseif column.fieldType == "BigDecimal">
            <#assign hasBigDecimal = true>
        </#if>
    </#if>
</#list>
<#if hasDate>
    import java.util.Date;
</#if>
<#if hasLocalDate>
    import java.time.LocalDate;
</#if>
<#if hasLocalDateTime>
    import java.time.LocalDateTime;
</#if>
<#if hasLocalTime>
    import java.time.LocalTime;
</#if>
<#if hasBigDecimal>
    import java.math.BigDecimal;
</#if>

/**
* ${tableAnnotation}查询参数
<#if author??>
    * @author ${author}
</#if>
<#if date??>
    * @date ${date}
</#if>
*/
@Data
@Schema(description = "${tableAnnotation}查询参数")
public class ${ClassName}Query {

<#-- 生成查询字段 -->
<#list tableColumns as column>
    <#if column.queryable>
        <#assign comment = column.columnComment!column.capitalizeCamelCaseColumnName>
        <#assign processedComment = comment?replace("[\r\n]+", " ", "r")?replace('"', '\\"')?trim>
        <#assign queryType = column.queryType!"EQUAL">
    @HyQuery(<#if queryType != "EQUAL">type = HyQuery.Type.${queryType}</#if>)
    @Schema(description = "${processedComment}")
    private ${column.fieldType} ${column.camelCaseColumnName?uncap_first};
    </#if>
</#list>

    /**
    * 关键词搜索
    */
    @HyQuery(type = HyQuery.Type.INNER_LIKE, blurry = "title,name,description")
    @Schema(description = "关键词搜索")
    private String keyword;

    @NotNull(message = "页码不能为空", groups = GetPageGroup.class)
    @Schema(description = "第几页，从 0 开始")
    private Integer page = 0;

    @NotNull(message = "每页显示数不能为空", groups = GetPageGroup.class)
    @Schema(description = "每一页的大小")
    private Integer size = 10;
}