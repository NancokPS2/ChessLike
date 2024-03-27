extends Node
class_name AbilitySystem

const TARGETING_SHAPE_FRONT:Array[Vector3i]=[Vector3i.FORWARD]
const TARGETING_SHAPE_LINE_TWO:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2]
const TARGETING_SHAPE_LINE_THREE:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2, Vector3i.FORWARD*3]
const TARGETING_SHAPE_SELF:Array[Vector3i]=[Vector3i.ZERO]
const TARGETING_SHAPE_ADJACENT:Array[Vector3i]=[Vector3i.LEFT, Vector3i.RIGHT, Vector3i.BACK, Vector3i.FORWARD]
const TARGETING_SHAPE_ALL:Array[Vector3i]=[]
const TARGETING_SHAPE_STAR_ONE:Array[Vector3i]=[Vector3i.ZERO, Vector3i.LEFT, Vector3i.RIGHT, Vector3i.BACK, Vector3i.FORWARD]
const TARGETING_SHAPE_CONE_ONE:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2, Vector3i.FORWARD+Vector3i.LEFT, Vector3i.FORWARD+Vector3i.RIGHT]
const TARGETING_SHAPE_BARRIER:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD+Vector3i.LEFT, Vector3i.FORWARD+Vector3i.RIGHT]


const COMP_ABILITY_USABLE:StringName = "_AbilitySystem_USABLE"

var refCompUsables:Array[AbilitySystemUsable]

func _enter_tree() -> void:
	get_tree().node_added.connect(on_node_entered)	


func on_node_entered(node:Node) -> void:
	if node is AbilitySystemUsable:
		usable_add(node)

func usable_get_all(fromGroup:bool)->Array[AbilitySystemUsable]:
	if fromGroup:
		var usables:Array[AbilitySystemUsable]
		usables.assign(get_tree().get_nodes_in_group(COMP_ABILITY_USABLE))
		return usables
	else:
		return refCompUsables
	
func usable_add(usable:AbilitySystemUsable):
	refCompUsables.append(usable)
