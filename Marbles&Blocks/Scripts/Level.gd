extends Node2D

onready var marbles := $Marbles.get_children()
onready var blocks  := $Blocks.get_children()

var _all_entities := []

var _movement := false
var _processing_needed := false
var _tails := []
var _to_process := []
var _percent := 0.0

var _time_per_square := 0.1

var win := false

func _ready():
	_all_entities.append_array(marbles)
	_all_entities.append_array(blocks)
	for entity in _all_entities:
		entity.all_entities = _all_entities
		entity.map = $Map

func _process_movement(delta):
	_percent = min(1, _percent + delta / _time_per_square)
	_movement = false
	for entity in _all_entities:
		entity.process_movement(_percent)
		if(entity.is_moving()):
			_movement = true

func _process_action():
	_percent = 0.0
	_processing_needed = false
	_to_process = []
	for entity in _all_entities:
		entity.init_pos = entity.position
		entity.influences = null
		entity.influenced_by = null
		entity.apply_direction(entity.direction)
		if(entity.processing_stage == 1):
			_processing_needed = true
			_to_process.append(entity)
	if(_processing_needed):
		for entity in _to_process:
			if(entity.processing_stage == 1):
				entity.check_what_is_in_front_until_free()
		_tails = []
		for entity in _to_process:
			var last = entity.find_last()
			if(last.movement_state != -1 && !_tails.has(last)):
				_tails.append(last)
		for last in _tails:
			last.find_root().calculate_move(0)
		_movement = true
	else:
		for marble in marbles:
			var tile = $Map.is_a_color_target(marble.position)
			if(!(tile == 0 or tile == marble.type)):
				return
		win = true

func _process_input():
	var action_x = 0
	var action_y = 0
	var direction = 0
	if(Input.is_key_pressed(KEY_UP) || Input.is_key_pressed(KEY_W)):
		action_y -= 1
		direction = 4
	elif(Input.is_key_pressed(KEY_DOWN) || Input.is_key_pressed(KEY_S)):
		action_y += 1
		direction = 2
	elif(Input.is_key_pressed(KEY_LEFT) || Input.is_key_pressed(KEY_A)):
		action_x -= 1
		direction = 3
	elif(Input.is_key_pressed(KEY_RIGHT) || Input.is_key_pressed(KEY_D)):
		action_x += 1
		direction = 1
	if(action_x*action_x + action_y*action_y == 1):
		for entity in _all_entities:
			entity.apply_direction(direction)
			entity.movement_state = 0
			entity.processing_stage = 0
			entity.has_just_finished_moving = false
		for marble in marbles:
			marble.processing_stage = 1
		_processing_needed = true

func process(delta):
	if(_movement):
		_process_movement(delta)
	elif(_processing_needed):
		_process_action()
	else:
		_process_input()
	
