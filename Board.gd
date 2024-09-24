extends Node2D

@onready var tile_map = $TileMap
@onready var popup_menu = $PopupMenu

var board_x = 12
var board_y = 9
#all the tiles (in order) on the board
var board_array = {} #TODO #board: number: int, position: vector2, building: bool, company:int 
#all the available tiles
var all_tiles_array = range(108) #just numbers
#selection of tiles the player holds
var player_tiles = [] #just numbers
#position to show player tiles on screen
var player_tile_position = Vector2(6,11)
#colors of the board
enum layers {white = 3, yellow, gray, green, blue, orange, purple, red, pink, black = 0}



var build_tile = false

func _ready():
	setup_board()
	
	popup_menu.add_item("Build building here") # id = 0
	popup_menu.add_item("Cancel") # id = 1
	#connect method menu_click to the "id_pressed" signal 
	popup_menu.connect("id_pressed", menu_click)
	
func menu_click(id):
	if id == 0:
		build_tile = true
		
func _process(delta):
	pass
#
		
func setup_board():
	fill_board_array() #generate the list of numbers corresponding to the tiles position
	print_board() #show the board on screen
	shuffle_all_tiles() #shuffle the tiles
	pick_player_tiles(6) #take six tiles at start
	#print(all_tiles_array)
	#print(player_tiles)
	print_player_tiles(player_tile_position) #print the six tiles on screen
	show_player_posibilities_on_board()
	
func fill_board_array():
	var i = 0
	for y in range(board_y):
		for x in range(board_x):
			var current_spot = Vector2(x, y)
			board_array[i] = Vector2(x,y)
			i += 1

func print_board():
	for i in board_array:
		#set_cell(layernumber,
		#		  coords: where to place the tile,
		#		  source_id: number of the tileset (= colors in our case)
		#		  atlas_coords: coords of the tile in the tilemap (what tile to print on screen)
		#		  alternative_tile: int = 0 (no alternatives at the moment)
		tile_map.set_cell(0, board_array[i], 3, board_array[i])

func shuffle_all_tiles():
	all_tiles_array.shuffle()

func pick_player_tiles(amount):
	for i in range(amount): #take 6 tiles and remove them from the all_tiles_array
		player_tiles.push_back(all_tiles_array.pop_back())

func remove_player_tile(tile_clicked:Vector2):
	#convert the postition of the tile (vector2) in an number and remove that number from the player tiles
	player_tiles.erase(board_array.find_key(tile_clicked))
	
func print_player_tiles(position: Vector2):
	for i in player_tiles:
		position.x += 1
		tile_map.set_cell(0, position, 3, board_array[i], 0)

func show_player_posibilities_on_board():
	for i in player_tiles:
		#we loop over the numbers in the player tiles, and those tiles on the board are shown in grey
		tile_map.set_cell(0, board_array[i], layers.gray, board_array[i])

	
func _input(event):
	click_on_tile()
	
func click_on_tile():
	if Input.is_action_just_pressed("turn_tile"):
		#convert mouse position to tile coordinate
		var pos_clicked = Vector2(tile_map.local_to_map(get_global_mouse_position()))
		if check_if_tile_is_in_selection(pos_clicked):
			#if tile can be clicked -> show small menu to choose what to do
			popup_menu.popup(Rect2(get_global_mouse_position().x+64, get_global_mouse_position().y+64, popup_menu.size.x, popup_menu.size.y))
			#we await the signal result before we continue
			await popup_menu.id_pressed #this sets the build tile boolean to true
		#if you chose to build the tile in the menu
		if build_tile:
			#change color of the tile
			print("color")
			tile_map.set_cell(0, pos_clicked,layers.black, pos_clicked)
			build_tile = false
			#remove the tile from the player_tiles
			remove_player_tile(pos_clicked)
			#pich a new tile, show the tiles and show the new posibilities
			pick_player_tiles(1)
			print_player_tiles(player_tile_position)
			show_player_posibilities_on_board()
			
	#
func check_if_tile_is_in_selection(click_pos: Vector2) -> bool:
	var pos_in_building_number = board_array.find_key(click_pos)
	if player_tiles.find(pos_in_building_number) > -1:
		return true
	else:
		return false



		
