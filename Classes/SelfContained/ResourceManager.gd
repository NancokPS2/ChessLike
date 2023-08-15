extends Node
class_name ResourceManager

const cachePath:String = "user://cache/main.txt"

#Folders whose contents will be automatically added when this node is ready
@export var autoScanFolders:Dictionary = {} #Directory:group

## Automatically replaces paths with the file when added to a group
@export var keepLoadedDefault:bool = true

## Keeps any requested resources loaded for later. Forced if autoLoadResources is true. Careful with memory usage.
#@export var keepResourcesLoaded:bool:
#	set(val):
#		if autoLoadResources: val = true
#		keepResourcesLoaded = true

var resources:Dictionary = {
}

var pools:Dictionary


#Loading
func _enter_tree() -> void:#Loading of files
	for folder in autoScanFolders:
		var group:String = autoScanFolders[folder]
		store_from_folder(folder,group)
	pass

func store_from_folder(folderPath:String,group:String, keepLoaded:bool=keepLoadedDefault):
	var files:PackedStringArray = DirAccess.get_files_at(folderPath)
	for fileName in files:
		store_single_resource(folderPath+fileName, group, keepLoaded)
	
func store_single_resource(filePath:String,group:String, keepLoaded:bool=keepLoadedDefault):
#	var fileName:String = filePath.get_file()
	if not filePath.get_extension() == "tres": push_error("Extension must be tres but it is " + filePath.get_extension()); return
	var resLoaded:Resource = load(filePath)
	
	var identifier:String = _get_identifier(resLoaded)
	
	if identifier == "": push_error("Empty or invalid identifier. File path: {0} | Identifier: {1} | Group: {2}".format([filePath, identifier, group])); return
	
	#Ensure the group exists in resources
	if not resources.has(group): resources[group] = {}
	
	#Add it to the list of the corresponding group
	if keepLoaded:
		resources[group][identifier] = resLoaded
	else:
		resources[group][identifier] = filePath
	
#	resources[group][fileName] = fileName
	
	
func regenerate_cache():
	var cache:=ConfigFile.new()
	resources.clear()
	
	for folder in autoScanFolders:
		var group:String = autoScanFolders[folder]
		store_from_folder(folder,group)
	
	
	pass
## Attempts to retrieve a resource with the given identifier and keeps it loaded.
func get_resource(identifier:String,group:String)->Resource:#If useCategory is true
#	if identifier == "":
#		push_error("No identifier given for " + group + " returnal.")
#		return null
#	elif group == "":
#		push_error("Tried to retrieve resource but a group was not specified for file: " + identifier)
#		return null
		
	if resources.has(group) and resources[group].has(identifier):
		
		#If it has not been loaded yet, do so now.
		if resources[group][identifier] is String:
			resources[group][identifier] = load(resources[group][identifier])
			
		return resources[group][identifier]
			
	else: 
		push_error("Could not find resource with name '{0}' in group '{1}'".format([identifier,group]))
		return null
	

## Used when registering a Resource to the main Dictionary
func _get_identifier(resource:Resource)->String:
	return resource.resource_path

	
func add_to_pool(identifier:String, group:String, targetPool:String):
	var res:Resource = get_resource(identifier, group)
	pools.get(targetPool,[]).append(res)
	pass

func get_all_in_group(group:String)->Array:
	if not resources.has(group): push_error("The group {0} does not exist.".format([group])); return []
	return resources[group].values()
