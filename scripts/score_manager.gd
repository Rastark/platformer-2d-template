class_name ScoreManager
extends Node

## Signals when the score changes
signal score_updated(new_value : int)

## Total score value
var total_score : int = 0
## Stored score value checkpoint
var score_checkpoint : int = 0


#region initialization
func _ready() -> void:
	connect_collectibles()
#endregion


## Resets the score to 0 (to_checkpoint = false) or 
## to the last checkpoint_value (to_checkpoint = true)
func reset_score(to_checkpoint : bool = false) -> void:
	if to_checkpoint:
		total_score = score_checkpoint
	else:
		total_score = 0
		score_checkpoint = 0


## Saves checkpoint data
func save_checkpoint() -> void:
	score_checkpoint = total_score


## Used to connect to collectible signals on scene creation and on checkpoint restoration.
func connect_collectibles() -> void:
	var collectibles = get_tree().get_nodes_in_group("Collectibles")
	for item in collectibles:
		if item.has_signal("collected"):
			item.collected.connect(_on_collectible_collected)


## Activates when a collectible item gets picked up. Adds the passed value to the total score
## and signals the event to external entities
func _on_collectible_collected(score_value : int) -> void:
	total_score += score_value
	score_updated.emit(total_score)
