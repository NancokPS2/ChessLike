extends Node


## Entity signals

signal ENTITY_MOVED(entity: Entity3D, cell: Vector3i)

signal ENTITY_SELECTED(entity: Entity3D)

signal ENTITY_TURN_STARTED(entity: Entity3D)
signal ENTITY_TURN_ENDED(entity: Entity3D)


## Board signals

signal BOARD_CELL_SELECTED(cell: Vector3i)


