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

func get_number_from_position():
	pass

