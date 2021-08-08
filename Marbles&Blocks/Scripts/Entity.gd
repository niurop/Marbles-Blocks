tool
extends Node2D

class_name Entity

# 0 - none
# 1 - blue
# 2 - green
# 3 - yellow
# 4 - red
export var type := 0

var influences = null
var influenced_by = null

# 0 - No processing needed
# 1 - processing needed
# 2 - created tree
# 3 - during movement
var processing_stage := 0
# -1 - blocked
# 0 - no movement
# x - simple movement for x squares [does not decrese for marbles]
var movement_state := 0
var has_just_finished_moving := false

var direction := 0
onready var target := position
onready var _oryginal_position := position
var init_pos := Vector2()

var all_entities := []
var map = null

func reset():
	position  = _oryginal_position
	direction = 0
	target = position
	influences = null
	influenced_by = null
	processing_stage = 0
	movement_state = 0
	has_just_finished_moving = false

func find_root():
	return self if influenced_by == null else influenced_by.find_root()

func find_last():
	return self if influences == null else influences.find_last()

func is_moving():
	return processing_stage == 3

func set_blocked():
	movement_state = -1
	processing_stage = 0
	if(influenced_by != null):
		influenced_by.set_blocked()

func calculate_move(push:int):
	if(has_just_finished_moving):
		if(type == 0):
			if(movement_state <= 1):
				movement_state = 0
				processing_stage = 0
				if(influences != null):
					influences.calculate_move(0)
			elif(influences != null):
				movement_state = 0
				processing_stage = 0
				influences.calculate_move(movement_state-1 if influences.type == 0 else 0)
			else:
				movement_state -= 1
				processing_stage = 3
		else:
			if(influences == null && movement_state > 1):
				processing_stage = 3
			else:
				movement_state = 0
				processing_stage = 0
			if(influences != null):
				influences.calculate_move(0)
	else:
		if(type == 0):
			if(push > 0):
				movement_state = push
				processing_stage = 3
			else:
				set_blocked()
			if(influences != null):
				influences.calculate_move(movement_state-1 if influences.type == 0 else 0)
		else:
			movement_state = push + 1
			processing_stage = 3
			if(influences != null):
				influences.calculate_move(movement_state)
	has_just_finished_moving = false

func set_direction(new_direction:int):
	direction = new_direction
	target.x = ((position.x / 32) as int) * 32
	target.y = ((position.y / 32) as int) * 32
	match(direction):
		1: target.x += 32
		2: target.y += 32
		3: target.x -= 32
		4: target.y -= 32

func apply_direction(new_direction:int):
	set_direction(new_direction)
	check_if_hitting_a_wall()

func check_if_hitting_a_wall():
	if(map.is_a_wall(target)):
		set_blocked()

func check_what_is_in_front_until_free():
	processing_stage = 2
	for other in all_entities:
		if(other != self && other.position == target):
			influences = other
			other.influenced_by = self
			if(other.processing_stage != 2):
				other.check_what_is_in_front_until_free()
			if(other.movement_state == -1):
				set_blocked()
			return null

func process_movement(percent):
	if(movement_state > 0):
		position = lerp(init_pos, target, percent)
		z_index = position.y as int
		if(percent == 1):
			processing_stage = 1
			has_just_finished_moving = true
		
func _process(_delta):
	if Engine.editor_hint:
		position.x = ((position.x / 32) as int) * 32
		position.y = ((position.y / 32) as int) * 32
		z_index = position.y as int
