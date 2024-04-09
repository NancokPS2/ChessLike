extends Node2D
class_name ComponentInterfaceScene

const Themes: Dictionary = {
	TURN_DISPLAY = preload("res://Assets/Themes/TurnDisplayTheme.tres")
	}

const Colors := {
	"TURN_OWNER" : Color.YELLOW,
	"TURN_THIS_ENTITY" : Color.GREEN,
	"TURN_THIS_ENTITY_AND_OWNER" : Color.YELLOW_GREEN,
	"TURN_DEFAULT" : Color.LIGHT_GRAY,
}

@export var identifier: String

@export_group("Nodes", "node")
@export var node_health_bar: Range
@export var node_energy_bar: Range
@export var node_health_text: Control
@export var node_energy_text: Control
@export var node_name_text: Control
@export var node_turn_cont: HBoxContainer

var active_nodes: Array[StringName]

var auto_update_entity: Entity3D

var timer_reference: Timer

func _ready() -> void:
	update_active_nodes()


func set_auto_update_target(entity: Entity3D):
	auto_update_entity = entity
	if auto_update_entity:
		timer_reference = Timer.new()
		timer_reference.timeout.connect(update_interface)
		add_child(timer_reference)
		timer_reference.start(ComponentInterface.UPDATE_RATE)
	else:
		if timer_reference:
			timer_reference.queue_free()
		
		
## Creates an array with paths to specific properties, the ones which actually have something
func update_active_nodes():
	active_nodes.clear()
	for prop_name: StringName in get_all_node_property_names():
		var node_found: Node = get(prop_name)
		
		if not node_found is Node:
			continue
			
		active_nodes.append(prop_name)
		
		match prop_name:
			&"node_turn_cont":
				node_found.theme
	
func update_interface(entity: Entity3D = auto_update_entity):
	if not entity:
		## Disable auto updates if the target is null
		if auto_update_entity == null:
			set_auto_update_target(null)
		return
	
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

			## Containers
			&"node_turn_cont":
				for child: Node in node_turn_cont.get_children():
					child.queue_free()
					
				#var sub_container := HBoxContainer.new()
				#sub_container.custom_minimum_size.x = get_viewport_rect().size.x * 0.75
					
				var turn_taker_turn_comp: Entity3D = ComponentTurn.get_current_turn_taker().get_entity()
				var turn_comp: ComponentTurn = entity.get_component(ComponentTurn.COMPONENT_NAME)
				
				for comp: ComponentTurn in ComponentTurn.turn_component_array:	
					var label := Label.new()
					label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
					label.custom_minimum_size.y = node_turn_cont.size.y
					label.custom_minimum_size.x = node_turn_cont.size.y
					
					var entity_lore_comp: ComponentLore = comp.get_entity().get_component(ComponentLore.COMPONENT_NAME)
					label.text = lore_comp.get_data(ComponentLore.Keys.NAME)
					
					#Turn owner AND entity being displayed
					if comp == turn_taker_turn_comp and comp.get_entity() == entity:
						label.modulate = Colors.TURN_THIS_ENTITY_AND_OWNER
						
					#Only the turn owner
					elif comp == turn_taker_turn_comp:
						label.modulate = Colors.TURN_OWNER
						
					#Only this entity
					elif comp == turn_comp:
						label.modulate = Colors.TURN_THIS_ENTITY
					
					#Default
					else:
						label.modulate = Colors.TURN_DEFAULT
					
					node_turn_cont.add_child(label)
			
func get_all_node_property_names() -> Array[StringName]:
	var output: Array[StringName]
	
	for prop_dict: Dictionary in get_property_list():
		if prop_dict.get("name", "").begins_with("node_"):
			output.append(prop_dict.name)
	
	return output
