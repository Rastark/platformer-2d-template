class_name PlayerCharacter
extends CharacterBody2D

signal died()

# Asset import
const JUMP_SFX = preload("res://assets/audio/player_character_sfx/sfx_jump.ogg")

## Base speed (px/s) of the character
const SPEED = 300.0
## Jump speed (px/s) of the character
const JUMP_VELOCITY = -600.0

#region knockback exported variables
## Knockback parameters - controls how the player gets pushed back when hit
@export_group("Knockback")
## How hard the player gets pushed back when hit (pixels/second)
@export_range(100, 1000, 50) var knockback_strength : float = 400.0
## How long the knockback lasts (seconds)
@export_range(0.1, 1.0, 0.05) var knockback_duration : float = 0.25
#endregion

#region Private variables - should be used only internally by the class
var _knockback_direction : Vector2 = Vector2.ZERO
var _knockback_force_multiplier : float = 1.0
#endregion

## Physics collision shape
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
## Player character's sprite with baked-in animation logic
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# SFX player
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

#region knockback onready variables
## Base knockback duration
@onready var knockback_timer: Timer = $KnockbackTimer
#endregion


# Physics logic - runs every physics frame
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	## Disables input detection while knockback is active.
	if knockback_timer.time_left > 0.0:
		velocity = _knockback_direction * knockback_strength * _knockback_force_multiplier
	else:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
			# Play JUMP SFX
			audio_stream_player.stream = JUMP_SFX
			audio_stream_player.play()
			
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			animated_sprite_2d.play("walk")
			
			# Turns the character towards the move direction
			if direction < 0:
				animated_sprite_2d.flip_h = true
			else:
				animated_sprite_2d.flip_h = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite_2d.play("idle")

	# Necessary to activate movement and collision calculations. Remove it or comment is out to stop them.
	move_and_slide()


## Handles reactions to damage.
func take_damage() -> void:
	die()


## Executes death cleanup operations.
func die() -> void:
	velocity = Vector2.ZERO
	knockback_timer.stop()
	died.emit()


#region Knockback logic
## Pushes the player away from a source position. Called by enemies when they hit the player.
## The optional force_multiplier makes some enemies push harder than others.
func apply_knockback(
		source_position : Vector2,
		force_multiplier : float = 1.0
) -> void:
	# Calculate push direction: away from whatever hit the player
	_knockback_direction = (global_position - source_position).normalized()
	# Always push slightly upward for better game feel
	_knockback_direction.y = -0.5
	_knockback_direction = _knockback_direction.normalized()
	_knockback_force_multiplier = force_multiplier

	# Start the knockback timer
	knockback_timer.wait_time = knockback_duration
	knockback_timer.start()
#endregion
