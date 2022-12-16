extends Node
 
var unitInAction:Unit #Unit currently taking a turn
var unitSelected:Node #Unit currently trying to interact with
var unitHovered:Node

var mainNode:Node #Main node of the combat scene

var mainCamera:Node#Camera of the battlefield



var unitsInBattle:Array #Units in battle

var unitsBenched:Array #Units that are not participating

var combatGrid:MovementGrid #Combat field

var UITree:CanvasLayer #The UI




var debugRef
