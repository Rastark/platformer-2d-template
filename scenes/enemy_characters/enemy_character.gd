class_name EnemyCharacter
extends CharacterBody2D

## Movement speed in pixels per second
@export_range(50, 300, 10) var speed : float = 100.0

## Starting direction: -1 = left, 1 = right
@export var direction := -1

## Enemy Behavior - what happens when this enemy touches the player
@export_group("Enemy Behavior")
## If ON, touching this enemy hurts the player
@export var hurts_player : bool = true
## If ON, touching this enemy pushes the player back
@export var pushes_player : bool = true
## How hard the player gets pushed (only works if pushes_player is ON)
@export_range(0.5, 3.0, 0.1) var push_strength : float = 1.0

## Enemy Character's Animated Sprite
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
## Ray Cast used for wall detection
@onready var wall_check_ray_cast: RayCast2D = $WallCheckRayCast
## Ray Cast used for ground/edge detection
@onready var ground_check_ray_cast: RayCast2D = $GroundCheckRayCast


@export var external_resource : EnemyResource


func _ready() -> void:
	if is_instance_valid(external_resource):
		speed = external_resource.speed
		animated_sprite_2d.sprite_frames = external_resource.sprite_frames


# Physics logic - runs every physics frame
func _physics_process(delta: float) -> void:
	# Turn around when reaching a wall or platform edge
	if not ground_check_ray_cast.is_colliding() or wall_check_ray_cast.is_colliding():
		direction *= -1
		flip()

	# Move horizontally
	velocity.x = speed * direction

	# Apply gravity when not on floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Apply movement
	move_and_slide()


# Flips the character sprite when changing direction
func flip() -> void:
	scale.x *= -1


## Called when something enters the enemy's hitbox
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Only affect the player
	if not body.is_in_group("Player"):
		return

	# Push the player back if enabled
	if pushes_player and body.has_method("apply_knockback"):
		body.apply_knockback(global_position, push_strength)

	# Hurt the player if enabled
	if hurts_player and body.has_method("take_damage"):
		body.take_damage()
