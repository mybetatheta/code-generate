package ${packageName}.controller;

import ${packageName}.dto.${ClassName}DTO;
import ${packageName}.query.${ClassName}Query;
import ${packageName}.service.${ClassName}Service;
import com.zchg.common.base.controller.BaseController;
import com.zchg.common.core.base.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

<#-- 处理路由路径：去除第一个下划线之前的前缀 -->
<#function getRequestMappingPath tableName>
    <#if tableName?contains('_')>
        <#local firstUnderscore = tableName?index_of('_')>
        <#local processedName = tableName?substring(firstUnderscore + 1)>
    <#else>
        <#local processedName = tableName>
    </#if>
    
    <#-- 将下划线替换为斜杠，并转为小写 -->
    <#local path = processedName?replace('_', '/')?lower_case>
    
    <#return "/api/" + path>
</#function>

<#assign requestMappingPath = getRequestMappingPath(tableName)>

@Tag(name = "${tableAnnotation}管理")
@RestController
@RequestMapping("${requestMappingPath}")
@RequiredArgsConstructor
public class ${ClassName}Controller extends BaseController {

    private final ${ClassName}Service ${className}Service;

    @Operation(summary = "分页查询")
    @GetMapping("/page")
    public R<Page<${ClassName}DTO>> page(@Valid ${ClassName}Query query) {
        return R.ok(${classNameLower}Service.page(query));
    }

    @Operation(summary = "列表查询")
    @GetMapping("/list")
    public R<List<${ClassName}DTO>> list(@Valid ${ClassName}Query query) {
        return R.ok(${classNameLower}Service.list(query));
    }

    @Operation(summary = "根据ID查询")
    @GetMapping("/{id}")
    public R<${ClassName}DTO> getById(@PathVariable Long id) {
        return R.ok(${classNameLower}Service.getById(id));
    }

    @Operation(summary = "新增")
    @PostMapping
    public R<${ClassName}DTO> save(@Valid @RequestBody ${ClassName}DTO dto) {
        return R.ok(${classNameLower}Service.save(dto));
    }

    @Operation(summary = "删除")
    @DeleteMapping("/{id}")
    public R<${ClassName}DTO> deleteById(@PathVariable Long id) {
        return R.ok(${classNameLower}Service.deleteById(id));
    }
}