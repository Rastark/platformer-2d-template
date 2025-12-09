extends Area2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func activate() -> void:
	set_deferred("monitoring", false)
	animated_sprite_2d.play("active")
