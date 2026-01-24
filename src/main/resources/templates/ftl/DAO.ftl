package ${package_name}.dao;

import java.util.Map;

import org.apache.ibatis.annotations.MapKey;

import com.zchg.common.annotation.MyBatisDao;
import ${package_name}.entity.${table_name};

@MyBatisDao
public interface ${table_name}Dao {

	int deleteById(int id);

	@MapKey("id")
	Map<Integer, ${table_name}> findAll();

	int insert(${table_name} entity);

	int update(${table_name} entity);

}
