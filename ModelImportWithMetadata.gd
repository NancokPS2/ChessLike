tool
extends EditorScenePostImport
var ass = 1
func post_import(obj):
	obj.set_meta("ass","TESTING")
	print(obj.get_meta("ass"))
	
	return obj
