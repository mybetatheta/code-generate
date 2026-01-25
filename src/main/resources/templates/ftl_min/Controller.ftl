package ${packageName}.controller;

import com.clt.matlink.common.domain.form.PageQuery;
import com.clt.matlink.common.domain.vo.PageInfo;
import com.clt.matlink.common.domain.vo.Result;
import ${packageName}.domain.entity.${ClassName};
import ${packageName}.domain.form.${ClassName}Form;
import ${packageName}.domain.vo.${ClassName}Vo;
import ${packageName}.service.${ClassName}Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

<#if tableAnnotation??>
    /**
    *  ${tableAnnotation}
    */
<#else>
    /**
    *  ${ClassName}
    */
</#if>
@RequestMapping("/${className}")
@RestController
public class ${ClassName}Controller {

@Autowired
private ${ClassName}Service ${className}Service;

    /**
    * 新建${tableAnnotation!""}
    */
    @PostMapping()
    public Result<${ClassName}> create(@RequestBody ${ClassName} ${className}){
        return Result.success(${className}Service.save(${className}));
    }

    /**
    * 修改${tableAnnotation!""}
    * @param ${className}
    * @return
    */
    @PutMapping()
    public Result<${ClassName}> update(@RequestBody ${ClassName} ${className}){
        return Result.success(${className}Service.save(${className}));
    }

    /**
    * 批量修改${tableAnnotation!""}
    * @param materials
    * @return
    */
    @PutMapping("batchUpdate")
    public Result<List<${ClassName}>> batchUpdate(@RequestBody List<${ClassName}> materials){
        return Result.success(${className}Service.batchSave(materials));
    }

    /**
    * 根据${tableAnnotation!""}Id查询${tableAnnotation!""}
    */
    @GetMapping("{id}")
    public Result<${ClassName}> getById(@PathVariable("id") Long id){
        return Result.success(${className}Service.getById(id));
    }

    /**
    * 根据${tableAnnotation!""}Ids查询${tableAnnotation!""}列表
    */
    @GetMapping("/getByIds/{ids}")
    public Result<List<${ClassName}>> getById(@PathVariable("ids") List<Long> ids){
        return Result.success(${className}Service.getByIds(ids));
    }

    /**
    * 删除${tableAnnotation!""}
    */
    @DeleteMapping("{id}")
    public Result<Void> deleteById(@PathVariable("id") Long id){
       ${className}Service.deleteById(id);
        return Result.success();
    }

    /**
    * 查询${tableAnnotation!""}列表
    */
    @GetMapping("/list")
    public Result<List<${ClassName}Vo>> list(${ClassName}Form ${className}Form){
        return Result.success(${className}Service.list(${className}Form));
    }

    /**
    * 分页查询${tableAnnotation!""}列表
    */
    @GetMapping("/page")
    public Result<PageInfo<${ClassName}Vo>> page(${ClassName}Form ${className}Form, PageQuery pageQuery){
        return Result.success(${className}Service.page(${className}Form, pageQuery));
    }
}