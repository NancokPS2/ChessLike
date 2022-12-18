extends Resource
class_name SaveLoad


class SaveFile extends ConfigFile:
	
	const SaveName = "New Game"
	const Flags = 0
	const PlayerUnitsIN = ["Misha"]
	const PlayerFactionIN = "PLAYER"
	const ProgressFlags = {"storyStart":false}
	
	var playerUnits:Array
	var playerFaction:Faction
	
	func _init() -> void:
		if not get_value("misc","initiated"):
			set_value("main","saveName",SaveName)
			set_value("main","flags",Flags)
			set_value("main","progressFlags",ProgressFlags)
			set_value("main","playerFactionIN",PlayerFactionIN)
			set_value("main","playerUnitsIN",PlayerUnitsIN)
			set_value("misc","initiated",true)

	

	enum ErrorCode {OK,NULL_FACTION,NO_UNITS}
	var currentStatus
	func setup():#Must be ran after being loaded
		load_resources()
		push_warning("Setup of save finished with status: " + str( validation_messages() ) )
			

	func load_resources():#Initial loading of resources
		
		var unitsIN = get_value("main","playerUnitsIN")
		var factionIN = get_value("main","playerFactionIN")
		assert(unitsIN is Array and factionIN is String)
		
		for unitIN in unitsIN:#Load units
			var loadedUnit = ResList.get_resource(unitIN,"characters")
			assert(loadedUnit is Resource)
			var unitNode = Unit.Generator.build_from_attributes(loadedUnit)
			playerUnits.append(unitNode)
		
		playerFaction = ResList.get_resource(factionIN,"factions")
		assert(playerFaction is Faction)

	func validation_messages():
		var messages:Array
		
		if not playerFaction is Faction:
			messages.append("Faction is null /")
			
		if playerUnits.empty():
			messages.append("No playable units could be loaded /")
			
		if messages.empty():
			messages.append("OK")
		
		return( str(messages) )


class Manager extends Node:

	static func reset_save(saveFile:ConfigFile):
		saveFile.set_value("main","saveName","New Game")
		
		var starterChars = ["res://Resources/Characters/UniqueCharacters/Misha.tres"]
		saveFile.set_value("main","playerUnitsIN",starterChars)
		
		return saveFile
		
	static func load_save_file(fileName:String)->Resource:
		var save = ConfigFile.new()
		return save.load(Const.dirSaves + fileName + "/save.cfg")
		
#	static func get_all_save_data(saveFolderPath:String)->Dictionary:
#		var dir = Directory.new()
#		var saves:Array
#
#		dir.open(Const.dirSaves)
#		dir.list_dir_begin()
#		var folderName = dir.get_next()
#
#		while folderName != "":
#			if dir.current_is_dir():
#				var saveDir:String = targetDir + folderName
#				var currentDict:Dictionary
#				var configFile:ConfigFile = ConfigFile.new()
#
#				currentDict["configFile"]
#				currentDict["icon"]
#
#
#			folderName = dir.get_next()
#		return saves

	static func save_game(file:ConfigFile)->String:#Returns the path it was saved at
		var saved = file
		var dir = Directory.new()
		var saveName = file.get_value("main","saveName")#Name of the save file and it's folder
		var targetDir = Const.dirSaves+saveName+"/"#Where it should be saved
		var errorCode:int#Used to keep track of errors
		
		if dir.dir_exists(targetDir):#Alter the name if it already exists
			file.set_value("main","saveName",saveName+"_DUP")
			
		errorCode = dir.make_dir_recursive(targetDir)#Create the dir just in case
		assert(errorCode == OK)
		dir.open(targetDir)
			
		if saved is Resource:#Convert to ConfigFile if not on
			saved = save_to_config(saved)
			
		saved.set_value("main","icon",targetDir+"/icon.png")#Store a path to the icon
			
		errorCode = saved.save(targetDir + "save.tactsav")#Save the file
		
		if errorCode:#If something went wrong report it
			push_error( "Reported error code while saving: " + str(errorCode) )
		
		return targetDir

	static func config_to_save(file:ConfigFile)->Resource:
		var saveFile
		for key in file.get_section_keys("main"):
			saveFile.set(key,file.get_value("main",key,null))
		
		return saveFile

	static func save_to_config(saveFile)->ConfigFile:
		var config = ConfigFile.new()
		config.set_value("main","saveName",saveFile.saveName)
		config.set_value("main","flags",saveFile.flags)
		config.set_value("main","progressFlags",saveFile.progressFlags)
		config.set_value("main","playerFactionIN",saveFile.playerFactionIN)
		config.set_value("main","playerUnitsIN",saveFile.playerUnitsIN)
		return config
