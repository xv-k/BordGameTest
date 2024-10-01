extends Node

#temporaraly
var board_x = 12
var board_y = 9

class tile_object:
	var tile_number: int
	var tile_coords: Vector2
	var is_tile_built: bool
	var company: int
	var neighbours : Array
	
	func _init(tn: int, tc: Vector2, itb: bool):
		tile_number = tn
		tile_coords = tc
		is_tile_built = itb
		company = 0
		neighbours = []
	
#all the tiles (in order) on the board
var board_array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	fill_board_array() #generate the tiles
	add_all_neighbours_to_array()
	#DEBUG: print board array
	for tile: GameData.tile_object in GameData.board_array:
		prints(tile.tile_number, tile.tile_coords, tile.is_tile_built, tile.neighbours)

func fill_board_array():
	var i = 0
	for y in range(9):
		for x in range(12):
			#board_array[i] = Vector2(x,y)
			board_array.append(tile_object.new(i, Vector2(x,y), false)) 
			i += 1
			
			
func get_tile_from_position(pos: Vector2) -> tile_object:
	if pos.x >= 0 and pos.y >=0 :
		return board_array.filter(func(to): return to.tile_coords == pos)[0]
	return null
	
func get_tile_from_number(tile_num: int) -> tile_object:
	if tile_num >= 0:
		return board_array.filter(func(to): return to.tile_number == tile_num)[0]
	return null
	
func get_number_from_position(pos: Vector2) -> int:
	var tile = board_array.filter(func(to): return to.tile_coords == pos)
	if tile.size() > 0:
		return tile[0].tile_number
	else: return -1

func get_position_from_number(tile_num: int) -> Vector2:
	if tile_num > 0:
		return get_tile_from_number(tile_num).tile_coords
	return Vector2.ZERO

func check_if_position_is_built(pos: Vector2) -> bool:
	return get_tile_from_position(pos).is_tile_built

func check_if_number_is_built(tile_num: int) -> bool:
	if tile_num > 0:
		return get_tile_from_number(tile_num).is_tile_built
	return false
	
func check_company_from_position(pos: Vector2) -> int:
	return get_tile_from_position(pos).company

func check_company_from_number(tile_num: int) -> int:
	if tile_num > 0:
		return get_tile_from_number(tile_num).company
	return -1 #TODO: not good, retuns multiple times -1 if tile is against border so same company
	
func add_all_neighbours_to_array():
	for tile: GameData.tile_object in GameData.board_array:
		tile.neighbours = check_neighbours(tile.tile_coords)

func count_all_companies_of_ont_type(id) -> int:
	var company_count = 0
	for tile: GameData.tile_object in GameData.board_array:
		if tile.company == id:
			company_count += 1
	return company_count
	
#retuns the number postion of the neightbours (clockwise from left)
#borders also get a number (had soome bugs with -1 for all borders)
#lesft: -1, up: -2, right: -3, bottom: -4
func check_neighbours(click_pos: Vector2) -> Array:
	var result = [-5, -5, -5, -5]
	var tile_number = GameData.get_number_from_position(click_pos)

	#left -> -1 but result must be larger than 0 otherwise return -1
	# on row two 0 is 11 so must be larger than 11 ...
	if (tile_number - (click_pos.y * board_x)) > 0:
		result[0] = tile_number - 1
	else:
		result[0] = -1
	#up -> -board_x but position must be larger than board_X
	if (tile_number - board_x) and tile_number > board_x:
		result[1] = tile_number - board_x
	else:
		result[1] = -2
	#right -> + 1 but result must be lower than board size otherwise return -1 (=board edge)
	if (tile_number - (click_pos.y * board_x)) < (board_x-1):
		result[2] = tile_number + 1
	else:
		result[2] = -3
	#down -> + board_x but pos must be lower than pos minus board_x
	if (tile_number + board_x) and (tile_number + board_x) < (GameData.board_array.size() - 1):
		result[3] = tile_number + board_x
	else:
		result[3] = -4
		#left, up, right, down
	return result
