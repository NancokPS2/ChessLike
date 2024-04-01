extends Node

## Board

signal BOARD_CELL_SELECTED(cell: Vector3i, button_index: int)
signal BOARD_CELL_HOVERED(cell: Vector3i)


## Entity

signal ENTITY_MOVED(entity: Entity3D, old_cell: Vector3i, cell: Vector3i)

signal ENTITY_SELECTED(entity: Entity3D)

signal ENTITY_TURN_STARTED(entity: Entity3D)
signal ENTITY_TURN_ENDED(entity: Entity3D)


## Interface

signal ENTITY_COMPONENT_INTERFACE_AUTO_UPDATE_ENABLED(comp: ComponentInterface)


## Status

signal ENTITY_COMPONENT_STATUS_METER_CHANGED(comp: ComponentStatus, meter: String, old_value: int, new_value: int)


## Action

signal ENTITY_COMPONENT_ACTION_TARGETED_CELL(culprit: Entity3D, cells: Array[Vector3i], action: ComponentActionResource)
signal ENTITY_COMPONENT_ACTION_USED_ON_CELL(culprit: Entity3D, cells: Array[Vector3i], action: ComponentActionResource)


