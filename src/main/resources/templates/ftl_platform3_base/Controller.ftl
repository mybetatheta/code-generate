package ${packageName}.controller;

import com.zchg.platform.common.core.domain.R;
import ${packageName}.dto.${ClassName}Base;
import ${packageName}.dto.${ClassName}Query;
import ${packageName}.dto.${ClassName}VO;
import ${packageName}.service.${ClassName}Service;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

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
public class ${ClassName}Controller {

    private final ${ClassName}Service ${classNameLower}Service;

    @Operation(summary = "分页查询")
    @GetMapping("/page")
    public R<Page<${ClassName}VO>> page(${ClassName}Query query) {
        return R.ok(${classNameLower}Service.page(query));
    }

    @Operation(summary = "列表查询")
    @GetMapping("/list")
    public R<List<${ClassName}VO>> list(${ClassName}Query query) {
        return R.ok(${classNameLower}Service.list(query));
    }

    @Operation(summary = "根据ID查询")
    @GetMapping("/{id}")
    public R<${ClassName}VO> getDetailById(@PathVariable Long id) {
        return R.ok(${classNameLower}Service.getDetailById(id));
    }

    @Operation(summary = "新增")
    @PostMapping
    public R<${ClassName}Base> save(@RequestBody ${ClassName}Base base) {
        return R.ok(${classNameLower}Service.save(base));
    }

    @Operation(summary = "修改")
    @PutMapping
    public R<${ClassName}Base> update(@RequestBody ${ClassName}Base base) {
        return R.ok(${classNameLower}Service.update(base));
    }

    @Operation(summary = "删除")
    @DeleteMapping("/{id}")
    public R<${ClassName}Base> deleteById(@PathVariable Long id) {
        return R.ok(${classNameLower}Service.deleteById(id));
    }
}