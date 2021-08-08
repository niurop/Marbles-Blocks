extends TileMap

const WALLS := [2,3]

func get_ground_type(pos:Vector2) -> int:
	return get_cellv(pos / 32) + 1

func is_a_wall(pos:Vector2) -> bool:
	return get_ground_type(pos) in WALLS

func is_a_color_target(_pos:Vector2) -> int:
	return 0
