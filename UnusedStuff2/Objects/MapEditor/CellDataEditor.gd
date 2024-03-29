extends VBoxContainer
class_name CellDataEditor

@export var applyButton:Button
@export var useMarkersCheck:CheckBox

@export_category("Fields")
@export var coordinateX:LineEdit
@export var coordinateY:LineEdit
@export var coordinateZ:LineEdit

@export var tags:LineEdit
@export var tileID:LineEdit

var currentCell:Cell
	
func load_cell(cell:Cell):
	currentCell = cell
	if not currentCell is Cell:
		coordinateX.text = ""
		coordinateY.text = ""
		coordinateZ.text = ""
		tileID.text = ""
		tags.text = ""
		return
		
	coordinateX.text = str(currentCell.position.x)
	coordinateY.text = str(currentCell.position.y)
	coordinateZ.text = str(currentCell.position.z)
	
	tileID.text = str(currentCell.tileID)
	
	for tag in currentCell.tags:
		tags.text = tag + ","


	

func update_cell(cell:Cell=currentCell):
	if not currentCell is Cell: push_error("No cell has been selected."); return
	var tagsDetected:Array[StringName] 
	tagsDetected.assign( tags.text.split(",",false) )
	cell.tags = tagsDetected
	cell.tileID = int(tileID.text)

	
func validate_tile_id(text:String):
	if not text.is_valid_int(): tileID.text = ""
	pass
	
	
