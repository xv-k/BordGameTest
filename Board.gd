extends Node2D

@onready var tile_map = $TileMap
@onready var popup_menu = $PopupMenu
@onready var popup_menu_company = $PopupMenuCompany


signal first_neigbour_signal

var board_x = 12
var board_y = 9
#all the available tiles
var all_tiles_array = range(108) #just numbers
#selection of tiles the player holds
var player_tiles = [] #just numbers
#position to show player tiles on screen
var player_tile_position = Vector2(6,11)
#colors of the board (index corresdponding to the company)
enum layers {black = 0, red, orange, yellow, green, blue, purple,  pink, white = 10, gray = 11}
#all companies
var companies = {1: "Company 1", 2: "Company 2", 3: "Company 3", 4: "Company 4", 5: "Company 5", 6: "Company 6", 7: "Company 7"}
#available companies
var available_companies = {} #set in setup

#used only for click action
var build_tile = false
var company_select = 0

func _ready():
	setup_board()
	
	#TODO: change popup menus to real UI menus
	popup_menu.add_item("Build building here") # id = 0
	popup_menu.add_item("Cancel") # id = 1
	#connect method menu_click to the "id_pressed" signal 
	popup_menu.connect("id_pressed", menu_click)
	
	for key in available_companies:
		popup_menu_company.add_item(available_companies[key],key)
	
	#button.connect("button_down", Callable(self, "_on_button_down"))
	popup_menu_company.connect("id_pressed", company_selection)
	

#to check if we can click on the tile
func menu_click(id):
	if id == 0:
		build_tile = true
		
func _process(_delta):
	pass
#
		
func setup_board():
	for key in companies:
		available_companies[key] = companies[key]
	shuffle_all_tiles() #shuffle the tiles
	pick_player_tiles(6) #take six tiles at start
	print_player_tiles(player_tile_position) #print the six tiles on screen
	print_board() #show the board on screen
	
#func fill_board_array():
	#var i = 0
	#for y in range(board_y):
		#for x in range(board_x):
			##board_array[i] = Vector2(x,y)
			#board_array.append(tile_object.new(i, Vector2(x,y), false)) 
			#i += 1
	
func print_board():
	for tile: GameData.tile_object in GameData.board_array:
		#set_cell(layernumber,
		#		  coords: where to place the tile,
		#		  source_id: number of the tileset (= colors in our case)
		#		  atlas_coords: coords of the tile in the tilemap (what tile to print on screen)
		#		  alternative_tile: int = 0 (no alternatives at the moment)
		
		if not tile.is_tile_built:
			tile_map.set_cell(0, tile.tile_coords, layers.white, tile.tile_coords)
		else:
			match tile.company:
				0:
					tile_map.set_cell(0, tile.tile_coords, layers.black, tile.tile_coords)
				1:
					tile_map.set_cell(0, tile.tile_coords, layers.red, tile.tile_coords)
				2:
					tile_map.set_cell(0, tile.tile_coords, layers.orange, tile.tile_coords)
				3:
					tile_map.set_cell(0, tile.tile_coords, layers.yellow, tile.tile_coords)
				4:
					tile_map.set_cell(0, tile.tile_coords, layers.green, tile.tile_coords)
				5:
					tile_map.set_cell(0, tile.tile_coords, layers.blue, tile.tile_coords)
				6:
					tile_map.set_cell(0, tile.tile_coords, layers.purple, tile.tile_coords)
				7:
					tile_map.set_cell(0, tile.tile_coords, layers.pink, tile.tile_coords)
					
	#to show the palyer posibilities
	for i in player_tiles:
		#we loop over the numbers in the player tiles, and those tiles on the board are shown in grey
		tile_map.set_cell(0, GameData.board_array[i].tile_coords, layers.gray, GameData.board_array[i].tile_coords)
		
func shuffle_all_tiles():
	all_tiles_array.shuffle()

func pick_player_tiles(amount):
	for i in range(amount): #take 6 tiles and remove them from the all_tiles_array
		player_tiles.push_back(all_tiles_array.pop_back())

func remove_player_tile(tile_clicked:Vector2):
	var tile_number = GameData.get_number_from_position(tile_clicked)
	if tile_number >= 0:
		player_tiles.erase(tile_number)
	
func print_player_tiles(screen_pos: Vector2):
	for i in player_tiles:
		screen_pos.x += 1
		tile_map.set_cell(0, screen_pos, layers.white, GameData.board_array[i].tile_coords, 0)

func set_tile_to_built(tile_clicked: Vector2):
	var tile = GameData.get_tile_from_position(tile_clicked)
	tile.is_tile_built = true
	
func set_tile_company(tile_clicked: Vector2, comp: int):
	var tile = GameData.get_tile_from_position(tile_clicked)
	tile.company = comp	
	
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
			#tile_map.set_cell(0, pos_clicked,layers.black, pos_clicked)
			set_tile_to_built(pos_clicked)
			check_first_built_neighbour(pos_clicked)
			build_tile = false
			#remove the tile from the player_tiles
			remove_player_tile(pos_clicked)
			#pick a new tile, show the tiles and print the board
			pick_player_tiles(1)
			print_player_tiles(player_tile_position)
			print_board()
		#DEBUG: print neighbours
		print(pos_clicked)
		#DEBUG: print neighbours
		prints(
			"left", GameData.check_neighbours(pos_clicked)[0], 
			"up", GameData.check_neighbours(pos_clicked)[1],
			"right", GameData.check_neighbours(pos_clicked)[2], 
			"down", GameData.check_neighbours(pos_clicked)[3])
		#DEBUG: print board array
		for tile: GameData.tile_object in GameData.board_array:
			prints(tile.tile_number, tile.tile_coords, tile.is_tile_built, tile.neighbours)
		#DEBUG: check neigbours are built
		prints(
			GameData.check_if_number_is_built(GameData.check_neighbours(pos_clicked)[0]), 
			GameData.check_if_number_is_built(GameData.check_neighbours(pos_clicked)[1]),
			GameData.check_if_number_is_built(GameData.check_neighbours(pos_clicked)[2]), 
			GameData.check_if_number_is_built(GameData.check_neighbours(pos_clicked)[3]))
		
		

#used to check the click on the board
func check_if_tile_is_in_selection(click_pos: Vector2) -> bool:
	var pos_in_building_number = -1
	pos_in_building_number = GameData.get_number_from_position(click_pos)
	
	if player_tiles.find(pos_in_building_number) > -1:
		return true
	else:
		return false


func check_first_built_neighbour(pos_clicked):
	#if new building has one neighbour and that neighbour has no neighbours -> emit signal
	var only_neighbour = -1
	var neighbour_count = 0
	#array with neighbour numbers
	var neighbours = GameData.check_neighbours(pos_clicked)
	#loop neighbour numbers
	for i in neighbours:
			if GameData.check_if_number_is_built(i):
				#store neighbour
				only_neighbour = i
				#count neighbours
				neighbour_count += 1
	#if only one neighbour
	if neighbour_count == 1:
		#check if neighbour has a company
		if GameData.check_company_from_number(only_neighbour) == 0:
			var neighbour_pos = GameData.get_position_from_number(only_neighbour)
			#emit_signal("first_neigbour_signal", await choose_company(neighbour_pos, pos_clicked))
			choose_company(neighbour_pos, pos_clicked)
	
func choose_company(pos1:Vector2, pos2:Vector2):
	print("choose company")
	popup_menu_company.popup(Rect2(get_global_mouse_position().x+64, get_global_mouse_position().y+64, popup_menu.size.x, popup_menu.size.y))
	await popup_menu_company.id_pressed
	set_tile_company(pos1, company_select)
	set_tile_company(pos2, company_select)
	print_board()
	
func company_selection(id):
	company_select = (id)
	available_companies.erase(id)

	popup_menu_company.clear()
	if not available_companies.is_empty():
		for key in available_companies:
			popup_menu_company.add_item(available_companies[key],key)
	else: 
		popup_menu_company.add_item("no more companies",-1)

