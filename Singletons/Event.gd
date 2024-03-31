extends Node

## Board signals

signal BOARD_CELL_SELECTED(cell: Vector3i, button_index: int)
signal BOARD_CELL_HOVERED(cell: Vector3i)


## Entity signals

signal ENTITY_MOVED(entity: Entity3D, cell: Vector3i)

signal ENTITY_SELECTED(entity: Entity3D)

signal ENTITY_TURN_STARTED(entity: Entity3D)
signal ENTITY_TURN_ENDED(entity: Entity3D)


## Interface component signals

signal ENTITY_COMPONENT_INTERFACE_AUTO_UPDATE_ENABLED(comp: ComponentInterface)




## Action signals

signal ENTITY_COMPONENT_ACITON_TARGETED_CELL(culprit: Entity3D, target: Vector3i, action: ComponentActionResource)
signal ENTITY_COMPONENT_ACITON_USED_ON_CELL(culprit: Entity3D, target: Vector3i, action: ComponentActionResource)


