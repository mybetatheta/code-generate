package ${packageName}.service;

import ${packageName}.dto.${ClassName}DTO;
import ${packageName}.dto.${ClassName}Query;
import org.springframework.data.domain.Page;

import java.util.List;

public interface ${ClassName}Service {

    Page<${ClassName}DTO> page(${ClassName}Query query);

    List<${ClassName}DTO> list(${ClassName}Query query);

    ${ClassName}DTO getById(Long id);

    ${ClassName}DTO save(${ClassName}DTO dto);

    ${ClassName}DTO update(${ClassName}DTO dto);

    ${ClassName}DTO deleteById(Long id);
}