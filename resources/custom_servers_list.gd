class_name CustomServers
extends Resource

const PATH = "user://custom_servers.res"

@export var servers: Array[RServerData] = []

func add_server(address: String, port: int):
	var server_data = RServerData.new()
	server_data.address = address
	server_data.port = port
	self.servers.append(server_data)
	save()

func get_servers() -> Array[RServerData]:
	return self.servers

static func setup() -> CustomServers:
	if ResourceLoader.exists(PATH):
		return ResourceLoader.load(PATH)
	return CustomServers.new()

func save():
	ResourceSaver.save(self, PATH)
