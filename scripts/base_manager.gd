class_name BaseManager
extends Node2D

var managed_items : Array[PackedScene] = []
var checkpoint_items : Array[PackedScene] = []


#region initial setup
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Save initial state of all children for level reset
	for child in get_children():
		var p_scene = PackedScene.new()
		p_scene.pack(child) 
		managed_items.append(p_scene)
#endregion


## Resets collectible in the level to their initial (to_checkpoint == false) or 
## saved (to_checkpoint == true) state, provided they were children of this node.
func reset_items(to_checkpoint : bool = false) -> void:
	var item_blueprints : Array[PackedScene]
	
	# If a checkpoint reset was asked
	if to_checkpoint:
		item_blueprints = checkpoint_items
	# If a total reset was asked
	else:
		item_blueprints = managed_items
		
	# Clear current collectibles
	for child in get_children():
		child.queue_free()
	
	# Repopulates with the selected items
	_repopulate(item_blueprints)


## Saves the item scenes into the checkpoint data for future restoration.
func save_item_checkpoint() -> void:
	checkpoint_items.clear()
	for child in get_children():
		var p_scene = PackedScene.new()
		p_scene.pack(child) 
		checkpoint_items.append(p_scene)


# Repopulates the scene children using the provided collection of blueprints
func _repopulate(item_blueprints : Array[PackedScene]) -> void:
	# Repopulate
	for blueprint : PackedScene in item_blueprints:
		var restored_item := blueprint.instantiate()
		add_child(restored_item)
