class_name PlayerInfo
extends Resource

const PATH: String = "user://player.res"

var PSEUDOS: Array[StringName] = [
	"Grimdal",
	"Raptor",
	"PetiteFée",
	"Pewfan",
	"Seltade",
	"Kairrin",
	"Potaaato",
	"Neptendus",
	"RainbowMan",
	"Exominiate",
	"Meyriu",
	"Ectobiologiste",
	"ItsGodHere",
	"MaxMadMen",
	"TankerTanker",
	"Felipero",
	"TheFlyingBat",
	"JustEpic",
	"LeGrandBlond",
	"Azalee",
	"OarisKiller",
	"LeHamster",
	"Dialove",
	"Frexs",
	"Rofaly",
	"GeoMan",
	"Kirna",
	"Gruty",
	"Fridame",
	"Fluxy",
	"Drastics",
	"Grimace",
	"Viiper",
	"xXSerpentXx",
	"Cristobal",
	"Scubrina",
	"Xanoneq",
	"McTimley",
	"LittleDank",
	"Rocketman"
]

@export var name: String = ""
var placeholder_name: String

func _init(data: Dictionary = {}) -> void:
	randomize()
	PSEUDOS.shuffle()
	self.placeholder_name = PSEUDOS[0]
	
	if not data.is_empty():
		self.name = data.get("name", "")


static func setup() -> PlayerInfo:
	if ResourceLoader.exists(PATH):
		return ResourceLoader.load(PATH)
	return PlayerInfo.new()


func get_player_name() -> String:
	return name if not name.is_empty() else placeholder_name


func save() -> void:
	ResourceSaver.save(self, PATH)


func to_dict() -> Dictionary:
	return {
		"name": self.get_player_name()
	}
