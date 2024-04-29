extends Node3D
class_name Entity3D

enum Flags {
	INHERT, #Cannot move, act or take turns. Useful for obstacles.
	SUMMON, #Does not count as a unit for evaluating how many combatants a faction has remaining.	
	CRITICAL, #The unit is weakened, usually because of 50% health.
}

signal component_changed(component_name: String)

const ENTITY_GROUP: String = "ENTITY_3D_GROUP"
const CONFIG_PATH_RES: String = "res://Scripts/Resources/Entity/{0}.cconfig"
const CONFIG_PATH_USER: String = Global.FolderPaths.USER + "CharacterData/{0}.cconfig"
const CONFIG_SECTION_MAIN: String = "MAIN"
const CONFIG_SECTION_MAIN_KEY_IDENTIFIER: String = "IDENTIFIER"
const CONFIG_SECTION_MAIN_KEY_METADATA: String = "METADATA" 

var identifier: String = "DEFAULT"

var config_file_cache: ConfigFile

var metadata: Dictionary

var components: Dictionary

var flags: Dictionary

func _init():
	child_entered_tree.connect(on_child_entered_tree)


func _enter_tree() -> void:
	add_to_group(ENTITY_GROUP)


func get_all_in_tree(tree: SceneTree) -> Array[Entity3D]:
	return tree.get_nodes_in_group(ENTITY_GROUP) as Array[Entity3D]


func flag_set(flag: Flags, enable: bool):
	flags[flag] = enable

	
func flag_get(flag: Flags) -> bool:
	return flags.get(flag, false)


func add_all_components():
	var comps: Array[Node] = [
		ComponentFaction.new(),
		ComponentInput.new(),
		ComponentInventory.new(),
		ComponentLore.new(),
		ComponentMovement.new(),
		ComponentStatus.new(),
		ComponentTurn.new(),
		ComponentVision.new(),
		ComponentDisplay.new(),
		ComponentCapability.new(),
		ComponentInterface.new(),
		ComponentAction.new(),
		ComponentStack.new(),
	]
	for comp: Node in comps:
		add_child(comp)

## Components are not meant to be removed. Create a new instance if you need one with removed components.
func add_component(comp: Node):
	var comp_name: String = comp.get("COMPONENT_NAME")
	assert(comp_name is String)
	
	components[comp_name] = comp
	comp.name = comp_name
	
	## This component was already added, stop here.
	if comp.get_parent() == self and components[comp_name] == comp:
		return
	
	## Replace any existing component with the same COMPONENT_NAME
	if components.get(comp_name, null) is Node:
		components[comp_name].queue_free()
		
	add_child(comp)
	
	component_changed.emit(comp_name)


## TODO: Add PERSISTENT_PROPERTIES to components
func store_config_file(identifier_used: String = identifier):
	## Create a new ConfigFile
	var config_to_save = ConfigFile.new()

	## Store main data
	config_to_save.set_value(CONFIG_SECTION_MAIN, CONFIG_SECTION_MAIN_KEY_IDENTIFIER, identifier_used)
	config_to_save.set_value(CONFIG_SECTION_MAIN, CONFIG_SECTION_MAIN_KEY_METADATA, metadata)
	
	## Store component data
	for comp_name: String in components:
		var comp_node: Node = components[comp_name]
		
		if not comp_node.get("PERSISTENT_PROPERTIES"):
			continue
		
		for property: String in comp_node.PERSISTENT_PROPERTIES:
			config_to_save.set_value(comp_name, property, comp_node.get(property))
		
	## Save the file
	var save_path: String = get_config_file_path(identifier_used, false)
	DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	var error: Error = config_to_save.save( save_path )
	if not error == OK:
		push_error(error_string(error))
	
	## Replace the cached version
	config_file_cache = config_to_save
	
	
func load_config_file(identifier_used: String = identifier):
	var loaded_config: ConfigFile = get_config_file(identifier_used)
	if not loaded_config:
		push_error("Could not load config file.")
		return
		
	## Load the identifier and misc stuff
	identifier = loaded_config.get_value(CONFIG_SECTION_MAIN, CONFIG_SECTION_MAIN_KEY_IDENTIFIER)
	metadata = loaded_config.get_value(CONFIG_SECTION_MAIN, CONFIG_SECTION_MAIN_KEY_METADATA, {})

	## Get and set component data
	for comp_name: String in components:
		var comp_node: Node = components[comp_name]
		
		if not comp_node.get("PERSISTENT_PROPERTIES"):
			continue
		
		for property: String in comp_node.PERSISTENT_PROPERTIES:
			var value = loaded_config.get_value(comp_name, property)
			comp_node.set(property, value)
	
	config_file_cache = loaded_config
	
	
func get_config_file_path(identifier_used: String = identifier, res_dir: bool = false) -> String:
	var output: String = ""
	
	if res_dir:
		output = CONFIG_PATH_RES.format([identifier_used])
	else:
		output = CONFIG_PATH_USER.format([identifier_used])
	
	return output


func get_config_file(identifier_used: String = identifier) -> ConfigFile:
	var config := ConfigFile.new()
	var error: Error
	
	## Try to load from user://
	var user_path: String = get_config_file_path(identifier_used, false)
	error = config.load(user_path)
	if error == OK:
		return config
	
	## Try to load from res:// if it could not be loaded fom user://
	var res_path: String = get_config_file_path(identifier_used, true)
	error = config.load(res_path)
	if error == OK:
		return config
	
	## If all fails, throw an error
	push_error("Could not load entity config file with identifier '{0}' due to error '{1}'.".format([identifier, error_string(error)]))
	return null


func get_component(component_name: String) -> Node:
	assert(components.get(component_name, null).get("COMPONENT_NAME"))
	return components.get(component_name, null)
	
	
func on_child_entered_tree(node: Node):
	var comp_name: String = node.get("COMPONENT_NAME")
	
	if not comp_name is String:
		return
	
	add_component(node)


func _to_string():
	return "Entity3D#{0} ({1})".format([get_instance_id(), identifier])
