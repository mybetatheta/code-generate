package ${package_name}.entity;

<#list model_column as model>
<#if model.fieldType=="Date">
import java.util.Date;
    <#break/>
</#if>
</#list>

import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

import com.zchg.common.utils.PageSplit;

/**
 *
 * ${table_annotation}实体类(${table_name_small})
 */
@Table(name = "${table_name_small}")
public class ${table_name} extends PageSplit<${table_name}> {
	
<#list model_column as model>
<#if model_index==0>
<#if model.camelCaseColumnName=="id">
	@Id
	@GeneratedValue(generator="JDBC")
</#if>
</#if>
	private ${model.fieldType} ${model.camelCaseColumnName?uncap_first};	//${model.columnComment!}
</#list>

<#if model_column?exists>
	<#list model_column as model>
    public ${model.fieldType} get${model.capitalizeCamelCaseColumnName}() {
        return this.${model.camelCaseColumnName?uncap_first};
    }

    public void set${model.capitalizeCamelCaseColumnName}(${model.fieldType} ${model.camelCaseColumnName?uncap_first}) {
        this.${model.camelCaseColumnName?uncap_first} = ${model.camelCaseColumnName?uncap_first};
    }
		
	</#list>
</#if>
}