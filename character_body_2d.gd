extends CharacterBody2D


const SPEED = 800.0
const JUMP_VELOCITY = -1150.0
const ULTRA_JUMP_VELOCITY = -1400.0

@export var tree_scene: PackedScene

@export var max_trees: int = 6
var planted_trees_count: int = 0

@export var enforce_boundaries: bool = true
@export var min_x: float = -1000.0
@export var max_x: float = 7000.0
@export var min_y: float = -1200.0
@export var max_y: float = 1700.0

@onready var GroundDetector: RayCast2D = $GroundDetector
@onready var winner_text_label: Label = $winnerText
@onready var plant_sound: AudioStreamPlayer2D = $plantsound
@onready var win_sound: AudioStreamPlayer2D = $winner
@onready var jump_sound: AudioStreamPlayer2D = $jumpsound


func _ready() -> void:
	if winner_text_label != null:
		winner_text_label.text = ""


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if jump_sound != null:
			jump_sound.play()

	# ultra jump to jump higher.
	if Input.is_action_just_pressed("ultrajump") and is_on_floor():
		velocity.y = ULTRA_JUMP_VELOCITY
		if jump_sound != null:
			jump_sound.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)

	move_and_slide()

	if enforce_boundaries:
		global_position.x = clamp(global_position.x, min_x, max_x)
		global_position.y = clamp(global_position.y, min_y, max_y)

	if Input.is_action_just_pressed("interact"):
		plant_tree()


func plant_tree() -> void:
	if planted_trees_count >= max_trees:
		return

	if is_on_floor() and GroundDetector.is_colliding() and tree_scene != null:
		var tree_instance = tree_scene.instantiate()
		tree_instance.global_position = global_position
		get_parent().add_child(tree_instance)

		planted_trees_count += 1

		if plant_sound != null:
			plant_sound.play()

		if planted_trees_count == max_trees:
			if winner_text_label != null:
				winner_text_label.show()
				winner_text_label.position = Vector2(-300, -200)
				winner_text_label.text = "Congratulations! You are an arborist now."
			if win_sound != null:
				win_sound.play()

			
			await get_tree().create_timer(7.0).timeout
			get_tree().quit()
