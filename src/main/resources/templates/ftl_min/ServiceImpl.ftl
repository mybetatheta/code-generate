package ${packageName}.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollStreamUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.clt.matlink.common.domain.form.PageQuery;
import com.clt.matlink.common.domain.vo.PageInfo;
import com.clt.matlink.common.enums.DelFlagEnum;
import ${packageName}.domain.entity.${ClassName};
import ${packageName}.domain.form.${ClassName}Form;
import ${packageName}.domain.vo.${ClassName}Vo;
import ${packageName}.mapper.${ClassName}Mapper;
import ${packageName}.service.${ClassName}Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ${ClassName}ServiceImpl implements ${ClassName}Service {

    @Autowired
    private ${ClassName}Mapper ${classNameLower}Mapper;

    @Override
    public ${ClassName} save(${ClassName} ${classNameLower}) {
        int flag = 0;
        if(${classNameLower}.getId()==null){
            flag= ${classNameLower}Mapper.insert(${classNameLower});
        }else{
            flag = ${classNameLower}Mapper.updateById(${classNameLower});
        }
        if(flag>0){
            return ${classNameLower}Mapper.selectById(${classNameLower}.getId());
        }else{
            return null;
        }
    }

    @Override
    public ${ClassName} getById(Long id) {
        return ${classNameLower}Mapper.selectById(id);
    }

    @Override
    public List<${ClassName}> getByIds(List<Long> ids) {
        LambdaQueryWrapper<${ClassName}> lqw = Wrappers.lambdaQuery();
        lqw.eq(${ClassName}::getDelFlag, DelFlagEnum.NORMAL.getValue());
        lqw.in( ${ClassName}::getId, ids);
        return ${classNameLower}Mapper.selectList(lqw);
    }

    @Override
    public Boolean deleteById(Long id) {
        ${classNameLower}Mapper.deleteById(id);
        return true;
    }

    @Override
    public List<${ClassName}Vo> list(${ClassName}Form form) {
        LambdaQueryWrapper<${ClassName}> lqw = getQueryWrapper(form);
        List<${ClassName}> list = ${classNameLower}Mapper.selectList(lqw);
        List<${ClassName}Vo> voList = BeanUtil.copyToList(list, ${ClassName}Vo.class);
        return voList;
    }

    @Override
    public PageInfo<${ClassName}Vo> page(${ClassName}Form form, PageQuery pageQuery) {

        LambdaQueryWrapper<${ClassName}> lqw = getQueryWrapper(form);
        Page<${ClassName}> page = pageQuery.build();
        Page<${ClassName}> result = ${classNameLower}Mapper.selectPage(page, lqw);
        PageInfo<${ClassName}Vo> tableDataInfo = PageInfo.build(result,${ClassName}Vo.class );
        List<${ClassName}Vo> list = tableDataInfo.getList();

        return tableDataInfo;
    }

    @Override
    public List<${ClassName}> batchSave(List<${ClassName}> list) {
        ${classNameLower}Mapper.insertOrUpdateBatch(list);
        List<Long> ids = CollStreamUtil.toList(list, ${ClassName}::getId);
        List<${ClassName}> result = getByIds(ids);
        return result;
    }

    private LambdaQueryWrapper<${ClassName}> getQueryWrapper(${ClassName}Form form) {
        LambdaQueryWrapper<${ClassName}> lqw = Wrappers.lambdaQuery();
        lqw.eq(form.getId()!=null, ${ClassName}::getId, form.getId());
        lqw.eq(${ClassName}::getDelFlag, DelFlagEnum.NORMAL.getValue());
        return lqw;
    }
}