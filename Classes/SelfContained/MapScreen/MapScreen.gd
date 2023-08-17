extends TextureRect
class_name MapScreen

const DEFAULT_SAVE_PATH:String = "user://MapScreenMarkers.mapscreen"
const FILE_EXTENSION:String = "mapscreen"

signal marker_selected(marker:MapScreenMarker)
signal marker_selected_data(variant)
signal marker_selected_string(string:String)

signal marker_added(marker:MapScreenMarker)
signal marker_deleted(marker:MapScreenMarker)

#signal marker_disabled(marker:MapScreenMarker)
#signal marker_enabled(marker:MapScreenMarker)



#var markerRefs:Array[MapScreenMarker]
var markerRefs:Dictionary
var editorRef:MapScreenEditor:
	set(val):
		editorRef = val
		if editorRef is MapScreenEditor:
			editorRef.connect_to_map_screen(self)

@export_category("Actions")
@export var selectionAction:StringName = "ui_select"
@export var deletionAction:StringName = "ui_cancel"
@export var additionAction:StringName = "ui_accept"

@export_category("Editor")
@export var editorEnabled:bool = true
@export var editorHolder:Control

@export_category("Marker Appereance")
@export var defaultTexture:Texture
@export var defaultMinSize:=Vector2.ZERO
@export var defaultHoverModulate:Color = Color.WHITE * 1.2
@export var connectionLineColor:Color = Color.RED
@export var connectionLineWidth:float = 2
@export var connectionLineDash:float = 4

#func _ready() -> void:
#	for markerData in storedMarkers:
##		var markerAdded:MapScreenMarker = add_marker(markerData[0],markerData[1],markerData[2],load(markerData[3]))
#		var markerAdded:MapScreenMarker = add_marker(
#			markerData[STORED_MARKER_STRUCTURE.POSITION],
#			markerData[STORED_MARKER_STRUCTURE.IDENTIFIER],
#			markerData[STORED_MARKER_STRUCTURE.STORED_STRING],
#			markerData[STORED_MARKER_STRUCTURE.MIN_SIZE],
#			load(markerData[STORED_MARKER_STRUCTURE.TEXTURE])
#		)
#		markerAdded.disable

func _init() -> void:
	var redrawFunc:=func(_marker): queue_redraw()
	marker_added.connect(redrawFunc)
	marker_deleted.connect(redrawFunc)
	
func _ready() -> void:
	if editorEnabled:
		editorRef = MapScreenEditor.new()
		

func _draw() -> void:
	update_connection_visuals()

func get_markers()->Array[MapScreenMarker]:
	var ret:Array[MapScreenMarker] = []
	ret.assign(markerRefs.values())
	return ret

func add_marker(marker:MapScreenMarker, where:Vector2):
	if not marker.texture is Texture: marker.texture = defaultTexture
	
	marker.position = where
	
	marker.gui_input.connect(on_marker_gui_input.bind(marker))
	
	marker.mouse_entered.connect(on_marker_hovered.bind(marker, true))
	marker.focus_entered.connect(on_marker_hovered.bind(marker, true))
	
	marker.mouse_exited.connect(on_marker_hovered.bind(marker, false))
	marker.focus_exited.connect(on_marker_hovered.bind(marker, false))
	
	markerRefs[marker.identifier] = marker
	
	marker_added.emit(marker)
	
	add_child(marker)
	

	pass
	
func remove_marker(marker:MapScreenMarker):
	remove_child(marker)
	markerRefs.erase(marker)
	marker.queue_free()

func remove_marker_by_identifier(identifier:String):
	remove_marker(markerRefs[identifier])
	
	
func enable_marker(marker:MapScreenMarker, enabled:bool):
	if enabled:
		marker.enable()
	else:
		marker.disable()
		
func enable_marker_by_identifier(identifier:String, enabled:bool):
	enable_marker(markerRefs[identifier], enabled)

func get_marker_by_identifier(identifier:String)->MapScreenMarker:
	return markerRefs[identifier]

func connect_marker_to(marker:MapScreenMarker, targetMarker:MapScreenMarker):
	marker.connectedTo.append(targetMarker.identifier)
	pass

func connect_marker_to_by_identifier(markerIdent:String, targetIdent:String):
	connect_marker_to(get_marker_by_identifier(markerIdent),get_marker_by_identifier(targetIdent))

func disconnect_marker_from(marker:MapScreenMarker, targetMarker:MapScreenMarker):
	if not marker.connectedTo.has(targetMarker.identifier): push_error("These markers are not connected.")
	marker.connectedTo.erase(targetMarker.identifier)
	pass

func disconnect_marker_from_by_identifier(markerIdent:String, targetIdent:String):
	disconnect_marker_from(get_marker_by_identifier(markerIdent),get_marker_by_identifier(targetIdent))

func update_connection_visuals():
	for marker in markerRefs.values():
		for identifier in marker.connectedTo:
			draw_dashed_line(marker.get_rect().get_center(),
			 get_marker_by_identifier(identifier).get_rect().get_center(),
			 connectionLineColor, connectionLineWidth, connectionLineDash)

	
func on_marker_gui_input(event:InputEvent, marker:MapScreenMarker):
	if event.is_action_pressed(selectionAction): 
		marker_selected.emit(marker)
		marker_selected_data.emit(marker.customData)
		marker_selected_string.emit(marker.stringData)
		
	elif event.is_action_pressed(deletionAction):  
		remove_marker(marker)
		marker_deleted.emit(marker)
	
func on_marker_hovered(marker:MapScreenMarker, hovered:bool):
	if hovered:
		marker.modulate = defaultHoverModulate
	else:
		marker.modulate = Color.WHITE

func connect_marker_to_marker():
	pass



#const STORED_MARKER_KEYS:Array[String] = ["POSITION", "IDENTIFIER", "STORED_STRING", "MIN_SIZE", "TEXTURE", "DISABLED", "DISABLED_TEXTURE", "CONNECTED_TO"]
func save_markers(path:String=DEFAULT_SAVE_PATH, markers:Array[MapScreenMarker]=get_markers()):
	if markers.is_empty(): push_warning("There are no markers to save.")
	
	var configFile:=ConfigFile.new()
	for marker in markers:
		for propertyName in MapScreenMarker.SAVABLE_PROPERTIES:
			configFile.set_value(marker.identifier, propertyName, marker.get(propertyName))
	
	configFile.save(path)

func load_markers(path:String=DEFAULT_SAVE_PATH, preClear:bool=true):
	if preClear:
		for identifier in markerRefs:
			remove_marker(get_marker_by_identifier(identifier))
	
	if path.get_extension() != FILE_EXTENSION: push_warning("The file extension ({0}) is different from the expected one ({1})".format([path.get_extension(),FILE_EXTENSION]))
	
	var markersLoaded:Array[MapScreenMarker] = []
	var configFile:=ConfigFile.new()
	var errorCode:int = configFile.load(path)
	if errorCode != OK: push_error("Failed to load file with code " + str(errorCode)); return []
	
	assert(not configFile.get_sections().is_empty())
#	assert(configFile.get_section_keys(configFile.get_sections()[0]).size() == MapScreenMarker.SAVABLE_PROPERTIES.size(), "There is a discrepancy in the amount of keys saved." )
	
	for identifier in configFile.get_sections():
		var newMarker:=MapScreenMarker.new()
		for propertyName in MapScreenMarker.SAVABLE_PROPERTIES:
			newMarker.set(propertyName, configFile.get_value(identifier, propertyName, null))
			
#		var markPos:Vector2 = configFile.get_value(identifier, STORED_MARKER_KEYS[0])
#		var markIdent:String = configFile.get_value(identifier, STORED_MARKER_KEYS[1])
#		var markString:String = configFile.get_value(identifier, STORED_MARKER_KEYS[2])
#		var markMinSize:Vector2 = configFile.get_value(identifier, STORED_MARKER_KEYS[3])
#		var markTex:Texture = configFile.get_value(identifier, STORED_MARKER_KEYS[4])
#		var markDisabled:bool = configFile.get_value(identifier, STORED_MARKER_KEYS[5])
#		var markDisabledTex:Texture = configFile.get_value(identifier, STORED_MARKER_KEYS[6])
#		var markConnect:Array[String] = configFile.get_value(identifier, STORED_MARKER_KEYS[7])
		
#		var newMarker:MapScreenMarker = add_marker(markPos, markIdent, markString, markMinSize, markTex)
#		newMarker.isDisabled = markDisabled
#		newMarker.disabledTexture = markDisabledTex
#		newMarker.connectedTo = markConnect
		markersLoaded.append(newMarker)
		
	for marker in markersLoaded:
		add_marker(marker, marker.position)

class MapScreenMarker extends TextureRect:
	
	signal disabled(me:MapScreenMarker)
	signal enabled(me:MapScreenMarker)
	
	const META_LABEL_REF:String = "LABEL_REFERENCE"
	const SAVABLE_PROPERTIES:Array[String] = [
		"position",
		"identifier",
		"displayText",
		"stringData",
		"custom_minimum_size",
		"normalTexture",
		"isDisabled",
		"disabledTexture",
		"connectedTo",
		"customData",
		"metaData"
		]
	
	
	static var defaultTexture:Texture
	
	var identifier:String
	var displayText:String
	var isDisabled:bool
	var stringData:String
	var customData
	var disabledTexture:Texture
	var connectedTo:Array[String]
	var normalTexture:Texture
	
	var metaData:Dictionary
	static func construct(_identifier:String, _displayText:String="Unnamed", _normalTexture:Texture=null, _custom_minimum_size:=Vector2.ZERO)->MapScreenMarker:
		var marker := MapScreenMarker.new()
		
		marker.normalTexture = _normalTexture
		marker.texture = marker.normalTexture
		
		marker.custom_minimum_size = _custom_minimum_size	
		marker.identifier = _identifier
		marker.displayText = _displayText

		return marker

	func _init() -> void:
		enable()
	
	func _ready() -> void:
		#If no normalTexture has been set, use whatever is the current one when readied.
		if not normalTexture is Texture and texture is Texture and texture != disabledTexture:
			normalTexture = texture
		
		#If there is text to display, add a label for it.
		if displayText:
			update_label(displayText)
	
	func disable():
		if not isDisabled: return
		
		if disabledTexture is Texture: texture = disabledTexture
			
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		focus_mode = Control.FOCUS_NONE
		
		isDisabled = true
		disabled.emit(self)
			
	func enable():
		if not isDisabled: return
		
		texture = normalTexture
		
		mouse_filter = Control.MOUSE_FILTER_PASS
		focus_mode = Control.FOCUS_ALL
		
		isDisabled = false
		enabled.emit(self)

	func toggle():
		if isDisabled:
			enable()
		else:
			disable()

	
	func update_label(withText:String):
		#If it already exists, update it
		if get_meta(META_LABEL_REF, false) is Label:
			get_meta(META_LABEL_REF).text = withText
			
		#If not, create it
		else:
			var label:=Label.new()
			label.set_anchors_preset(PRESET_FULL_RECT)
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.text = withText
			
			set_meta(META_LABEL_REF, label)
			add_child(label)
	
#	signal selected(me:MapScreenMarker)
#	signal deleted(me:MapScreenMarker)
#
#	var selectAct:StringName
#	var deleteAct:StringName
	
#	func _gui_input(event: InputEvent) -> void:
#		if event.is_action_pressed(selectAct): 
#			selected.emit(self)
#		elif event.is_action_pressed(deleteAct):  
#			deleted.emit(self)
		
class MapScreenEditor extends Node:
	var mapScreen:MapScreen:
		set = connect_to_map_screen
		
	var hudParent:Control
	var UIRef:=VBoxContainer.new()
	var scrollContRef:=ScrollContainer.new()
	var markerSelected:MapScreenMarker
	
	var savePrompt:=FileDialog.new()
	var loadPrompt:=FileDialog.new()
	var resDirCheck:=CheckButton.new()
	var switchSide:=Button.new()
	
	
	func setup() -> void:
		scrollContRef.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		savePrompt.access = FileDialog.ACCESS_FILESYSTEM
		savePrompt.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		savePrompt.file_selected.connect(mapScreen.save_markers)
		
		loadPrompt.access = FileDialog.ACCESS_FILESYSTEM
		loadPrompt.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		loadPrompt.file_selected.connect(mapScreen.load_markers)
		
		resDirCheck.text = "Use res:// directory. (EDITOR ONLY)"
		var toggleAccessFunc:=func(button:CheckButton):
			if button.button_pressed:
				loadPrompt.root_subfolder = "res://"
				savePrompt.root_subfolder = "res://"
			else:
				loadPrompt.root_subfolder = "user://"
				savePrompt.root_subfolder = "user://"
		resDirCheck.pressed.connect(toggleAccessFunc.bind(resDirCheck))
		
		switchSide.text = "Move to other side."
		var moveUIFunc:=func():
			if UIRef.anchor_left == 0:
				UIRef.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
			else:
				UIRef.set_anchors_preset(Control.PRESET_LEFT_WIDE)
		switchSide.pressed.connect(moveUIFunc)
		
		
		UIRef.add_child(savePrompt, false, Node.INTERNAL_MODE_BACK)
		UIRef.add_child(loadPrompt, false, Node.INTERNAL_MODE_BACK)
		UIRef.add_child(resDirCheck, false, Node.INTERNAL_MODE_BACK)
		UIRef.add_child(switchSide, false, Node.INTERNAL_MODE_BACK)
	
	func update_hud(marker:MapScreenMarker):
		#Correctly parent the hud
		assert(UIRef is Control)
		if scrollContRef.get_parent() == null: hudParent.add_child(scrollContRef)
		elif scrollContRef.get_parent() != hudParent: scrollContRef.get_parent().remove_child(UIRef); hudParent.add_child(scrollContRef)
		
		if UIRef.get_parent() != scrollContRef: scrollContRef.add_child(UIRef)
		
		#Clean it
		for child in UIRef.get_children(): child.queue_free()
		
		#Add the fields
		for propertyName in MapScreenMarker.SAVABLE_PROPERTIES:
			var newField:=LineEdit.new()
			newField.set_anchors_preset(Control.PRESET_FULL_RECT)
			
			#Set the property name
			newField.placeholder_text = propertyName
			
			#Set the text
			if marker.get(propertyName) is String:
				newField.text = marker.get(propertyName)
				
			elif marker.get(propertyName) == null:
				newField.text = ""
			
			else:
				newField.text = str( marker.get(propertyName) )
				
			#Connect it
			newField.text_submitted.connect(set_marker_property.bind(newField))
			
			#Add it
			UIRef.add_child(newField)
		
		
	
	func set_marker_property(newText:String, lineEdit:LineEdit):
		var propertyName:String = lineEdit.placeholder_text
		var value = markerSelected.get(propertyName)
		var propertyType:Variant.Type = typeof(value)
		
		match propertyType:
			TYPE_INT:
				value = newText.to_int()
				
			TYPE_VECTOR2:
				value = Vector2(newText.get_slice(",",0).lstrip("(").to_float(), newText.get_slice(",",1).to_float())
				mapScreen.queue_redraw()
				lineEdit.update_minimum_size()
			
			
		
		markerSelected.set(propertyName, value)
		pass
	
	func connect_to_map_screen(_mapScreen:MapScreen):
		mapScreen = _mapScreen
		hudParent = mapScreen.editorHolder
		mapScreen.gui_input.connect(on_map_screen_input)
		mapScreen.marker_selected.connect(on_marker_selected)
		setup()
		
	func on_map_screen_input(event:InputEvent):
		
		if event.is_action_pressed(mapScreen.additionAction):
			var identifier:String = "DEFAULT"
			while mapScreen.markerRefs.has(identifier): identifier+="_"
			
			var marker:=MapScreenMarker.construct(identifier)
			
			mapScreen.add_marker(marker, mapScreen.get_local_mouse_position())
			
			
	func on_marker_selected(marker:MapScreenMarker):
		update_hud(marker)
		markerSelected = marker
		pass

