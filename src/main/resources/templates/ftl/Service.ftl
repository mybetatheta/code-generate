package ${package_name}.service;

import java.util.List;
import java.util.Map;

import ${package_name}.entity.${table_name};

public interface ${table_name}Service {

	int deleteById(int id);

	Map<Integer, ${table_name}> findAll();
	
	List<${table_name}> findList(${table_name} entity);

	${table_name} findPage(${table_name} entity);
	
	${table_name} get(${table_name} entity);
	
	${table_name} getById(Integer id);

	int insert(${table_name} entity);

	int update(${table_name} entity);
	
	void save(${table_name} entity);
}
