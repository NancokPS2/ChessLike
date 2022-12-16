extends Node

#Types
var roleStats = [{
		"className":"Civilian",
		"HPMaxMod":0.9,
		"energyMaxMod":0.9,
		"stat1Mod":0.9,
		"stat2Mod":0.9,
		"stat3Mod":0.9,
		"moveMod":0,
		"evasionMod":1,
		"accuracyMod":1,
		"turnDelayMod":1,
		"_comment": ""
		},
		{
		"className":"Paladin",
		"HPMaxMod":2,
		"energyMaxMod":0.7,
		"stat1Mod":1.2,
		"stat2Mod":0.8,
		"stat3Mod":1,
		"moveMod":0,
		"evasionMod":1,
		"accuracyMod":1,
		"turnDelayMod":1,
		"_comment": ""
		},
		{
		"className":"Ranger",
		"HPMaxMod":1,
		"energyMaxMod":0.5,
		"stat1Mod":0.8,
		"stat2Mod":1.5,
		"stat3Mod":0.6,
		"moveMod":0,
		"evasionMod":1,
		"accuracyMod":1,
		"turnDelayMod":1,
		"_comment": ""
		},
		{
		"className":"Thief",
		"HPMaxMod":0.9,
		"energyMaxMod":0.9,
		"stat1Mod":1,
		"stat2Mod":1.6,
		"stat3Mod":1,
		"moveMod":0,
		"evasionMod":1,
		"accuracyMod":1,
		"turnDelayMod":1,
		"_comment": ""
		},
		{
		"className":"Juggernaut",
		"HPMaxMod":2.3,
		"energyMaxMod":0.3,
		"stat1Mod":1.4,
		"stat2Mod":1.1,
		"stat3Mod":0.3,
		"moveMod":0,
		"evasionMod":1,
		"accuracyMod":1,
		"turnDelayMod":1,
		"_comment": ""
		},
		{
		"className":"Artillerist",
		"HPMaxMod":0.8,
		"energyMaxMod":0.6,
		"stat1Mod":0.8,
		"stat2Mod":1.2,
		"stat3Mod":0.6,
		"moveMod":0,
		"evasionMod":1,
		"accuracyMod":1,
		"turnDelayMod":1,
		"_comment": ""
		},
		{
		"className":"Leader",
		"HPMaxMod":1.2,
		"energyMaxMod":1.2,
		"stat1Mod":0.8,
		"stat2Mod":0.9,
		"stat3Mod":0.8,
		"moveMod":0,
		"evasionMod":1,
		"accuracyMod":1,
		"turnDelayMod":1,
		"_comment": ""
		}
	]

var racialStats = [{
		"name":"Human",
		"description":"An average human, widely known and hard to define.",
		"HPMax":100,
		"move":3,
		"energyMax":26,
		"stat1":105,
		"stat2":105,
		"stat3":105
		},
		{
		"name":"Poxt",
		"description":"Small yet hardy winged creatures.",
		"move":2,
		"HPMax":150,
		"energyMax":25,
		"stat1":70,
		"stat2":110,
		"stat3":115
		},
		{
		"name":"Arathi",
		"description":"Folk made out of stone, often dubbed 'living statues'.",
		"move":3,
		"HPMax":120,
		"energyMax":20,
		"stat1":110,
		"stat2":90,
		"stat3":100
		},
		{
		"name":"Vivistar",
		"description":"Full of the fire of stars, or something like that.",
		"move":3,
		"HPMax":95,
		"energyMax":30,
		"stat1":110,
		"stat2":90,
		"stat3":100
		},
		{
		"name":"Mantada",
		"description":"Clumsy and scrawny goblinoids with a will of steel.",
		"HPMax":125,
		"move":3,
		"energyMax":25,
		"stat1":100,
		"stat2":90,
		"stat3":120
		}
	]
	

