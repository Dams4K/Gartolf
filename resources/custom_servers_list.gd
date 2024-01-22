class_name CustomServers
extends Resource

signal server_added(index: int)
signal test

const PATH = "user://custom_servers.res"

@export var servers: Array[Dictionary] = []

func add_server(ip: String, port: int):
	servers.append({
		"ip": ip,
		"port": port
	})
	server_added.emit(len(servers)-1)
	save()

func get_server_nodes() -> Array[ServerDiscovered]:
	var nodes: Array[ServerDiscovered] = []
	for i in range(len(servers)):
		nodes.append(get_server_node(i))
	
	return nodes

func get_server_node(index: int) -> ServerDiscovered:
	var server_data = servers[index]
	var node = ServerDiscovered.new(server_data.ip)
	node.server_data = RServerData.new()
	node.server_data.port = server_data.port
	node.name = node.get_id()
	
	return node

static func setup() -> CustomServers:
	if ResourceLoader.exists(PATH):
		return ResourceLoader.load(PATH)
	return CustomServers.new()

func save():
	ResourceSaver.save(self, PATH)
