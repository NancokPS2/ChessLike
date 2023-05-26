extends Node3D
class_name Unit

enum limbs {HEAD,TORSO,HAND_L,HAND_R,FOOT_L,FOOT_R}

@export var saveName:String
@export var attributes:CharAttributes = CharAttributes.new(): #UnitAttributes (stats)
	set(val):
		attributes = val
		if attributes is CharAttributes: attributes.user = self
			
var inventory:Inventory
var facing:int = 0#Temp value
#var attributes:UnitAttributes
var requiredAnimationName:String = "stand"
var board:GameBoard = Ref.board

signal moving
signal moved(where:Vector3i)

signal acting
signal acted

#signal acted_upon
signal was_targeted(withWhat:Ability)
signal targeting(what:Vector3i, withWhat:Ability)

signal turn_started
signal turn_ended

#const limbs:Dictionary = {
#	"HEAD":"Head",
#	"TORSO":"Torso",
#	"HAND_L":"HandL",
#	"HAND_R":"HandR",
#	"FOOT_L":"FootL",
#	"FOOT_R":"FootR",
#}
func _init() -> void:
	add_to_group(Const.Groups.UNIT,true)

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


		
#func weapon_attack(hand:int,target:Unit):
#	if inventory.equipped[hand] is Weapon:
#		var weaponUsed = inventory.equipped[hand]
#		weaponUsed.attack(target)
#	else:
#		push_error(attributes.name + " tried to attack with " + inventory.equipped[hand].get_class())
	



class Generator:

	
	static func build_from_attributes(attrib:Resource):
		var unit = Const.UnitTemplate.instantiate()#Create an instance
		unit.attributes = attrib#Set it's attributes
		return unit
		
#	static func generate_new(nickName:String,charRace:String,charClass:String,charFaction:String="DEFAULT"):
#		var charAttribs = CharAttributes.new()
#		return build_from_attributes(charAttribs)

class Model extends Node3D:
	var modelStored:PackedScene
	
	func _init(modelToUse:PackedScene) -> void:
		modelStored = modelToUse
	
#	func add_meshes_from_scene(modelToUse:PackedScene):#Takes all the meshes from a model scene, includes animations
#
#
#		var modelInstance:Node3D = modelToUse.instantiate()
#		if modelInstance == null:
#			push_error("The model used is null!")
#		assert(modelInstance != null)
#
#
#		for child in modelInstance.get_children():
#			modelInstance.remove_child(child)#Remove it from the model
#			add_child(child)#Add it to this object
			
	static func get_mesh_nodes_in_scene(model:PackedScene)->Array[MeshInstance3D]:
		var nodes:Array#Returned nodes go here
		var modelNode:Node = model.get_state().get_node_instance(0).instantiate()#Get the state of the model
		for child in modelNode.get_children():#For each child of the scene
			if child is MeshInstance3D:#If it is a Mesh
				nodes.append(child)#Add it

		return nodes
			

	class Body extends Model:
		var limbRefs:Dictionary
		var animationRef:Node
		
		#Setup
		func _init(modelToUse:PackedScene):
			modelStored = modelToUse
		
		func _ready() -> void:		
			set_name("Body")
#			add_meshes_from_scene(modelStored)
			animationRef = get_node("AnimationPlayer")
			assert(animationRef is AnimationPlayer)
			
			update_limb_references()
			
		func update_limb_references():
			limbRefs.clear()
			var meshRefs:Array = Utility.NodeFuncs.get_all_children(self)#Get all meshes
			
			assert(not meshRefs.is_empty())
			
			for mesh in meshRefs:#Store references to each limb
				if mesh is MeshInstance3D:
					limbRefs[mesh.get_name()] = mesh

		
		
		#Functional
		func attach_node_to_limb(node:Node3D,usedLimb:String):
			if node.get_parent() != null: #Unparent if it already has one
				node.get_parent().remove_child(node)
				
			var origin = node.get_node_or_null("ORIGIN")
			if origin is Node3D:
				node.translate(-origin.position)
				
			limbRefs[usedLimb].add_child(node)

		func free_limb_attachment(limbToFree:String):
			for child in limbRefs[limbToFree].get_children():
				remove_child(child)#Remove it's children
				#child.queue_free()#And delete them

		func attach_nodes_from_array(meshes:Array):#Requires that the model contains meshes with the same name as a body part
			for node in meshes:#For each mesh
				var bodyPartName:String = node.get_name()#Get it's name
				attach_node_to_limb(node,node.get_name())
			


