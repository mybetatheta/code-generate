package ${package_name}.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zchg.common.collectionsfilter.ConditionFilterUtil;
import com.zchg.common.utils.BeanUtils;
import ${package_name}.dao.${table_name}Dao;
import ${package_name}.entity.${table_name};
import ${package_name}.service.${table_name}Service;

@Service
public class ${table_name}ServiceImpl implements ${table_name}Service {
	@Autowired
	private ${table_name}Dao hyDao;

	private Map<Integer, ${table_name}> hyMap = null;

	@Override
	public int deleteById(int id) {
		int type = hyDao.deleteById(id);
		if (type > 0) {
			synchronized (hyMap) {
				hyMap.remove(id);
			}
		}
		return type;
	}

	@Override
	@PostConstruct
	public Map<Integer, ${table_name}> findAll() {
		if (hyMap == null) {
			hyMap = hyDao.findAll();
		}
		return hyMap;
	}

	@Override
	public List<${table_name}> findList(${table_name} entity) {
		return ConditionFilterUtil.findListByMultiCond(hyMap.values(), entity);
	}

	@Override
	public ${table_name} findPage(${table_name} entity) {
		List<${table_name}> findList = this.findList(entity);
		entity.buildByList(findList);
		return entity;
	}

	@Override
	public ${table_name} get(${table_name} entity) {
		return ConditionFilterUtil.getFirstByMultiCond(hyMap.values(), entity);
	}

	@Override
	public ${table_name} getById(Integer id) {
		return hyMap.get(id);
	}

	@Override
	public int insert(${table_name} entity) {
		int type = hyDao.insert(entity);
		if (type > 0) {
			synchronized (hyMap) {
				hyMap.put(entity.getId(), entity);
			}
		}
		return type;
	}

	@Override
	public int update(${table_name} entity) {
		int type = hyDao.update(entity);
		if (type > 0) {
			synchronized (hyMap) {
				${table_name} item = hyMap.get(entity.getId());
				if (item != null) {
					BeanUtils.copyNotNullProperties(entity, item);
				}
			}
		}
		return type;
	}

	@Override
	public void save(${table_name} entity) {
		if (entity.getId() != null) {
			this.update(entity);
		} else {
			this.insert(entity);
		}
	}
}
