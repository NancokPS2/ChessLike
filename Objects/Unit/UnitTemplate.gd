extends Unit
const defaultModel = preload("res://Assets/CellMesh/Characters/Dummy/Dummy.tscn")

func _ready():#Has temps
	add_to_group("UNIT")
	misc_visuals()
	create_body(attributes.raceAttributes.model)#Adds the base model for the unit
	create_equipment(equipment)#Adds any equipment models on top

var body:Model.Body
func create_body(withModel:PackedScene=defaultModel):
	body = Model.Body.new(withModel)#Assign it to the controller
	add_child(body)
	
func create_equipment(equipDict:Dictionary):
	for equipRes in equipment.values():#Check every equipped item
		if equipRes is Equipment:
			var meshNodes:Array = Model.get_mesh_nodes_in_scene(equipRes.model)#Get it's model nodes
		
			body.attach_nodes_from_array(meshNodes)
				
		

	
func misc_visuals():
	$NickName.text = info["nickName"]
	var charSprites:SpriteFrames = ResourceLoader.load(attributes.raceAttributes.spriteFolder + "default.tres")

class Model extends Node3D:
	var modelStored:PackedScene
	
	func _init(modelToUse:PackedScene) -> void:
		modelStored = modelToUse
	
	func add_meshes_from_scene(modelToUse:PackedScene):#Takes all the meshes from a model scene, includes animations
		var modelInstance:Node3D = modelToUse.instantiate()
		if modelInstance == null:
			push_error("The model used is null!")
		assert(modelInstance != null)
		
		
		for child in modelInstance.get_children():
			modelInstance.remove_child(child)#Remove it from the model
			add_child(child)#Add it to this object
			
	static func get_mesh_nodes_in_scene(model:PackedScene)->Array:
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
			add_meshes_from_scene(modelStored)
			animationRef = get_node("AnimationPlayer")
			assert(animationRef is AnimationPlayer)
			
			update_limb_references()
			
		func update_limb_references():
			limbRefs.clear()
			var meshRefs:Array = Utility.NodeManipulation.get_all_children(self)#Get all meshes
			
			assert(not meshRefs.is_empty())
			
			for mesh in meshRefs:#Store references to each limb
				if mesh is MeshInstance3D:
					limbRefs[mesh.get_name()] = mesh

		
		
		#Functional
		func attach_node_to_limb(node:Node3D,usedLimb:String):
			if node.get_parent() != null: #Unparent if it already has one
				node.get_parent().remove_child(node)
				
			var origin = node.get_node("ORIGIN")
			if origin is Node3D:
				node.translate(-origin.position)
				
			limbRefs[usedLimb].add_child(node)

		func free_limb_attachment(limbToFree:String):
			for child in limbRefs[limbToFree]:
				remove_child(child)#Remove it's children
				#child.queue_free()#And delete them

		func attach_nodes_from_array(meshes:Array):#Requires that the model contains meshes with the same name as a body part
			for node in meshes:#For each mesh
				var bodyPartName:String = node.get_name()#Get it's name
				attach_node_to_limb(node,node.get_name())
			

	
