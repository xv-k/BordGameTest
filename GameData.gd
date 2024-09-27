extends Node

class tile_object:
	var tile_number: int
	var tile_coords: Vector2
	var is_tile_built: bool
	var company: int
	
	func _init(tn: int, tc: Vector2, itb: bool):
		tile_number = tn
		tile_coords = tc
		is_tile_built = itb
		company = 0
	
#all the tiles (in order) on the board
var board_array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	fill_board_array() #generate the tiles


func fill_board_array():
	var i = 0
	for y in range(9):
		for x in range(12):
			#board_array[i] = Vector2(x,y)
			board_array.append(tile_object.new(i, Vector2(x,y), false)) 
			i += 1
			
func get_tile_from_position(pos: Vector2) -> tile_object:
	return board_array.filter(func(to): return to.tile_coords == pos)[0]

func get_tile_from_number(tile_num: int) -> tile_object:
	if tile_num > 0:
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
	return -1
