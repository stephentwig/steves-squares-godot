extends CharacterBody2D

signal fell_out_of_world

const SPEED := 300.0
const JUMP_VELOCITY := -560.0

@onready var visuals: Node2D = $Visuals

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)

	if is_on_floor() and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")):
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	_update_facing(direction)

	var viewport_width := get_viewport_rect().size.x
	global_position.x = clamp(global_position.x, 20.0, viewport_width - 20.0)

	if global_position.y > 860.0:
		fell_out_of_world.emit()


func respawn(at_position: Vector2) -> void:
	global_position = at_position
	velocity = Vector2.ZERO


func _update_facing(direction: float) -> void:
	if direction > 0.0:
		visuals.scale.x = 1.0
	elif direction < 0.0:
		visuals.scale.x = -1.0
