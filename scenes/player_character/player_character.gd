class_name PlayerCharacter
extends CharacterBody2D

signal died()

# Asset import
const JUMP_SFX = preload("res://assets/audio/player_character_sfx/sfx_jump.ogg")

## Base speed (px/s) of the character
const SPEED = 300.0
## Jump speed (px/s) of the character
const JUMP_VELOCITY = -600.0

## Self-knockback parameters
@export_group("Knockback")
## Base strength at which knockbacks get applied to the player character (px/s)
@export var knockback_base_strength : float = 500.0
## Duration of the physics override of the knockback
@export var knockback_duration : float = 0.25
## Allows to influence the knockback angle. Every 0.5 corresponds to roughly 45° rotation on Y axis. 
## Positive goes toward ceiling and negative toward floor. 
@export_range(-1.0, 1.0, 0.01) var knockback_angle_correction : float = 0.5

#region Private variables - should be used only internally by the class
var _knockback_direction : Vector2 = Vector2.ZERO
var _knockback_force_multiplier : float = 1.0
#endregion

## Physics collision shape
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

## Base knockback duration
@onready var knockback_timer: Timer = $KnockbackTimer

## Player character's sprite with baked-in animation logic
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Scene variables
# SFX
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# Physics logic override. Should contain every calculation involving the physics engine.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	## Disables input detection while for knockback duration time.
	if knockback_timer.time_left > 0.0:
		velocity = _knockback_direction * knockback_base_strength * _knockback_force_multiplier
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


#region Optional knocked-back logic
## Used to start the knocked-back physical behavior. The "triggerer" of the behavior needs to specify at
## least its position and can optionally add a stronger force multiplier. 
func apply_knockback(
		source_position : Vector2, 
		knockback_force_multiplier : float = 1.0
 )-> void:
	# Saving internal values accordingly to the last knockback received
	# Calculates normalized direction according to the source of the knockback.
	_knockback_direction = (global_position - source_position).normalized()
	# Regulate vertical angle.
	_knockback_direction.y -= knockback_angle_correction
	_knockback_direction = _knockback_direction.normalized()
	_knockback_force_multiplier = knockback_force_multiplier
	
	# Applies exported timer parameters
	knockback_timer.wait_time = knockback_duration
	knockback_timer.start()
#endregion
