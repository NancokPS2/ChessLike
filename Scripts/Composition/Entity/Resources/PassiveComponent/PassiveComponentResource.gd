extends Resource
class_name ComponentPassiveResource
## Passives trigger a [ComponentActionResource] (using [ComponentAction] as usual) when a specific condition happens, additional arguments may be required for some conditions.  
## [property get_custom_targets] is called regardless of conditions, leave [param activation_conditions] empty to use only the function.


@export var display_name: String
@export var icon: Texture2D = load("res://icon.png")

@export var identifier: String

@export var activation_condition: ComponentPassive.ActivationConditions
@export var activation_flags: Array[ComponentPassive.Flags]
@export var activation_parameters: Array = [0]
@export var activation_parameters_action_flags: Array[ComponentAction.ActionFlags] = [ComponentAction.ActionFlags.HOSTILE]
@export var action_activated: ComponentActionResource
@export var duration: int = 100

func get_custom_targets() -> Array[Vector3i]:
	return []
