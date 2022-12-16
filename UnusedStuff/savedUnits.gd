extends Node

var availableUnits = [0,1,2]

var pUnitList = [{
	"ID": 0,
	"name": "John",
	"spriteName": "stickman1",
	"race": 0,
	"class": 0,
	"HPBonus": 0,
	"stat1Bonus":0,
	"stat2Bonus":0,
	"stat3Bonus":0,
	"stat4Bonus":0
	},
	{
	"name": "Pancho",
	"ID": 1,
	"spriteName": "stickman1",
	"race": 0,
	"class": 0,
	"HPBonus": 0,
	"stat1Bonus":0,
	"stat2Bonus":0,
	"stat3Bonus":0,
	"stat4Bonus":0
	},
	{
	"name":"Pincho",
	"ID": 2,
	"spriteName": "stickman1",
	"race": 0,
	"class": 0,
	"HPBonus": 0,
	"stat1Bonus":0,
	"stat2Bonus":0,
	"stat3Bonus":0,
	"stat4Bonus":0
	},
	{
	"name": "Caco",
	"ID": 3,
	"spriteName": "stickman2",
	"race": 0,
	"class": 0,
	"HPBonus": 0,
	"stat1Bonus":0,
	"stat2Bonus":0,
	"stat3Bonus":0,
	"stat4Bonus":0
	}
	]


# List of units in combat

var equipSlots = ["Main Hand","Off Hand","Armor","Trinket1","Trinket2","Trinket3"]
var p_unit1Equip = []


var e_unit1 = ["Rodilla",0,1,100,80,60,40]
var enemyList = [e_unit1]
