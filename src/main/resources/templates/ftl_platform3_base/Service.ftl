package ${packageName}.service;

import ${packageName}.dto.${ClassName}Base;
import ${packageName}.dto.${ClassName}Query;
import ${packageName}.dto.${ClassName}SaveParam;
import ${packageName}.dto.${ClassName}VO;
import org.springframework.data.domain.Page;

import java.util.List;

public interface ${ClassName}Service {

    Page<${ClassName}VO> page(${ClassName}Query query);

    List<${ClassName}VO> list(${ClassName}Query query);

    List<${ClassName}VO> listByIds(List<Long> ids);

    ${ClassName}Base getById(Long id);

    ${ClassName}VO getDetailById(Long id);

    ${ClassName}Base save(${ClassName}Base dto);

    List<${ClassName}Base> saveBatch(List<${ClassName}Base> list);

    ${ClassName}Base update(${ClassName}Base dto);

    ${ClassName}Base deleteById(Long id);
}