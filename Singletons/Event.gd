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
signal ENTITY_MOVEMENT_MOVED(entity: Entity3D, old_cell: Vector3i, cell: Vector3i)


## Interface
signal ENTITY_INTERFACE_ACTION_SELECTED(comp: ComponentInterface, action: ComponentActionResource)


## Status
signal ENTITY_STATUS_METER_CHANGED(comp: ComponentStatus, meter: String, old_value: int, new_value: int)


## Action
signal ENTITY_ACTION_QUEUED_LOGS(logs_queued: Array[ComponentActionEffectLog], index: int)


## Stack
signal ENTITY_STACK_ADDED(stack_object: ComponentStack.StackObject)
signal ENTITY_STACK_EXECUTING(stack_arr: Array[ComponentStack.StackObject])
