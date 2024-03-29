extends VBoxContainer
class_name MapDataEditor

enum FileSelectionModes {MESH_LIBRARY}

@export var mapEditor:MapEditor
@export var fileSelectionMode:FileSelectionModes

@export_category("Fields")
@export var displayName:LineEdit
@export var internalName:LineEdit
@export var description:TextEdit

@export var changeMeshLibBtn:Button

@export var fileSelector:FileDialog

var selectedMeshLib:MeshLibrary

var currentMap:Map

func _ready() -> void:
	changeMeshLibBtn.pressed.connect(set.bind("fileSelectionMode", FileSelectionModes.MESH_LIBRARY))
	changeMeshLibBtn.pressed.connect(fileSelector.show)
	
func load_map(map:Map=mapEditor.mapLoaded):
	currentMap = map
	if not currentMap is Map: push_error("Tried to load a non-Map value."); return
		
	displayName.text = currentMap.displayName
	internalName.text = currentMap.internalName
	description.text = currentMap.description
	selectedMeshLib = map.meshLibrary


	

func update_map(map:Map=currentMap):
	if not map is Map: push_error("No Map is loaded."); return
	map.displayName = displayName.text
	map.internalName = internalName.text
	map.description = description.text
	map.meshLibrary = selectedMeshLib
	
func on_file_selected(filePath:String):
	match fileSelectionMode:
		FileSelectionModes.MESH_LIBRARY: 
			fileSelector.title = "Select a MeshLibrary Resource"
			change_mesh_library(filePath)
			
			
	pass
	
func change_mesh_library(meshPath:String):
	var meshLib:Resource = load(meshPath)
	if not meshLib is MeshLibrary: push_error("Not a MeshLibrary."); return
	
	selectedMeshLib = meshLib
	update_map()
