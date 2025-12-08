class_name Collectible
extends Area2D

## Pickup SFX import.
const PICKUP_SFX = preload("res://assets/audio/player_character_sfx/sfx_coin.ogg")

## Signals the item being collected and passes its score value.
signal collected(score_value : int)

## Points awarded when collected (1 = bronze, 5 = silver, 10 = gold)
@export_range(1, 100, 1) var score_value : int = 1

## The SFX audio stream player reference.
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


## Activates when a physical body enters the collectible's collision shape. 
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		# Play pickup sound
		audio_stream_player.stream = PICKUP_SFX
		audio_stream_player.play()
		# Signal that the collection happened
		collected.emit(score_value)
		# Hide immediately, then wait for sound to finish before removing
		set_deferred("monitoring", false)	# set_deferred is necessary to avoid timing bugs.
		hide()
		await audio_stream_player.finished
		queue_free()	# Destroys the Node automatically upon pending operations completion.
