extends Node3D
class_name Unit

signal moving
signal moved(where:Vector3i)

signal acting
signal acted

signal was_targeted(withWhat:Ability)
signal targeting(what:Vector3i, withWhat:Ability)

signal turn_started
signal turn_ended

signal time_passed(time:float)

const UNIT_SCENE:PackedScene = preload("res://Objects/Unit/UnitNode.tscn")

@export var saveName:String
@export var attributes:CharAttributes = CharAttributes.new(): #UnitAttributes (stats)
	set(val):
		if attributes is CharAttributes: push_warning("This unit already has attributes set. It is not recommended to swap them like this.")
		attributes = val
		if attributes is CharAttributes: 
			attributes.user = self
			assert(attributes.user == self)
			bodyNode.modelNode = attributes.model.instantiate()
			attributes.stat_changed.connect(on_stat_changed)

@onready var board:GameBoard = Ref.board
			
var bodyNode:=Body.new()
var facing:int = 0#Temp value
#var attributes:UnitAttributes
var requiredAnimationName:String = "STANDING":
	set(val):
		requiredAnimationName = val
		if bodyNode is Body:
			bodyNode.animationRef.play(requiredAnimationName)

@export_category("References")
@export var numbers:Label3D

func _init() -> void:
	add_to_group(Const.ObjectGroups.UNIT,true)
	

func _ready() -> void:
	assert(board is GameBoard)
	add_child(bodyNode)
	
	#TEMP
	await get_tree().process_frame 
	var abil:Ability = load("res://Resources/Abilities/AllAbilities/Heal.tres")
	assert(abil is Ability)
	attributes.abilities.append(abil)
	abil.user = self
	print(attributes.abilities)
#	position = board.gridMap.get_top_of_cell(get_current_cell())

func get_current_cell()->Vector3i:
	var cell:Vector3i = board.gridMap.local_to_map(position)
#	assert(board.gridMap.search_in_cell(cell, MovementGrid.Searches.UNIT, true).has(self))
	return cell

func start_turn():
	attributes.stats.turnDelay = attributes.stats.turnDelayMax
	attributes.stats.actions = attributes.stats.actionsMax
	attributes.stats.moves = attributes.stats.movesMax
	turn_started.emit()

func end_turn():
	turn_ended.emit()

func get_passive_effects():
	pass

func on_stat_changed(statName:String, oldVal:float, newVal:float):
	var floatingNumbers:=StatChangeNumbers.new(statName, oldVal-newVal)
	add_child(floatingNumbers)
	
	if statName == attributes.StatNames.TURN_DELAY:
		time_passed.emit(oldVal - newVal)
#	if statName == AttributesBase.StatNames.HEALTH or statName == AttributesBase.StatNames.HEALTH_MAX:
		


class Generator:


	static func build_from_attributes(attrib:CharAttributes)->Unit:
		var unit:Unit = Unit.UNIT_SCENE.instantiate()#Create an instance
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
	"UPP_ARM_L","UPP_ARM_R",
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
	
	#Contains a reference to each mesh that's a limb
	var limbRefs:Dictionary
	var animationRef:AnimationPlayer

	func update_limb_references():
		limbRefs.clear()
		var meshRefs:Array[Node] = Utility.NodeFuncs.get_all_children(self)#Get all meshes
#		meshRefs =  meshRefs.filter(func (node): return node is MeshInstance3D)

		assert(not meshRefs.is_empty())

		for mesh in meshRefs:#Store references to each limb
			if mesh is MeshInstance3D and Body.is_limb_name_valid(mesh.get_name()):
				limbRefs[mesh.get_name()] = mesh
				
		if limbRefs.values().has(null): push_error("Null value for a limb node in this Body!")
		if limbRefs.size() < Parts.size(): 
			var missingParts:Array = Parts.filter(func(limbName): return not limbRefs.has(limbName))
			push_error("This model has missing parts: " + str(missingParts))
		elif limbRefs.size() > Parts.size(): 
			push_error("This model has more parts than expected: " + str(limbRefs))

	func attach_node_to_limb(node:Node3D, usedLimb:String):
		if not is_limb_name_valid(usedLimb): push_error("{0} is not a valid limb name.".format([usedLimb])); return
		if not usedLimb in limbRefs: push_error("No node has been assigned to {0} ref.".format([usedLimb])); return
		
		#Get node
		var nodeUsed:Node3D = node.duplicate(7)

		#If it has an ORIGIN point, use that.
		var origin = nodeUsed.get_node_or_null("ORIGIN")
		if origin is Node3D: nodeUsed.translate(-origin.position)

		limbRefs[usedLimb].add_child(nodeUsed)

	func free_limb_attachments(limbToFree:String):
		for child in limbRefs[limbToFree].get_children():
			if limbRefs.values().has(child): push_warning("Another valid limbRef is a child of  this limb.")
			remove_child(child)#Remove it's children
			#child.queue_free()#And delete them

	func attach_nodes_from_array(meshes:Array[MeshInstance3D]):#Requires that the model contains meshes with the same name as a body part
		for node in meshes:#For each mesh
			var bodyPartName:String = node.get_name()#Get it's name
			attach_node_to_limb(node,node.get_name())

	static func get_mesh_nodes_in_packed(model:PackedScene)->Array[MeshInstance3D]:
		var nodes:Array#Returned nodes go here
		var modelSceneNode:Node = model.get_state().get_node_instance(0).instantiate()#Get the state of the model
		for child in Utility.NodeFuncs.get_all_children(modelSceneNode):#For each child of the scene
			if child is MeshInstance3D:#If it is a Mesh
				nodes.append(child)#Add it
		return nodes

	static func is_limb_name_valid(limbName:String)->bool:
		return limbName in Parts

class StatChangeNumbers extends Label3D:
	
	var baseValue:float
	var baseColor:=Color.WHITE
	var positiveColor:=Color.GREEN
	var negativeColor:=Color.RED
	
	var movementFinal:Vector3 = Vector3.UP * 2
	var movementDuration:float = 1
	var modulationFinal:=Color.WHITE
	var modulationDuration:float = 1
	
	func _init(_text:String, _value:float) -> void:
		modulate = Color.TRANSPARENT
		billboard = BaseMaterial3D.BILLBOARD_ENABLED
		no_depth_test = true
		
		text = _text + " "
#		if _value < 0: text += "-"
		text += str(_value)
	
	func _ready() -> void:
		update_color()
		pop()
	
	func update_color():
		var value:float = text.to_float()
		
		var offset:float = value / baseValue
		
		var color:Color
		if offset > 1: 
			color = positiveColor
		elif offset < 1: 
			color = negativeColor
		else: 
			color = baseColor
			
		modulate = color 
		
	func pop():
#		var newLabel:Label = labelRef.duplicate(DUPLICATE_SCRIPTS + DUPLICATE_SIGNALS)
		top_level = true
		modulate = Color.TRANSPARENT
		
		var tween:Tween = create_tween().set_parallel(true)
		tween.tween_property(self, "position", movementFinal, movementDuration)
		tween.tween_property(self, "modulate", Color.WHITE, modulationDuration)
		tween.tween_callback(queue_free)
		
		tween.play()
