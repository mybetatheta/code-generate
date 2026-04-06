package ${packageName}.dao;

import ${packageName}.entity.${ClassName};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

<#assign hasFlag = false>
<#list tableColumns as column>
    <#if column.camelCaseColumnName == "flag">
        <#assign hasFlag = true>
        <#break>
    </#if>
</#list>
@Repository
public interface ${ClassName}Repository extends JpaRepository<${ClassName}, Long>, JpaSpecificationExecutor<${ClassName}> {

<#if hasFlag>
    ${ClassName} findByIdAndFlag(Long id, int flag);
</#if>
<#if !hasFlag>
    //${ClassName} findByIdAndFlag(Long id, int flag);
</#if>

}
