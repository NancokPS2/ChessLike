extends VBoxContainer
class_name NestedMenu
## Stores sets of Control nodes in a dictionary, allowing you to change between them.

## BUttons that will be automatically generated, which can allow you to travel around the menus.
## Each element is made out of Arrays with the following format: ["Menu where the button goes", "Menu where it leads to"]
@export var navigationButtons:Array[Array] #[ [MenuWhereTheButtonIsPlaced,WhereTheButtonLeads] ]
	
## If this node hsa Control nodes, they will be considered a menu (with the menu's name being the children's node) and the children will be part of said menu
@export var autoStripChildControls:bool=true

## When true, automatically creates a back button to return to the previous menu.
## If there's no previous menu to return to, the button will not appear.
@export var autoAddBackButton:bool = true

var currentMenu:String

var menuStack:Array[String] = []

## Stores a pair of menu name and control node
@export var menus:Dictionary #String:Array[Control]
		

func _ready():
	if autoStripChildControls: 
		for child in self.get_children():
			if not child is Control: continue
			strip_from_parent(child, child.get_name(), true)	
	add_navigation_buttons()
	if not menus.is_empty(): change_current_menu(menus.keys()[0],true)

func reorder_buttons():
	for button in get_children():
		if button is NavigationButtonBack and menuStack.is_empty(): remove_child(button)
		elif button is NavigationButtonBack: move_child(button, -1)
		elif button is NavigationButton: move_child(button, 0)

func create_menu(menuName:String):
	menus[menuName]=[]
	#It is automatically added
	if autoAddBackButton: NavigationButtonBack.new(self,menuName)

func get_menus()->Array[String]:
	var returnal:Array[String]; returnal.assign(menus.keys())
	return returnal
	

## Takes all children from a control node and optionally removes it as well
func strip_from_parent(control:Control, toMenuName:String, removeParent:bool=false):
	if control.get_children().is_empty(): push_warning("This node has no children")
	create_menu(toMenuName)
	
	for child in control.get_children():
		if not child is Control: continue
		control.remove_child(child)
		add_to_menu(child, toMenuName)
	
	if removeParent: control.queue_free()



func add_to_menu(what:Control, menuName:String):
	if menuName == "": push_error("Menu name cannot be empty."); return
	if not menus.has(menuName): 
		create_menu(menuName)
	
	menus[menuName].append(what)


##SLOW! Scans each menu and removes the referenced control	
func remove_from_menu(what:Control):
	for menu in menus:
		menu.erase(what)

func clear_menu(menuName:String, includeNavigation:bool=false):
	if menus.has(menuName): 
		for control in menus[menuName]:
			assert(control is Control)
			if (control is NavigationButton or control is NavigationButtonBack) and not includeNavigation:
				continue
			else:
				menus[menuName].erase(control)
				
				
	else: push_warning(menuName + " does not exist.")
		
func delete_menu(menuName:String):
	menus.erase(menuName)


## Changes the current menu, if it's not going back, the menu that was just left is added to the stack
func change_current_menu(menuName:String, goingBack:bool=false):
	for child in get_children():
		remove_child(child)
		
	for control in menus[menuName]:
		add_child(control)
	
	if not goingBack:
		menuStack.append(currentMenu)
		
	currentMenu = menuName
	reorder_buttons()
	
	
func go_to_prev_menu():
	if not menuStack.is_empty() and menus.has(menuStack.back()):
		change_current_menu( menuStack.pop_back(), true )
	else: push_warning("There's no previous menu")
	
func add_navigation_buttons():
	for array in navigationButtons:
		NavigationButton.new(self,array[0],array[1])
		
class NavigationButtonBack extends Button:

	func _init(nestedMenu:NestedMenu, menuLocation:String):
		nestedMenu.add_to_menu(self,menuLocation)
		nestedMenu.move_child(self,-1)
		pressed.connect( Callable(nestedMenu, "go_to_prev_menu") )
		text = "Back"

class NavigationButton extends Button:
	var destination:String
	
	func _init(nestedMenu:NestedMenu, menuLocation:String, targetMenu:String):
		nestedMenu.add_to_menu(self,menuLocation)
		pressed.connect( Callable(nestedMenu, "change_current_menu").bind(targetMenu) )
		destination = targetMenu
		text = ">"+destination
		
