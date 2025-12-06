class_name EnemyCharacter
extends CharacterBody2D

## Enemy horizontal movement speed in px/s
@export var speed : float = 100.0
## Enemy base facing direction. Starts at -1 since enemies face the opposite direction of the player
## by default
@export var direction := -1

## Attack paramers. If turned on, the enemy will attack available targets upon detecting them.
@export_group("Attack")
@export_subgroup("Attacks Player")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "Attacks Player") var attacks_player : bool = false
@export var attack_animation_duration : float = 0.5
@export var attack_length : float = 100.0

## Damage paramers. If turned on, the enemy will able to deal damage 
## to damage-subsceptible entities.
@export_group("Damage")
@export_subgroup("Damages")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "Deals Damage") var damages : bool = false

## Damage paramers. If turned on, the enemy will be able to trigger knockback behaviors 
## on knockback-subsceptible entities.
@export_group("Knockback")
@export_subgroup("Knocks back")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "Knockback To Others") var knocks_back : bool = false
@export var knockback_force_multiplier : float = 1.0

## Private reference to the _attack_tween to make it usable across the class
var _attack_tween : Tween

## Enemy Character's Animated Sprite
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
## Ray Cast used for wall detection
@onready var wall_check_ray_cast: RayCast2D = $WallCheckRayCast
## Ray Cast used for ground detection
@onready var ground_check_ray_cast: RayCast2D = $GroundCheckRayCast
## Area used to detect enemies
@onready var detection_area: Area2D = $DetectionArea



# Physics logic override. Should contain every calculation involving the physics engine.
func _physics_process(delta: float) -> void:
	# Stops physics calculations during attack frames.
	if is_instance_valid(_attack_tween) and _attack_tween.is_running():
		velocity.x = 0
		return
	
	# Flips the enemy along the X-axis when it reaches the edge of a platform or a wall.
	if not ground_check_ray_cast.is_colliding() or wall_check_ray_cast.is_colliding():
		direction *= -1
		flip()
	
	# Calculates X-axis velocity (these enemies aren't able of complex movements)
	velocity.x = speed * direction
	
	# Activates gravity if the enemy falls off a platform
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Necessary to activate movement and collision calculations. Remove it or comment is out to stop them.
	move_and_slide()
	

# Flips the character along its X axis
func flip() -> void:
	scale.x *= -1


## Makes the character execute a charge attack in the enemy facing direction.
func execute_charge_attack() -> void:
		# Calculate the attack end position relative to the enemy facing direction
		var attack_end_relative_position = attack_length * direction
		# Creates a new Tween. Tweens are general-purpose scripted animation objects. 
		# They are are perfect to achieve animations with dynamic values and "fire and forget"
		# scenarios.
		_attack_tween = create_tween()
		# Make the tween move to the relative position in attack_animation_duration time.
		_attack_tween.tween_property(
				self, 
				"position:x",
				attack_end_relative_position,
				attack_animation_duration
		).as_relative().from_current()


## Activates upon a body (Node2D with physics) entering the associated Hitbox Area2D component
func _on_hitbox_body_entered(body: Node2D) -> void:
	# If knockback functionality is enabled, execute it.
	if knocks_back:
		if body.is_in_group("Player") and body.has_method("apply_knockback"):
			body.apply_knockback(global_position, knockback_force_multiplier)
	
	# If damages, forces the player to react to damage
	if damages:
		if body.is_in_group("Player") and body.has_method("take_damage"):
			body.take_damage()


## Activates upon a body (Node2D with physics) entering the associated Detection Area2D component
## Used to trigger attacks
func _on_detection_area_body_entered(body: Node2D) -> void:
	# If attacking player functionality is enabled, execute it.
	if attacks_player and body.is_in_group("Player"):
		execute_charge_attack()


## Activates upon a body (Node2D with physics) LEAVING the associated Detection Area2D component
## Breaks the attack upon losing sight of the player character
func _on_detection_area_body_exited(body: Node2D) -> void:
	if attacks_player and body.is_in_group("Player"):
		_attack_tween.kill()
