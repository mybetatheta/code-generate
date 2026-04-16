package ${packageName}.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.bean.copier.CopyOptions;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.lang.func.LambdaUtil;
import com.google.common.collect.Lists;
import com.zchg.platform.common.core.constant.BaseProcessId;
import com.zchg.platform.common.core.exception.ServiceException;
import com.zchg.platform.common.core.utils.AopProxyTargetUtils;
import com.zchg.platform.common.core.utils.HyBeanUtils;
import com.zchg.platform.common.core.utils.IdGenerator;
import com.zchg.platform.common.core.utils.QueryHelp;
import com.zchg.platform.common.datasource.utils.jpa.JpaSpecificationsUtils;
import ${packageName}.dao.${ClassName}Repository;
import ${apiDtoPackageName}.${ClassName}Base;
import ${apiDtoPackageName}.${ClassName}Query;
import ${apiDtoPackageName}.${ClassName}SaveParam;
import ${apiDtoPackageName}.${ClassName}VO;
import ${packageName}.entity.${ClassName};
import ${packageName}.service.${ClassName}Service;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

<#assign hasFlag = false>
<#list tableColumns as column>
    <#if column.camelCaseColumnName == "flag">
        <#assign hasFlag = true>
        <#break>
    </#if>
</#list>
@Service
@RequiredArgsConstructor
public class ${ClassName}ServiceImpl implements ${ClassName}Service {

    private static final IdGenerator idGenerator = new IdGenerator(BaseProcessId.PROCESS_ID_COMMON.getBaseId());
    //private static final IdGenerator idGenerator = new IdGenerator(MeetingProcessId.MEETING_TYPE_PROCESS_ID);

    private final ${ClassName}Repository repository;

    @Override
    public Page<${ClassName}VO> page(${ClassName}Query query) {
        Sort sort = Sort.by(Sort.Direction.ASC, LambdaUtil.getFieldName(${ClassName}::getId));
        // 处理分页参数
        Pageable pageable = PageRequest.of(0, Integer.MAX_VALUE, sort);
        if (query.getPage() != null && query.getSize() != null) {
            pageable = PageRequest.of(query.getPage(), query.getSize(), sort);
        }

        // 构建查询条件
        Specification<${ClassName}> spec = getSpecification(query);
        // 执行分页查询
        Page<${ClassName}> page = repository.findAll(spec, pageable);

        // 转换为VO并返回
        Page<${ClassName}VO> pageResult = page.map(this::convertToVO);
        List<${ClassName}VO> content = pageResult.getContent();
        //setExProp(content);
        return pageResult;
    }

    @Override
    public List<${ClassName}VO> list(${ClassName}Query query) {
        // 构建查询条件
        Specification<${ClassName}> spec = getSpecification(query);

        // 执行查询
        List<${ClassName}> list = repository.findAll(spec);
        List<${ClassName}VO> results = BeanUtil.copyToList(list, ${ClassName}VO.class);
        //setExProp(results);
        return results;
    }

    @Override
    public List<${ClassName}VO> listByIds(List<Long> ids) {
        ${ClassName}Query query = new ${ClassName}Query();
        query.setIds(ids);
        return list(query);
    }

    private Specification<${ClassName}> getSpecification(${ClassName}Query query) {

        // 1. 自动生成的条件（来自 QueryHelp）
        Specification<${ClassName}> autoSpec = (root, cq, cb) ->
            cb.and(QueryHelp.getPredicate(root, query, cb));

        // 合并所有条件（AND）
        return JpaSpecificationsUtils.and(autoSpec);
    }


    @Override
    public ${ClassName}Base getById(Long id) {
        // 查询实体
    <#if hasFlag>
        ${ClassName} entity = repository.findByIdAndFlag(id, 0);
    </#if>
    <#if !hasFlag>
        ${ClassName} entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("${ClassName} not found with id: " + id));
    </#if>

        // 转换为VO
        ${ClassName}Base dto = BeanUtil.copyProperties(entity, ${ClassName}Base.class);
        return dto;
    }

    @Override
    public ${ClassName}VO getDetailById(Long id) {
        // 查询实体
    <#if hasFlag>
        ${ClassName} entity = repository.findByIdAndFlag(id, 0);
    </#if>
    <#if !hasFlag>
        ${ClassName} entity = repository.findById(id)
        .orElseThrow(() -> new RuntimeException("${ClassName} not found with id: " + id));
    </#if>

        // 转换为VO
        ${ClassName}VO dto = BeanUtil.copyProperties(entity, ${ClassName}VO.class);
        // 设置扩展属性
        setExProp(Lists.newArrayList(dto));
        return dto;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ${ClassName}Base save(${ClassName}Base base) {
        ${ClassName} oldEntity = null;
        if (base.getId() == null) {
            base.setId(idGenerator.nextId());
            oldEntity = new ${ClassName}();
        }else{
            ${ClassName}Base oldBase = this.getById(base.getId());
            if(oldBase != null){
                oldEntity = new ${ClassName}();
                HyBeanUtils.copyNotNullProperties(oldBase,oldEntity);
<#--                oldEntity = BeanUtil.copyProperties(oldBase, ${ClassName}.class);-->
            }else{
                oldEntity = new ${ClassName}();
            }
        }
        HyBeanUtils.copyNotNullProperties(base, oldEntity);
        ${ClassName} save = repository.save(oldEntity);
        return BeanUtil.copyProperties(save, ${ClassName}Base.class);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public List<${ClassName}Base> saveBatch(List<${ClassName}Base> list) {
        List<${ClassName}Base> resList = Lists.newArrayList();
        for (${ClassName}Base detailBase : list) {
            ${ClassName}Base save = AopProxyTargetUtils.getProxy(this)
                    .save(detailBase);
            resList.add(save);
        }
        return resList;
    }


    @Override
    public ${ClassName}Base deleteById(Long id) {
    <#if hasFlag>
        ${ClassName} old = repository.findByIdAndFlag(id, 0);
        if(old == null){
        return null;
        }
        old.setFlag(1);
        repository.save(old);
        return BeanUtil.copyProperties(old, ${ClassName}Base.class);
    </#if>
    <#if !hasFlag>
        ${ClassName}Base old = this.getById(id);
        repository.deleteById(id);
        return old;
    </#if>
    }

    private ${ClassName}VO convertToVO(${ClassName} entity) {
        if (entity == null) return null;
        ${ClassName}VO vo = new ${ClassName}VO();
        BeanUtil.copyProperties(entity, vo);
        return vo;
    }

    public void setExProp(List<${ClassName}VO> rows) {
        if(CollUtil.isEmpty(rows) || rows.get(0) == null){
            return ;
        }
        // 设置扩展属性
    }
}