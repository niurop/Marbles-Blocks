extends Node

onready var SingleWalls := $SingleWalls.get_children()

func is_a_wall(pos:Vector2) -> bool:
	if($Walls.get_cellv(pos/32) != -1):
		return true
	for wall in SingleWalls:
		if(pos == wall.position):
			return true
	return false

func is_a_color_target(pos:Vector2) -> int:
	return $Finishes.get_cellv(pos/32)
