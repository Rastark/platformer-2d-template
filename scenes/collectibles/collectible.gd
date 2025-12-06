class_name Collectible
extends Area2D

## Pickup SFX import.
const PICKUP_SFX = preload("res://assets/audio/player_character_sfx/sfx_coin.ogg")

## Signals the item being collected and passes its score value.
signal collected(score_value : int)

## The collectible's score value.
@export var score_value : int = 1

## The SFX audio stream player reference.
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


## Activates when a physical body enters the collectible's collision shape. 
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		# Set the audio stream and play i.t
		audio_stream_player.stream = PICKUP_SFX
		audio_stream_player.play()
		# Signal that the collection happened
		collected.emit(score_value)
		# Deactivate and hide the coin immediately and awaits for the SFX to finish playing before. 
		# clearing it.
		set_deferred("monitoring", false)	# set_deferred is necessary to avoid timing bugs.
		hide()
		await audio_stream_player.finished
		queue_free()	# Destroys the Node automatically upon pending operations completion.
