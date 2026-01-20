class_name ControllerSwitch

var control_node: Controller
var prefab_node: Controller


func switch():
	var switch_node = prefab_node
	prefab_node = control_node
	control_node = switch_node
