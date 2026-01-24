package ${package_name}.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import ${package_name}.entity.${table_name};
import ${package_name}.service.${table_name}Service;

@Controller
@RequestMapping("${table_name}Controller")
public class ${table_name}Controller {

	@Autowired
	private ${table_name}Service hyService;

	@RequestMapping("deleteById")
	@ResponseBody
	public int deleteById(int id) {
		return hyService.deleteById(id);
	}

	@RequestMapping("findAll")
	@ResponseBody
	public List<${table_name}> findAll() {
		Map<Integer, ${table_name}> map = hyService.findAll();
		if (map != null) {
			return new ArrayList<>(map.values());
		}
		return null;
	}

	@RequestMapping("findList")
	@ResponseBody
	public List<${table_name}> findList(${table_name} entity) {
		return hyService.findList(entity);
	}

	@RequestMapping("findPage")
	@ResponseBody
	public ${table_name} findPage(${table_name} entity) {
		return hyService.findPage(entity);
	}

	@RequestMapping("get")
	@ResponseBody
	public ${table_name} get(${table_name} user) {
		return hyService.get(user);
	}

	@RequestMapping("getById")
	@ResponseBody
	public ${table_name} getById(int id) {
		return hyService.getById(id);
	}

	@RequestMapping("insert")
	@ResponseBody
	public int insert(${table_name} hyDriverAdapter) {
		return hyService.insert(hyDriverAdapter);
	}

	@RequestMapping("update")
	@ResponseBody
	public int update(${table_name} hyDriverAdapter) {
		return hyService.update(hyDriverAdapter);
	}
	
	@RequestMapping("save")
	@ResponseBody
	public String save(${table_name} entity) {
		hyService.save(entity);
		return "1";
	}

}
