extends Resource
class_name SaveFile

const SAVE_FOLDERS_DIR:String = "user://Saves/"
const SAVE_DIR:String = "user://Saves/{0}/save.tres"
const SETTINGS_DIR:String = "user://Saves/{0}/settings.ini"

func _init() -> void:
	if DirAccess.make_dir_recursive_absolute(SAVE_FOLDERS_DIR) != OK: push_error("Cannot create saves folder!!!")
	settingsFile.load( SAVE_DIR.format([saveName]) )

@export var saveName = "New Game"
@export var playerUnitsIN:Array[CharAttributes]
@export var playerFactionIN:Faction
@export var progressFlags = {"storyStart":false}
var settingsFile:ConfigFile

func save():
	ResourceSaver.save(self, SAVE_DIR.format([saveName]))
	settingsFile.save(SETTINGS_DIR.format([saveName]))
	
static func get_save_file(saveName:String)->SaveFile:
	var saveFile:SaveFile = load(SAVE_DIR)
	return saveFile
	
static func get_all_save_folders()->Array[String]:
	var folders:Array[String]
	folders.assign(DirAccess.get_directories_at(SAVE_FOLDERS_DIR))
	folders.filter(validate_save)
	return folders

static func validate_save(saveName:String)->bool:
	return FileAccess.file_exists(SAVE_DIR.format([saveName]))
	
	
