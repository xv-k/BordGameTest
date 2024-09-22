extends Node2D

@onready var tile_map = $TileMap

var board_x = 12
var board_y = 9
var color = 4
enum layers {white = 3, yellow, gray, green, blue, orange, purple, red, pink}
var building_positions = {}
var player_tile_pos = {0: Vector2(6,11), 1: Vector2(7,11), 2: Vector2(8,11), 3: Vector2(9,11), 4: Vector2(10,11), 5: Vector2(11,11)}
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
	print(building_positions)
	print(layers)
	get_first_tiles()
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

func get_first_tiles():
	var options = range(108)
	options.shuffle()
	var selection = []
	for i in range(6):
		selection.push_back(options.pop_back())
	print(selection)
	var loc = 0
	for j in selection:
		print(building_positions[j])
		place_selection_of_tiles(building_positions[j], player_tile_pos[loc])
		show_posibilities(building_positions[j])
		loc += 1
		
	
func setup_board():
	#var cards_to_use = get_tiles_to_use()
	var i = 0
	for y in range(board_y):
		for x in range(board_x):
			var current_spot = Vector2(x, y)
			place_single_face_down_card(current_spot)
			building_positions[i] = Vector2(x,y)
			i += 1
			#var card_atlas_coords = cards_to_use.pop_back()
			#tile_pos_to_atlas_position[current_spot] = card_atlas_coords
			#tile_map.set_cell(layers.revealed, current_spot, 
						#atlas_source_num, card_atlas_coords)
						#
func place_single_face_down_card(coords: Vector2):
	#set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
	tile_map.set_cell(0, coords, 3, coords, 0)
	
func place_selection_of_tiles(coords: Vector2, location: Vector2):
	#set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
	tile_map.set_cell(0, location, 3, coords, 0)
	
func show_posibilities(location: Vector2):
	#set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
	tile_map.set_cell(0, location, layers.gray, location, 0)
#
#func set_cell():
	#pass
#
func _input(event):
	if Input.is_action_just_pressed("turn_tile"):
		#var pos_clicked = Vector2(tile_map.local_to_map(event.position))
		var pos_clicked = Vector2(tile_map.local_to_map(get_global_mouse_position()))
		#pos_clicked.x -= 1
		#pos_clicked.y -= 1 
		print(pos_clicked)
		#prints("click", event.position)
		#prints("click", event.global_position)
		prints("click", get_global_mouse_position() )
		
		tile_map.set_cell(0, pos_clicked, color, pos_clicked, 0)
		if color < 10:
			color += 1
		else:
			color = 4
	#
