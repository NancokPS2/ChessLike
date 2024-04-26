extends ComponentActionResource

@export var passive_action: ComponentActionResource

func _affect_entity(entity: Entity3D):
	var target_comp: ComponentAction = entity.get_component(ComponentAction.COMPONENT_NAME)
	var log: ComponentActionLog = target_comp.create_log_for_action(passive_action)	
	target_comp.passive_action_add(log)
