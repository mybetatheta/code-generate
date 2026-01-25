package ${packageName}.service;

import com.clt.matlink.common.domain.form.PageQuery;
import com.clt.matlink.common.domain.vo.PageInfo;
import ${packageName}.domain.entity.${ClassName};
import ${packageName}.domain.form.${ClassName}Form;
import ${packageName}.domain.vo.${ClassName}Vo;

import java.util.List;

public interface ${ClassName}Service {

    ${ClassName} save(${ClassName} ${classNameLower});

    ${ClassName} getById(Long id);

    List<${ClassName}> getByIds(List<Long> ids);

    Boolean deleteById(Long id);

    List<${ClassName}Vo> list(${ClassName}Form form);

    PageInfo<${ClassName}Vo> page(${ClassName}Form form, PageQuery pageQuery);

    List<${ClassName}> batchSave(List<${ClassName}> list);
}