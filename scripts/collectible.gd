extends Area2D

signal taken(points: int)

const FLOAT_DISTANCE := 8.0
const FLOAT_SPEED := 3.0

@onready var visuals: Node2D = $Visuals

var base_position := Vector2.ZERO
var elapsed := 0.0
var collected := false


func _ready() -> void:
	base_position = position
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	elapsed += delta
	position.y = base_position.y + sin(elapsed * FLOAT_SPEED) * FLOAT_DISTANCE
	visuals.rotation = sin(elapsed * 2.0) * 0.15


func _on_body_entered(body: Node) -> void:
	if collected or not (body is CharacterBody2D):
		return

	collected = true
	monitoring = false
	visible = false
	taken.emit(10)
	queue_free()
