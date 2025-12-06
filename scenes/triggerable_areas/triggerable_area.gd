class_name TriggerableArea
extends Area2D

signal activated(global_position : Vector2)

var active : bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


## Used to "permanently" activate the area.
func activate() -> void:
	active = true
	set_deferred("monitoring", false)
	animated_sprite_2d.play("active")
	activated.emit(global_position)


## Resets the area to its initial state.
func reset() -> void:
	active = false
	set_deferred("monitoring", true)
	animated_sprite_2d.play("inactive")


## Detects physical bodies entering the range and activates the area if a player character enters.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		activate()
