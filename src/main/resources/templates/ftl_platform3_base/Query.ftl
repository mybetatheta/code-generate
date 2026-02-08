package ${packageName}.dto;

import com.zchg.platform.common.core.annotation.HyQuery;
import com.zchg.platform.common.core.group.GetPageGroup;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

/**
* ${tableAnnotation}查询参数
<#if author??>
* @author ${author}
</#if>
<#--<#if date??>-->
<#--    * @date ${date}-->
<#--</#if>-->
*/
@Data
@Schema(description = "${tableAnnotation}查询参数")
public class ${ClassName}Query {

    @HyQuery
    @Schema(description = "ID")
    private Long id;

    @HyQuery(type = HyQuery.Type.IN, propName = "id")
    @Schema(description = "ID列表（批量查询）")
    private List<Long> ids;

    @NotNull(message = "页码不能为空", groups = GetPageGroup.class)
    @Schema(description = "第几页，从 0 开始")
    private Integer page = 0;

    @NotNull(message = "每页显示数不能为空", groups = GetPageGroup.class)
    @Schema(description = "每一页的大小")
    private Integer size = 10;
}