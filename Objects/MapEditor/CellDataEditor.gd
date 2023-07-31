extends VBoxContainer
class_name CellDataEditor

@export var gridMap:GridMap
@export var mapUsed:Map

@export var applyButton:Button
@export var useMarkersCheck:CheckBox

@export_category("Fields")
@export var coordinateX:LineEdit
@export var coordinateY:LineEdit
@export var coordinateZ:LineEdit

@export var tags:LineEdit

var currentCell:Cell

#func _ready() -> void:
#	tags.text_submitted.connect(update_cell)
	

func get_cell_from_pos(pos:Vector3i)->Cell:
	var cellDict := mapUsed.get_pos_to_cell_dictionary()
	return cellDict[pos]
	
func load_cell(cell:Cell):
	currentCell = cell
	
	coordinateX.text = str(currentCell.position.x)
	coordinateY.text = str(currentCell.position.y)
	coordinateZ.text = str(currentCell.position.z)
	
	for tag in currentCell.tags:
		tags.text += tag + ","

func update_cell(cell:Cell=currentCell):
	if not currentCell is Cell: push_error("No cell has been selected."); return
	var tagsDetected:Array[StringName] 
	tagsDetected.assign( tags.text.split(",",false) )
	cell.tags = tagsDetected
	
func save_map(path:String):
	var newMap:=Map.new()
	
	
	
