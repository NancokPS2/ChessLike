extends Node3D
class_name Entity3D

var components: Dictionary

func _init():
	child_entered_tree.connect(on_child_entered_tree)

func add_all_components():
	var comps: Array[Node] = [
		ComponentFaction.new(),
		ComponentInput.new(),
		ComponentInventory.new(),
		ComponentLore.new(),
		ComponentMovement.new(),
		ComponentStats.new(),
		ComponentTurn.new(),
		ComponentVision.new(),
		ComponentDisplay.new(),
	]
	for comp: Node in comps:
		add_child(comp)


func add_component(comp: Node):
	var comp_name: String = comp.get("COMPONENT_NAME")
	assert(comp_name is String)
	
	## Replace any existing component with the same COMPONENT_NAME
	if components[comp_name] is Node:
		components[comp_name].queue_free()
		
	components[comp_name] = comp


func get_component(component_name: String) -> Node:
	assert(components.get(component_name, null).get("COMPONENT_NAME"))
	return components.get(component_name, null)
	

func on_child_entered_tree(node: Node):
	var comp_name: String = node.get("COMPONENT_NAME")
	
	if not comp_name is String:
		return
	
	components[comp_name] = node
	node.name = comp_name

