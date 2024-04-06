extends Node

## Board
signal BOARD_CELL_SELECTED(cell: Vector3i, button_index: int)
signal BOARD_CELL_HOVERED(cell: Vector3i)


## Entity

signal ENTITY_SELECTED(entity: Entity3D)


## Turn

signal ENTITY_TURN_STARTED(entity: Entity3D)
signal ENTITY_TURN_ENDED(entity: Entity3D)
signal ENTITY_TURN_TIME_PASSED(time: float)


## Movement
signal ENTITY_COMPONENT_MOVEMENT_MOVED(entity: Entity3D, old_cell: Vector3i, cell: Vector3i)


## Interface
signal ENTITY_COMPONENT_INTERFACE_AUTO_UPDATE_ENABLED(comp: ComponentInterface)


## Status
signal ENTITY_COMPONENT_STATUS_METER_CHANGED(comp: ComponentStatus, meter: String, old_value: int, new_value: int)
signal ENTITY_COMPONENT_STATUS_PASSIVE_ADDED(comp: ComponentStatus, passive: ComponentPassiveResource)
signal ENTITY_COMPONENT_STATUS_PASSIVE_REMOVED(comp: ComponentStatus, passive: ComponentPassiveResource)


## Action
signal ENTITY_COMPONENT_ACTION_TARGETED_CELL(culprit: Entity3D, cells: Array[Vector3i], action: ComponentActionResource)
signal ENTITY_COMPONENT_ACTION_USED_ON_CELL(culprit: Entity3D, cells: Array[Vector3i], action: ComponentActionResource)


## Stack
signal ENTITY_COMPONENT_STACK_ADDED(stack_object: ComponentStack.StackObject)
