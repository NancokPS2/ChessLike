extends Resource
class_name SaveFile

const SAVE_FOLDERS_DIR:String = "user://Saves/"

const SAVE_FILE_PATH:String = "user://Saves/{0}/save.tres"
const SETTINGS_FILE_PATH:String = "user://Saves/{0}/settings.ini"

func _init() -> void:
	if DirAccess.make_dir_recursive_absolute(SAVE_FOLDERS_DIR) != OK: push_error("Cannot create saves folder!!!")
	settingsFile.load( SAVE_FILE_PATH.format([saveName]) )

@export var saveName = "New Game"
@export var playerUnits:Array[CharAttributes]
@export var playerFaction:Faction
@export var progressFlags = {"storyStart":false}

var settingsFile:=ConfigFile.new()

func save():
	ResourceSaver.save(self, SAVE_FILE_PATH.format([saveName]))
	settingsFile.save(SETTINGS_FILE_PATH.format([saveName]))
	
static func get_SAVE_FILE_PATH(saveFolder:String)->SaveFile:
	var saveFile:SaveFile = load(SAVE_FILE_PATH.format([saveFolder]))
	return saveFile
	
static func get_all_save_folders()->Array[String]:
	var folders:Array[String]
	folders.assign(DirAccess.get_directories_at(SAVE_FOLDERS_DIR))
	folders.filter(validate_save)
	return folders

static func validate_save(saveFolder:String)->bool:
	return FileAccess.file_exists(SAVE_FILE_PATH.format([saveFolder]))
	
func get_setting(settingName:String):
	if not settingsFile is ConfigFile: push_error("There is no settingsFile loaded"); return null
	settingsFile.get_value("MAIN", settingName)
	
func set_setting(settingName:String, value):
	if not settingsFile is ConfigFile: push_error("There is no settingsFile loaded"); return
	settingsFile.set_value("MAIN", settingName, value)
	pass
