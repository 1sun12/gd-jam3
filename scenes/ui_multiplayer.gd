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

# called only from clients
func connection_failed():
	print("Connection failed!")

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
	pass # Replace with function body.
