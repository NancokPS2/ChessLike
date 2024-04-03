extends Node2D
class_name ComponentInterfaceScene

@export var identifier: String

@export_group("Nodes", "node")
@export var node_health_bar: Range
@export var node_energy_bar: Range
@export var node_health_text: Control
@export var node_energy_text: Control
@export var node_name_text: Control

var active_nodes: Array[StringName]

func _ready() -> void:
	update_active_nodes()


## Creates an array with paths to specific properties, the ones which actually have something
func update_active_nodes():
	active_nodes.clear()
	for prop_name: String in get_all_node_property_names():
		if get(prop_name) is Node:
			active_nodes.append(prop_name)
	
	
func update_interface(entity: Entity3D):
	var status_comp: ComponentStatus = entity.get_component(ComponentStatus.COMPONENT_NAME)
	var lore_comp: ComponentLore = entity.get_component(ComponentLore.COMPONENT_NAME)
	for node_prop: StringName in active_nodes:
		
		var node: CanvasItem = get(node_prop)
		
		match node_prop:
			
			## Lore text
			&"node_name_text":
				node.text = lore_comp.get_data(ComponentLore.Keys.NAME)
			
			## Meter bars
			&"node_health_bar":
				node.value = status_comp.get_meter(ComponentStatus.MeterKeys.HEALTH)
				node.max_value = status_comp.get_stat(ComponentStatus.StatKeys.HEALTH)
				
			&"node_energy_bar":
				node.value = status_comp.get_meter(ComponentStatus.MeterKeys.HEALTH)
				node.max_value = status_comp.get_stat(ComponentStatus.StatKeys.HEALTH)
			
			## Stat text
			&"node_health_text":
				var health_curr: int = status_comp.get_meter(ComponentStatus.MeterKeys.HEALTH)
				var health_max: int = status_comp.get_stat(ComponentStatus.StatKeys.HEALTH)
				node.text = str(health_curr) + "/" + str(health_max)
				if health_curr >= health_max:
					node.modulate = Color.GREEN_YELLOW
				else:
					node.modulate = Color.WHITE
	
			&"node_energy_text":
				var energy_curr: int = status_comp.get_meter(ComponentStatus.MeterKeys.ENERGY)
				var energy_max: int = status_comp.get_stat(ComponentStatus.StatKeys.ENERGY)
				node.text = str(energy_curr) + "/" + str(energy_max)
				if energy_curr >= energy_max:
					node.modulate = Color.GREEN_YELLOW
				else:
					node.modulate = Color.WHITE

func get_all_node_property_names() -> Array[StringName]:
	var output: Array[StringName]
	
	for prop_dict: Dictionary in get_property_list():
		if prop_dict.get("name", "").begins_with("node_"):
			output.append(prop_dict.name)
	
	return output
