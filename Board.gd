extends Node2D

@onready var tile_map = $TileMap
@onready var popup_menu = $PopupMenu

#TODO should be refactored (rewritten) with a board array with tile objects as a state variable
#board array should be autoloaded

signal first_neigbour_signal

var board_x = 12
var board_y = 9
#all the tiles (in order) on the board
var board_array = []
#all the available tiles
var all_tiles_array = range(108) #just numbers
#selection of tiles the player holds
var player_tiles = [] #just numbers
#position to show player tiles on screen
var player_tile_position = Vector2(6,11)
#colors of the board
enum layers {white = 3, yellow, gray, green, blue, orange, purple, red, pink, black = 0}

class tile_object:
	var tile_number: int
	var tile_coords: Vector2
	var is_tile_built: bool
	
	func _init(tn: int, tc: Vector2, ib: bool):
		tile_number = tn
		tile_coords = tc
		is_tile_built = ib
	
	
#used only for click action
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
		
func _process(_delta):
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
	show_player_possibilities_on_board()
	
func fill_board_array():
	var i = 0
	for y in range(board_y):
		for x in range(board_x):
			#board_array[i] = Vector2(x,y)
			board_array.append(tile_object.new(i, Vector2(x,y), false)) 
			i += 1
	
func print_board():
	for tile in board_array:
		#set_cell(layernumber,
		#		  coords: where to place the tile,
		#		  source_id: number of the tileset (= colors in our case)
		#		  atlas_coords: coords of the tile in the tilemap (what tile to print on screen)
		#		  alternative_tile: int = 0 (no alternatives at the moment)
		tile_map.set_cell(0, tile.tile_coords, 3, tile.tile_coords)

func shuffle_all_tiles():
	all_tiles_array.shuffle()

func pick_player_tiles(amount):
	for i in range(amount): #take 6 tiles and remove them from the all_tiles_array
		player_tiles.push_back(all_tiles_array.pop_back())

func remove_player_tile(tile_clicked:Vector2):
	#convert the postition of the tile (vector2) in an number and remove that number from the player tiles
	#player_tiles.erase(board_array.find_key(tile_clicked))
	#using the tile_object instead with a lambda (pfff) 
	var tile = board_array.filter(func(to): return to.tile_coords == tile_clicked)
	if tile.size() > 0:
		player_tiles.erase(tile[0].tile_number)
		
	#TODO not happy with lambda: is too much of a hassle, getting an array of objects from the filter fucntion and
	#checking if array is not empty before doing anything (pffff)
	
func print_player_tiles(screen_pos: Vector2):
	for i in player_tiles:
		screen_pos.x += 1
		tile_map.set_cell(0, screen_pos, 3, board_array[i].tile_coords, 0)

func show_player_possibilities_on_board():
	for i in player_tiles:
		#we loop over the numbers in the player tiles, and those tiles on the board are shown in grey
		tile_map.set_cell(0, board_array[i].tile_coords, layers.gray, board_array[i].tile_coords)

func set_tile_to_built(tile_clicked: Vector2):
	var tile = board_array.filter(func(to): return to.tile_coords == tile_clicked)
	if tile.size() > 0:
		tile[0].is_tile_built = true
	
func _input(_event):
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
			tile_map.set_cell(0, pos_clicked,layers.black, pos_clicked)
			set_tile_to_built(pos_clicked)
			check_first_built_neighbour(pos_clicked)
			build_tile = false
			#remove the tile from the player_tiles
			remove_player_tile(pos_clicked)
			#pich a new tile, show the tiles and show the new posibilities
			pick_player_tiles(1)
			print_player_tiles(player_tile_position)
			show_player_possibilities_on_board()
		
		#DEBUG: print neighbours
		prints(
			"left", check_neighbours(pos_clicked)[0], 
			"up", check_neighbours(pos_clicked)[1],
			"right", check_neighbours(pos_clicked)[2], 
			"down", check_neighbours(pos_clicked)[3])
		#DEBUG: print board array
		#for tile: tile_object in board_array:
			#prints(tile.tile_number, tile.tile_coords, tile.is_tile_built)
		#DEBUG: check neigbours are built
		prints(
			check_if_number_is_built(check_neighbours(pos_clicked)[0]), 
			check_if_number_is_built(check_neighbours(pos_clicked)[1]),
			check_if_number_is_built(check_neighbours(pos_clicked)[2]), 
			check_if_number_is_built(check_neighbours(pos_clicked)[3]))
		
		

#used to check the click on the board
func check_if_tile_is_in_selection(click_pos: Vector2) -> bool:
	var pos_in_building_number = -1
	#var pos_in_building_number = board_array.find_key(click_pos)
	#using the tile_object instead with a lambda (pfff)
	var tile = board_array.filter(func(to): return to.tile_coords == click_pos)
	if tile.size() > 0:
		pos_in_building_number = tile[0].tile_number
	
	if player_tiles.find(pos_in_building_number) > -1:
		return true
	else:
		return false

#retuns the number postion of the neightbours (clockwise from left)
func check_neighbours(click_pos: Vector2) -> Array:
	var result = [-1, -1, -1, -1]
	#var tile_number = board_array.find_key(click_pos)
	#using the tile_object instead with a lambda (pfff)
	var tile = board_array.filter(func(to): return to.tile_coords == click_pos)
	if tile.size() > 0:
		var tile_number = tile[0].tile_number
	
		#left -> -1 but result must be larger than 0 otherwise return -1
		if (tile_number - 1) >= 0:
			result[0] = tile_number - 1
		else:
			result[0] = -1
		#up -> -board_x but position must be larger than board_X
		if (tile_number - board_x) and tile_number > board_x:
			result[1] = tile_number - board_x
		else:
			result[1] = -1
		#right -> + 1 but result must be lower than board size otherwise return -1 (=board edge)
		if (tile_number + 1) < (board_array.size() - 1):
			result[2] = tile_number + 1
		else:
			result[2] = -1
		#down -> + board_x but pos must be lower than pos minus board_x
		if (tile_number + board_x) and (tile_number + board_x) < (board_array.size() - 1):
			result[3] = tile_number + board_x
		else:
			result[3] = -1
		#left, up, right, down
	return result

func check_neighbours_from_number(pos: int) -> Array:
	var result = [-1, -1, -1, -1]

	var tile_number = pos

	#left -> -1 but result must be larger than 0 otherwise return -1
	if (tile_number - 1) >= 0:
		result[0] = tile_number - 1
	else:
		result[0] = -1
	#up -> -board_x but position must be larger than board_X
	if (tile_number - board_x) and tile_number > board_x:
		result[1] = tile_number - board_x
	else:
		result[1] = -1
	#right -> + 1 but result must be lower than board size otherwise return -1 (=board edge)
	if (tile_number + 1) < (board_array.size() - 1):
		result[2] = tile_number + 1
	else:
		result[2] = -1
	#down -> + board_x but pos must be lower than pos minus board_x
	if (tile_number + board_x) and (tile_number + board_x) < (board_array.size() - 1):
		result[3] = tile_number + board_x
	else:
		result[3] = -1
		#left, up, right, down
	return result
	

func check_if_position_is_built(click_pos: Vector2) -> bool:
	var tile = board_array.filter(func(to): return to.tile_coords == click_pos)
	if tile.size() > 0:
		return tile[0].is_tile_built
	else:
		return false

func check_if_number_is_built(tile_num: int) -> bool:
	var tile = board_array.filter(func(to): return to.tile_number == tile_num)
	if tile.size() > 0:
		return tile[0].is_tile_built
	else:
		return false

#works but only if your company is built when two! tiles are neughbouring
#when they start out immidiatly with three, this doest work
#TODO: ann "company" variable to tile object and do this check:
 # -> if new tile has neighbour and tile is not yet part of a company 
func check_first_built_neighbour(pos_clicked):
	#if new building has one neighbour and that neighbour has no neighbours -> emit signal
	var only_neighbour = -1
	var neighbour_count = 0
	#array with neighbour numbers
	var neighbours = check_neighbours(pos_clicked)
	#loop neighbour numbers
	for i in neighbours:
			if check_if_number_is_built(i):
				#store neighbour
				only_neighbour = i
				#count neighbours
				neighbour_count += 1
	#if only one neighbour			
	if neighbour_count == 1:
		#check neighbour's neighbours
		var neighboursneighbour_count = 0
		var neighboursneighbours = check_neighbours_from_number(only_neighbour)
		for j in neighboursneighbours:
				if check_if_number_is_built(j):
					neighboursneighbour_count += 1
		if neighboursneighbour_count == 1:
			emit_signal("first_neigbour_signal", choose_company())
	
func choose_company():
	print("choose company")
