extends Control

@export var address = "127.0.0.1"
@export var port = 135
var peer
var error

func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_connected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

# gets called on server and client when someone connects
func player_connected(id):
	print("Player connected: " + str(id))
	
# gets called on server and clients when someone disconnects
func player_disconnected(id):
	print("Player Disconnected: " + str(id))

# called only from clients
func connected_to_server():
	print("Connected to server!")
	send_player_info.rpc_id(1, %LineEdit.text, multiplayer.get_unique_id())

# called only from clients
func connection_failed():
	print("Connection failed!")
	
# keep a synchronized list of all connected players and their ids across all peers
@rpc("any_peer")
func send_player_info(name, id):
	# if the global var. players does not have this player id...
	if !Global.players.has(id):
		# add that player name and id to their local list on that peer
		# storing information as an object
		Global.players[id] = {
			"name" : name,
			"id" : id,
			"score" : 0			
		}
	
	# if this peer is the server, go ahead and update this information for all connected clients
	if multiplayer.is_server():
		# loop through all players in the global array
		for i in Global.players:
			send_player_info.rpc(Global.players[i].name, i)
	
# load the game scene for all connected clients
@rpc("any_peer", "call_local")
func start_game():
	# load the game scene
	var game_scene = load("res://scenes/game.tscn").instantiate()
	# add it as a child to the root tree
	get_tree().root.add_child(game_scene)
	# hide this UI menu overlay
	self.hide()

# creates a host peer to connect to
func _on_host_button_down():
	# create a new peer; the host
	peer = ENetMultiplayerPeer.new()
	# attempt to host on this peer, given port number and max players
	error = peer.create_server(port, 2)
	# error checking, in case it couldn't host for some reason, print the error
	if error != OK:
		print("Cannot host: " + error)
		return
	# choose a compression algo. helps with bandwidth usage
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	# now that the computer is ready to host, pass the peer as the host object
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")
	send_player_info(%LineEdit.text, multiplayer.get_unique_id())

func _on_join_button_down():
	# create a new peer; the client
	peer = ENetMultiplayerPeer.new()
	# configure this peer to be a client
	peer.create_client(address, port)
	# configure the compression algo
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	# set yourself (the client) as the multiplayer peer
	multiplayer.set_multiplayer_peer(peer)

func _on_start_game_button_down():
	# call start game, for all clients (rpc)
	start_game.rpc()
