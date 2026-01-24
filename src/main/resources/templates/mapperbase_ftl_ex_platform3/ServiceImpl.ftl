package ${packageName}.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import com.google.common.collect.Lists;
import com.zchg.platform.common.core.utils.QueryHelp;
import ${packageName}.dao.${ClassName}Repository;
import ${packageName}.dto.${ClassName}DTO;
import ${packageName}.dto.${ClassName}Query;
import ${packageName}.entity.${ClassName};
import ${packageName}.service.${ClassName}Service;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ${ClassName}ServiceImpl implements ${ClassName}Service {

    private final ${ClassName}Repository repository;

    @Override
    public Page<${ClassName}DTO> page(${ClassName}Query query) {
        // 处理分页参数
        Pageable pageable = PageRequest.of(0, Integer.MAX_VALUE);
        if (query.getPage() != null && query.getSize() != null) {
            pageable = PageRequest.of(query.getPage(), query.getSize());
        }

        // 构建查询条件
        Specification<${ClassName}> specification = (root, criteriaQuery, criteriaBuilder) ->
            criteriaBuilder.and(QueryHelp.getPredicate(root, query, criteriaBuilder));

        // 执行分页查询
        Page<${ClassName}> page = repository.findAll(specification, pageable);

        // 转换为DTO并返回
        Page<${ClassName}DTO> pageResult = page.map(this::convertToDTO);
        List<${ClassName}DTO> content = pageResult.getContent();
        //setExProp(content);
        return pageResult;
    }

    @Override
    public List<${ClassName}DTO> list(${ClassName}Query query) {
        // 构建查询条件
        Specification<${ClassName}> specification = (root, criteriaQuery, criteriaBuilder) ->
        criteriaBuilder.and(QueryHelp.getPredicate(root, query, criteriaBuilder));

        // 执行查询
        List<${ClassName}> list = repository.findAll(specification);
        List<${ClassName}DTO> results = BeanUtil.copyToList(list, ${ClassName}DTO.class);
        //setExProp(results);
        return results;
    }

    @Override
    public ${ClassName}DTO getById(Long id) {
        // 查询实体
        ${ClassName} entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("${ClassName} not found with id: " + id));

        // 转换为DTO
        ${ClassName}DTO dto = BeanUtil.copyProperties(entity, ${ClassName}DTO.class);
        // 设置扩展属性
        setExProp(Lists.newArrayList(dto));
        return dto;
    }

    @Override
    public ${ClassName}DTO save(${ClassName}DTO dto) {
        return convertToDTO(repository.save(convertToEntity(dto)));
    }

    @Override
    public ${ClassName}DTO update(${ClassName}DTO dto) {
        return convertToDTO(repository.save(convertToEntity(dto)));
    }

    @Override
    public ${ClassName}DTO deleteById(Long id) {
        ${ClassName}DTO old = this.getById(id);
        repository.deleteById(id);
        return old;
    }

    private ${ClassName}DTO convertToDTO(${ClassName} entity) {
        if (entity == null) return null;
        ${ClassName}DTO dto = new ${ClassName}DTO();
        BeanUtil.copyProperties(entity, dto);
        return dto;
    }

    private ${ClassName} convertToEntity(${ClassName}DTO dto) {
        if (dto == null) return null;
        ${ClassName} entity = new ${ClassName}();
        BeanUtil.copyProperties(dto, entity);
        return entity;
    }

    public void setExProp(List<${ClassName}DTO> rows) {
        if(CollUtil.isEmpty(rows) || rows.get(0) == null){
            return ;
        }
        // 设置扩展属性
    }
}