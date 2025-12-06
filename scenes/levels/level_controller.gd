## This class holds the responsibility of orchestrating the level's flow. 
## It acts as a communication mediator between its children Nodes.
class_name LevelController
extends Node2D

# Dependencies
# Player
## Determines the position at which the player spawns if the the level is not completed and no checkpoints have been reached.
@export var player_spawn_marker : Marker2D

# Variables
## Custom respawn position. Automatically saved on reaching a checkpoint. The player will restart.
var _player_respawn_global_position : Vector2 = Vector2.ZERO

## Gets set to true upon completing the level.
var _level_completed : bool = false

# Components
# Player
## Reference to the PlayerCharacter. Used mainly for respawning reasons.
@onready var player_character: PlayerCharacter = $PlayerCharacter

# Score
## Used to manage the level score.
@onready var score_manager: ScoreManager = $ScoreManager

# Optional Managers
## Used to manage the collectible respawn
@onready var collectible_manager: BaseManager = $CollectibleManager
## Used to manage the enemy respawn
@onready var enemy_manager: BaseManager = $EnemyManager

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
## Spawns the player accordingly to its last checkpoint position.
func spawn_player() -> void:
	# If there's no saved respawn position, move the character to the start of the level
	if _player_respawn_global_position == Vector2.ZERO:
		player_character.global_position = player_spawn_marker.global_position
	# Otherwise, move it to the saved position
	else:
		player_character.global_position = _player_respawn_global_position


## Shows level completion UI and marks the level as completed.
func complete_level() -> void:
	setup_and_show_win_screen()
	_level_completed = true


## Sets up and hows level completion UI.
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


## Saves checkpoint data.
func _on_checkpoint_activated(checkpoint_global_position : Vector2) -> void:
	_player_respawn_global_position = checkpoint_global_position
	score_manager.save_checkpoint()
	collectible_manager.save_item_checkpoint()
	enemy_manager.save_item_checkpoint()
#endregion


## Activates when the player hits an area capable of killing it (DeathAreas) group. Commands the
## player character to trigger its death process.
func _on_death_area_body_entered(body: Node2D) -> void:
	if body == player_character:
		player_character.die()


## Activates when the goal area is reached. Completes the level.
func _on_goal_body_entered(body: Node2D) -> void:
	if body == player_character:
		complete_level()


## Activates when the player dies. 
## Making it respawn to its last checkpoint if they reached one or resetting the level entirely otherwise
func _on_player_character_died() -> void:
	
	# Checks if the player reached a checkpoint by looking at the custom respawn positiopn
	var checkpoint_reached : bool = _player_respawn_global_position != Vector2.ZERO
	
	# If the level is completed or the player has not reached any checkpoint, reset it completely
	if _level_completed or not checkpoint_reached:
		reload_level()
		return
	
	#region Respawn to Checkpoint - plays only if the player reached a checkpoint
	# Hide the level completion UI
	hide_win_screen()

	# Reset Managers to checkpoint state
	collectible_manager.reset_items(checkpoint_reached)
	enemy_manager.reset_items(checkpoint_reached)
	
	# Reset Score to checkpoint state
	score_manager.reset_score(checkpoint_reached)
	score_manager.connect_collectibles()
	
	# Reset UI to checkpoint state
	score_points_label.text = str(score_manager.total_score)
	
	# Respawn the PlayerCharacter
	spawn_player()
#endregion
