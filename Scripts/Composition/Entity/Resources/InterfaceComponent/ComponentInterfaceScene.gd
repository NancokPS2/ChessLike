extends Node2D
class_name ComponentInterfaceScene

const ThemesTypeVariations: Dictionary = {
	PROGRESS_BAR_ENERGY = "ProgressBarEnergy",
	PROGRESS_BAR_HEALTH = "ProgressBarHealth"
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
@export var node_turn_delay_text: Control

@export var node_stat_list: VBoxContainer

@export var node_action_list: ItemList

@export var node_turn_cont: HBoxContainer
@export var node_call_stack_list: ItemList

var active_nodes: Array[StringName]

var enable_autoupdate_dict: Dictionary

var auto_update_entity: Entity3D

var timer_reference: Timer

var entity_cache: Entity3D


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
		
		
func set_autoupdate_for_node(prop_name: StringName, enable: bool):
	enable_autoupdate_dict[prop_name] = enable
		
		
## Creates an array with paths to specific properties, the ones which actually have something
func update_active_nodes(entity: Entity3D):
	active_nodes.clear()
	for prop_name: StringName in get_all_node_property_names():
		var node_found: Node = get(prop_name)
		
		if not node_found is Node:
			continue
			
		active_nodes.append(prop_name)
		
		match prop_name:
			&"node_turn_cont":
				node_found.theme
			
			&"node_action_list":
				if not node_found.item_activated.is_connected(on_action_button_selected.bind(node_found)):
					node_found.item_activated.connect(on_action_button_selected.bind(node_found, entity))
	
func update_interface(entity: Entity3D = auto_update_entity):
	if not entity:
		## Disable auto updates if the target is null
		if auto_update_entity == null:
			set_auto_update_target(null)
		return
	
	if entity_cache != entity:
		update_active_nodes(entity)
		entity_cache = entity
	
	var status_comp: ComponentStatus = entity.get_component(ComponentStatus.COMPONENT_NAME)
	var lore_comp: ComponentLore = entity.get_component(ComponentLore.COMPONENT_NAME)
	for node_prop: StringName in active_nodes:
		
		if not enable_autoupdate_dict.get(node_prop, true):
			continue
		
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
				for child: Node in node.get_children():
					child.queue_free()
					
				#var sub_container := HBoxContainer.new()
				#sub_container.custom_minimum_size.x = get_viewport_rect().size.x * 0.75
					
				var turn_taker_turn_comp: Entity3D = ComponentTurn.get_current_turn_taker().get_entity()
				var turn_comp: ComponentTurn = entity.get_component(ComponentTurn.COMPONENT_NAME)
				
				for comp: ComponentTurn in ComponentTurn.turn_component_array:	
					var label := Label.new()
					label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
					label.custom_minimum_size.y = node.size.y
					label.custom_minimum_size.x = node.size.y
					
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
					
					node.add_child(label)
					
			&"node_call_stack_list":
				node.clear()
				var index: int = 0
				for stack_obj: ComponentStack.StackObject in ComponentStack.call_stack_arr:
					node.add_item(str(stack_obj.function))
					index += 1
			
			&"node_action_list":
				#const MAIN_LIST: StringName = &"ACTION_LIST_MAIN"
				#const MOVE_LIST: StringName = &"ACTION_LIST_MOVEMENT"
				#const ITEM_LIST: StringName = &"ACTION_LIST_ITEM"
				#node.set_meta(ENTITY_ID_KEY, entity.get_instance_id())
				
				#var actions_available_main: Array[ComponentActionResource] = action_comp.get_actions_available(ComponentAction.ActionCategories.MAIN)
				#var actions_available_movement: Array[ComponentActionResource] = action_comp.get_actions_available(ComponentAction.ActionCategories.MOVEMENT)
				#var actions_available_item: Array[ComponentActionResource] = action_comp.get_actions_available(ComponentAction.ActionCategories.ITEM)
				
				var action_comp: ComponentAction = entity.get_component(ComponentAction.COMPONENT_NAME)
				var actions_available: Array[ComponentActionResource] = action_comp.get_actions_available(ComponentAction.ActionCategories.ALL)				
				
				node.clear()
				var index: int = 0
				for action: ComponentActionResource in actions_available:
					node.add_item(action.identifier)
					node.set_item_metadata(index, action)
					index += 1
								
			&"node_stat_list":
				for child: Node in node.get_children():
					child.queue_free()
					
				for stat: ComponentStatus.StatKeys in ComponentStatus.StatKeys:
					var stat_string: String = ComponentStatus.StatKeys.find_key(stat)
					var value: int = status_comp.get_stat(stat)
					var label := Label.new()
					label.text = "{0}: {1}".format([stat_string, str(value)])
				
			&"node_turn_delay_text":
				var turn_comp: ComponentTurn = entity.get_component(ComponentTurn.COMPONENT_NAME)
				var curr_delay: int = turn_comp.delay_current
				var base_delay: int = turn_comp.get_base_delay()
				node.text = "TR: {0} | Base TR: {1}".format([str(curr_delay),str(base_delay)])
			
func get_all_node_property_names() -> Array[StringName]:
	var output: Array[StringName]
	
	for prop_dict: Dictionary in get_property_list():
		if prop_dict.get("name", "").begins_with("node_"):
			output.append(prop_dict.name)
	
	return output


func on_action_button_selected(index: int, item_list: ItemList, entity: Entity3D):
	var inter_comp: ComponentInterface = entity.get_component(ComponentInterface.COMPONENT_NAME)
	var action_res: ComponentActionResource = item_list.get_item_metadata(index)
	
	if not action_res:
		return
	
	Event.ENTITY_INTERFACE_ACTION_SELECTED.emit(inter_comp, action_res)
