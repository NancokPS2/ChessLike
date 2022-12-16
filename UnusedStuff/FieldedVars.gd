extends Node
#References
var fieldReference: Object #A permanent reference to the main combat field

var fieldedUnitList: Array #All units in the field

var selectedUnitReference: Object #Unit currently selected, mostly used for UI stuff

var turnOwnerReference: Object #Unit who's currently taking their turn

#Temp
var selectedUnitID
var hoveredUnitID

#Information
var confirmText: String


#Targeting
var unitTargeting: Object
var unitTargets: Array


#Misc
var combatStage: int #0 = preparations, 1 = combat, 2 = end screen

var combatState: int #0 = nothing is happening; 1 = targeting


