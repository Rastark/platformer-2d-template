## This class holds the responsibility of orchestrating the level's flow. 
## It acts as a communication mediator between its children Nodes.
class_name LevelController
extends Node2D

# Dependencies
# Player
## Determines the position at which the player spawns if the the level is not completed
@export var player_spawn_marker : Marker2D

# Variables
## Gets set to true upon completing the level.
var _level_completed : bool = false

# Components
# Player
## Reference to the PlayerCharacter. Used mainly for respawning reasons.
@onready var player_character: PlayerCharacter = $PlayerCharacter

# Goal Detection Area
@onready var goal: Area2D = $Goal

# Score
## Used to manage the level score.
@onready var score_manager: ScoreManager = $ScoreManager

# UI
## Label for the actual level score value on the user interface.
@onready var score_points_label: Label = %ScorePointsLabel
## Label for the final level score value showed on the level completed screen.
@onready var final_score_points_label: Label = %FinalScorePointsLabel
## Level completed screen.
@onready var win_screen: Panel = %WinScreen


#region Setup
func _ready() -> void:
	## Spawns the player when the level starts.
	spawn_player()
#endregion


#region Functions
## Spawns the player accordingly to its starting position marker.
func spawn_player() -> void:
	player_character.global_position = player_spawn_marker.global_position


## Shows level completion UI and marks the level as completed.
func complete_level() -> void:
	setup_and_show_win_screen()
	_level_completed = true


## Sets up and shows level completion UI.
func setup_and_show_win_screen() -> void:
	var score = score_manager.total_score
	win_screen.show()
	final_score_points_label.text = str(score)


## Hides the level completion UI.
func hide_win_screen() -> void:
	win_screen.hide()


## Resets the level scene by reloading it.
func reload_level() -> void:
	get_tree().reload_current_scene()
#endregion


#region Events
## Updates the score UI when the internal value is updated.
func _on_score_manager_score_updated(new_value: int) -> void:
	score_points_label.text = str(new_value)


## Activates when the player hits an area capable of killing it (DeathAreas) group. Commands the
## player character to trigger its death process.
func _on_death_area_body_entered(body: Node2D) -> void:
	if body == player_character:
		player_character.die()


## Activates when the goal area is reached. Completes the level.
func _on_goal_body_entered(body: Node2D) -> void:
	if body == player_character:
		goal.activate()
		complete_level()


## Activates when the player dies.
func _on_player_character_died() -> void:
	reload_level()
#endregion
