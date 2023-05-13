
	
#class FileManipulation extends Node:
#	static func get_files_in_folder(path:String)->Array:
#		var returnedFiles:Array
#		var loadingDir = Directory.new()
#		loadingDir.open(path)#Start loading abilities
#		loadingDir.list_dir_begin(true)
#		var fileName = loadingDir.get_next()
#
#		while fileName != "":
#			if !loadingDir.current_is_dir():
#				var loadedFile = load(path + fileName)
#				returnedFiles.append(loadedFile)
#
#			fileName = loadingDir.get_next()#Get next file
#		return returnedFiles
#
#	static func get_file_paths_in_folder(path:String)->Array:
#			var returnedPaths:Array
#			var loadingDir = Directory.new()
#			loadingDir.open(path)#Start loading abilities
#			loadingDir.list_dir_begin()
#			var fileName = loadingDir.get_next()
#
#			while fileName != "":
#				if !loadingDir.current_is_dir():
#					returnedPaths.append(path+fileName)
#
#				fileName = loadingDir.get_next()#Get next file
#			return returnedPaths
#
#	static func get_folders_in_folder(path:String)->Array:
#			var returnedPaths:Array
#			var loadingDir = Directory.new()
#			loadingDir.open(path)#Start loading abilities
#			loadingDir.list_dir_begin(true)
#			var folderName = loadingDir.get_next()
#
#			while folderName != "":
#				if loadingDir.current_is_dir():
#					returnedPaths.append(path+folderName)
#
#				folderName = loadingDir.get_next()#Get next file
#			return returnedPaths
