package ${packageName}.domain.form;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

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
public class ${ClassName}Form {

    @Schema(description = "ID")
    private Long id;

    @Schema(description = "ID列表（批量查询）")
    private List<Long> ids;

}