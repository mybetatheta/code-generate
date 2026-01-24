package ${package_name}.service.impl;

import org.springframework.stereotype.Service;

import com.zchg.comm.base.service.impl.BaseServiceImpl;
import ${package_name}.dao.${table_name}Dao;
import ${package_name}.entity.${table_name};
import ${package_name}.service.${table_name}Service;

@Service
public class ${table_name}ServiceImpl extends BaseServiceImpl<${table_name}Dao, ${table_name}> implements ${table_name}Service {
	
}
