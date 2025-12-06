class_name ScoreManager
extends Node

signal score_updated(new_value : int)

var total_score : int = 0
var score_checkpoint : int = 0


func _ready() -> void:
	connect_collectibles()


func reset_score(to_checkpoint : bool = false) -> void:
	if to_checkpoint:
		total_score = score_checkpoint
	else:
		total_score = 0
		score_checkpoint = 0


func save_checkpoint() -> void:
	score_checkpoint = total_score


# Used to connect to collectible signals on scene creation and on checkpoint 
func connect_collectibles() -> void:
	var collectibles = get_tree().get_nodes_in_group("Collectibles")
	for item in collectibles:
		if item.has_signal("collected"):
			item.collected.connect(_on_collectible_collected)


# Activates when the 
func _on_collectible_collected(score_value : int) -> void:
	total_score += score_value
	score_updated.emit(total_score)
