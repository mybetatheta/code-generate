package ${package_name}.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import com.zchg.comm.base.controller.BaseController;
import ${package_name}.entity.${table_name};
import ${package_name}.service.${table_name}Service;

@Controller
@RequestMapping("${table_name}Controller")
public class ${table_name}Controller extends BaseController<${table_name}Service, ${table_name}> {


}
