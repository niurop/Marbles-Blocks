extends Node

export var level_id := 0

var level = null

var state := 0
var reset := false

var total_game_time := 0.0
var level_time := 0.0
var restarts := 0
var level_restarts := 0
var cheated := false

var levels := [
	preload("res://Levels/Level_0.tscn"),
	preload("res://Levels/Level_1.tscn"),
	preload("res://Levels/Level_2.tscn"),
	preload("res://Levels/Level_3.tscn"),
	preload("res://Levels/Level_4.tscn"),
	preload("res://Levels/Level_5.tscn"),
	preload("res://Levels/Level_6.tscn"),
	preload("res://Levels/Level_7.tscn"),
	preload("res://Levels/Level_8.tscn"),
	preload("res://Levels/Level_9.tscn"),
	preload("res://Levels/Level_10.tscn"),
	preload("res://Levels/Level_11.tscn"),
	preload("res://Levels/Level_12.tscn"),
	preload("res://Levels/Level_13.tscn"),
	preload("res://Levels/Level_14.tscn"),
	preload("res://Levels/Level_15.tscn"),
	preload("res://Levels/Level_16.tscn"),
	preload("res://Levels/Level_17.tscn"),
	preload("res://Levels/Level_18.tscn"),
	preload("res://Levels/Level_19.tscn"),
	preload("res://Levels/Level_20.tscn"),
	preload("res://Levels/Level_21.tscn"),
	preload("res://Levels/Level_22.tscn"),
	preload("res://Levels/Level_23.tscn"),
	preload("res://Levels/Level_24.tscn"),
]

onready var N_levels := str(levels.size())

func _process(delta):
	match(state):
		-1:
			cheated = false
			level_id = 0
			$WhiteScreen.level = 1.0
			$WhiteScreen.fade_in()
			for elem in $EndScreen.get_children():
				elem.hide()
			$Hint.show()
			total_game_time = 0.0
			level_time = 0.0
			restarts = 0
			level_restarts = 0
			state = 0
		0:
			reset = false
			level = levels[level_id].instance()
			$Levels.add_child(level)
			$WhiteScreen.fade_out()
			state = 1
		1:
			if($WhiteScreen.done):
				state = 2
		2:
			level_time += delta
			if(!level.win):
				if(Input.is_key_pressed(KEY_0)):
					level.win = true
					cheated = true
				elif(Input.is_key_pressed(KEY_R)):
					reset = true
					state = 3
					level_restarts += 1
				else:
					level.process(delta)
			else:
				state = 3
		3:
			$WhiteScreen.fade_in()
			state = 4
		4:
			if($WhiteScreen.done):
				$Levels.remove_child(level)
				state = 5
		5:
			if(!reset):
				level_id += 1
				restarts += level_restarts
				level_restarts = 0
				total_game_time += level_time
				level_time = 0.0
			if(level_id >= levels.size()):
				state = 6
			else:
				state = 0
		6:
			$WhiteScreen.fade_in()
			state = 7
		7:
			if($WhiteScreen.done):
				state = 8
				$Timer.text = ""
				$Restarts.text = ""
				$Level.text = ""
				$Hint.hide()
				$EndScreen/Final_Time.text = "Your total time is " + print_time(total_game_time) + "!"
				$EndScreen/Final_Restarts.text = "You made " + str(restarts) + " restarts!"
				for elem in $EndScreen.get_children():
					elem.show()
				if(cheated):
					$EndScreen/Win.hide()
				else:
					$EndScreen/Cheat.hide()
				return
		8:
			if(Input.is_key_pressed(KEY_R)):
				state = -1
			return
	$Timer.text = "Time: " + print_time(total_game_time) + " + " + print_time(level_time)
	$Restarts.text = "Restarts: " + str(restarts) + " + " + str(level_restarts)
	$Level.text = "Level: " + str(level_id + 1) + "/" + N_levels

func print_time(time):
	var secs = time as int
	var msec = time - secs
	var mins = (secs / 60) as int
	secs = secs % 60
	return ("0" if mins < 10 else "") + str(mins) + ":" + ("0" if secs < 10 else "") + str(secs) + "." + str(msec).pad_decimals(3).right(2)
