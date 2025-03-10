extends Node2D

@export var player_knight: PackedScene

func _ready():
	var index = 0
	# loop through all connected players
	for i in Global.players:
		# create the player
		var curr_player = player_knight.instantiate()
		# set the name of the player to a unique id
		curr_player.name = str(Global.players[i].id)
		# add player as child to the root scene
		add_child(curr_player)
		# spawn that player in the right spot on the map
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(index):
				curr_player.global_position = spawn.global_position
		index += 1
		
