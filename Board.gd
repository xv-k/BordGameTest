extends Node2D

@onready var tile_map = $TileMap

var board_size = 4
#enum layers{hidden, revealed}
#var atlas_source_num = 1
#var hidden_alt_num = 1
#var atlas_tile_coords = Vector2.ZERO
#var hidden_tile_coords = Vector2(6,2)
#var revealed_spots =[]
#var tile_pos_to_atlas_position = {}
#var score = 0
#var turns_taken = 0
#
# Called when the node enters the scene tree for the first time.
func _ready():
	setup_board()
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
#
#func get_tiles_to_use():
	#var chosen_tile_chords = []
	#var options = range(10)
	#options.shuffle()
	#for i in range(board_size * (board_size/2)):
			#var current = Vector2(options.pop_back(),1)
			#for j in range(2):
				#chosen_tile_chords.append(current)
	#chosen_tile_chords.shuffle()
	#return chosen_tile_chords
#
func setup_board():
	#var cards_to_use = get_tiles_to_use()
	for y in range(board_size):
		for x in range(board_size):
			var current_spot = Vector2(x, y)
			place_single_face_down_card(current_spot)
			#var card_atlas_coords = cards_to_use.pop_back()
			#tile_pos_to_atlas_position[current_spot] = card_atlas_coords
			#tile_map.set_cell(layers.revealed, current_spot, 
						#atlas_source_num, card_atlas_coords)
						#
func place_single_face_down_card(coords: Vector2):
	#set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
	tile_map.set_cell(0, coords, 1, Vector2(6,2), 0)
#
#func set_cell():
	#pass
#
func _input(event):
	if Input.is_action_just_pressed("turn_tile"):
		var pos_clicked = Vector2(tile_map.local_to_map(event.position))
		print(pos_clicked)
		prints("click", event.position)
		tile_map.set_cell(0, pos_clicked, 1, Vector2(5,2), 0)
	#
