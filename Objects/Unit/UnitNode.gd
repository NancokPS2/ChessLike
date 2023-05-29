extends Node3D
class_name Unit

signal moving
signal moved(where:Vector3i)

signal acting
signal acted

#signal acted_upon
signal was_targeted(withWhat:Ability)
signal targeting(what:Vector3i, withWhat:Ability)

signal turn_started
signal turn_ended



@export var saveName:String
@export var attributes:CharAttributes = CharAttributes.new(): #UnitAttributes (stats)
	set(val):
		attributes = val
		if attributes is CharAttributes: 
			attributes.user = self
			bodyNode.modelNode = attributes.model.instantiate()
			
var bodyNode:=Body.new()
var inventory:Inventory
var facing:int = 0#Temp value
#var attributes:UnitAttributes
var requiredAnimationName:String = "STANDING":
	set(val):
		requiredAnimationName = val
		if bodyNode is Body:
			bodyNode.animationRef.play(requiredAnimationName)
var board:GameBoard = Ref.board

func _init() -> void:
	add_to_group(Const.Groups.UNIT,true)

func _ready() -> void:
	add_child(bodyNode)
	
	#TESTING
	requiredAnimationName = "STANDING"
	await get_tree().process_frame 
	position = board.gridMap.get_top_of_cell(get_current_cell())

func get_current_cell()->Vector3i:
	var cell:Vector3i = board.gridMap.local_to_map(position)
	assert(board.gridMap.search_in_tile(cell, MovementGrid.Searches.UNIT, true).has(self))
	return cell


#Possible parameters user, flags
func targeted_with_action(parameters:Dictionary):
	emit_signal("acted_upon",parameters)
	pass

func start_turn():
	attributes.stats.turnDelay = attributes.stats.turnDelayMax
	attributes.stats.actions = attributes.stats.actionsMax
	attributes.stats.moves = attributes.stats.movesMax
	emit_signal("turn_started")


func end_turn():
	var UI = Ref.UITree
	emit_signal("turn_ended")


class Generator:


	static func build_from_attributes(attrib:Resource):
		var unit = Const.UnitTemplate.instantiate()#Create an instance
		unit.attributes = attrib#Set it's attributes
		return unit

#	static func generate_new(nickName:String,charRace:String,charClass:String,charFaction:String="DEFAULT"):
#		var charAttribs = CharAttributes.new()
#		return build_from_attributes(charAttribs)

class Body extends Node3D:
#	enum Limbs {HEAD,TORSO,ARM_L,ARM_R,LEG_L,LEG_R}
#	enum Parts {HEAD, TORSO,
#	U_ARM_L,U_ARM_R,
#	D_ARM_L,D_ARM_R,
#	HAND_L, HAND_R,
#	U_LEG_L, U_LEG_R,
#	L_LEG_L, L_LEG_R,
#	FOOT_L, FOOT_R}
#	const Parts:Dictionary = {HEAD="HEAD", TORSO="TORSO",
#	U_ARM_L="UPP_ARM_L",U_ARM_R="ARM_R",
#	D_ARM_L="LOW_ARM_L",D_ARM_R="LOW_ARM_R",
#	HAND_L="HAND_L", HAND_R="HAND_R",
#	U_LEG_L="UPP_LEG_L", U_LEG_R="UPP_LEG_R",
#	L_LEG_L="LOW_LEG_L", L_LEG_R="LOW_LEG_R",
#	FOOT_L="FOOT_L", FOOT_R="FOOT_R"
#	}
	const Parts:Array[String] = ["HEAD", "TORSO",
	"UPP_ARM_L","ARM_R",
	"LOW_ARM_L","LOW_ARM_R",
	"HAND_L", "HAND_R",
	"UPP_LEG_L", "UPP_LEG_R",
	"LOW_LEG_L", "LOW_LEG_R",
	"FOOT_L", "FOOT_R"]

	var modelNode:Node:
		set(val):
			if modelNode is Node and modelNode.get_parent() == self:
				remove_child(modelNode)

			modelNode = val

			if modelNode is Node:
				add_child(modelNode)
				update_limb_references()
				animationRef = modelNode.get_node("AnimationPlayer")
	var limbRefs:Dictionary
	var animationRef:AnimationPlayer

	func update_limb_references():
		limbRefs.clear()
		var meshRefs:Array[Node] = Utility.NodeFuncs.get_all_children(self)#Get all meshes
#		meshRefs =  meshRefs.filter(func (node): return node is MeshInstance3D)

		assert(not meshRefs.is_empty())

		for mesh in meshRefs:#Store references to each limb
			if mesh is MeshInstance3D and is_limb_name_valid(mesh.get_name()):
				limbRefs[mesh.get_name()] = mesh

	func attach_node_to_limb(node:Node3D, usedLimb:String):
		if not is_limb_name_valid(usedLimb): push_error("{0} is not a valid limb name.".format([usedLimb])); return
		if not usedLimb in limbRefs: push_error("No node has been assigned to {0} ref.".format([usedLimb])); return
		
		#Get node
		var nodeUsed = node.duplicate(7)

		#If it has an ORIGIN point, use that.
		var origin = nodeUsed.get_node_or_null("ORIGIN")
		if origin is Node3D: nodeUsed.translate(-origin.position)

		limbRefs[usedLimb].add_child(nodeUsed)

	func free_limb_attachments(limbToFree:String):
		for child in limbRefs[limbToFree].get_children():
			remove_child(child)#Remove it's children
			#child.queue_free()#And delete them

	func attach_nodes_from_array(meshes:Array[MeshInstance3D]):#Requires that the model contains meshes with the same name as a body part
		for node in meshes:#For each mesh
			var bodyPartName:String = node.get_name()#Get it's name
			attach_node_to_limb(node,node.get_name())

	static func get_mesh_nodes_in_packed(model:PackedScene)->Array[MeshInstance3D]:
		var nodes:Array#Returned nodes go here
		var modelNode:Node = model.get_state().get_node_instance(0).instantiate()#Get the state of the model
		for child in Utility.NodeFuncs.get_all_children(modelNode):#For each child of the scene
			if child is MeshInstance3D:#If it is a Mesh
				nodes.append(child)#Add it
		return nodes

	static func is_limb_name_valid(limbName:String)->bool:
		return limbName in Parts
