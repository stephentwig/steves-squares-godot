extends Node2D

const COLLECTIBLE_SCENE: PackedScene = preload("res://scenes/collectible.tscn")
const PLATFORM_COLOR := Color(0.345098, 0.643137, 0.690196, 1.0)
const PLATFORM_EDGE_COLOR := Color(0.662745, 0.839216, 0.898039, 1.0)

const PLATFORM_DATA := [
	{"position": Vector2(640, 680), "size": Vector2(1280, 80)},
	{"position": Vector2(220, 565), "size": Vector2(220, 24)},
	{"position": Vector2(500, 470), "size": Vector2(220, 24)},
	{"position": Vector2(795, 375), "size": Vector2(220, 24)},
	{"position": Vector2(1060, 280), "size": Vector2(180, 24)},
	{"position": Vector2(330, 350), "size": Vector2(170, 24)},
	{"position": Vector2(120, 255), "size": Vector2(170, 24)}
]

const COLLECTIBLE_POSITIONS := [
	Vector2(190, 600),
	Vector2(220, 515),
	Vector2(500, 420),
	Vector2(795, 325),
	Vector2(1060, 230),
	Vector2(120, 205)
]

@onready var player: CharacterBody2D = $Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var platform_container: Node2D = $Platforms
@onready var collectible_container: Node2D = $Collectibles
@onready var score_label: Label = $CanvasLayer/HUD/MarginContainer/VBoxContainer/ScoreLabel
@onready var status_label: Label = $CanvasLayer/HUD/MarginContainer/VBoxContainer/StatusLabel

var score := 0
var collected_count := 0
var total_collectibles := COLLECTIBLE_POSITIONS.size()


func _ready() -> void:
	_build_platforms()
	player.fell_out_of_world.connect(_on_player_fell_out_of_world)
	restart_level()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == Key.KEY_R:
		restart_level()


func restart_level() -> void:
	score = 0
	collected_count = 0

	for child in collectible_container.get_children():
		child.free()

	for collectible_position in COLLECTIBLE_POSITIONS:
		var collectible := COLLECTIBLE_SCENE.instantiate()
		collectible.position = collectible_position
		collectible.taken.connect(_on_collectible_taken)
		collectible_container.add_child(collectible)

	player.respawn(player_spawn.global_position)
	_update_score_label()
	_update_status_label()


func _build_platforms() -> void:
	if platform_container.get_child_count() > 0:
		return

	for platform_data in PLATFORM_DATA:
		var platform := StaticBody2D.new()
		var size: Vector2 = platform_data["size"]
		var shape := CollisionShape2D.new()
		var rectangle_shape := RectangleShape2D.new()
		var fill := Polygon2D.new()
		var edge := Polygon2D.new()

		platform.position = platform_data["position"]
		platform_container.add_child(platform)

		rectangle_shape.size = size
		shape.shape = rectangle_shape
		platform.add_child(shape)

		fill.color = PLATFORM_COLOR
		fill.polygon = PackedVector2Array([
			Vector2(-size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.5, size.y * 0.5)
		])
		platform.add_child(fill)

		edge.color = PLATFORM_EDGE_COLOR
		edge.polygon = PackedVector2Array([
			Vector2(-size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, -size.y * 0.2),
			Vector2(-size.x * 0.5, -size.y * 0.2)
		])
		platform.add_child(edge)


func _on_collectible_taken(points: int) -> void:
	score += points
	collected_count += 1
	_update_score_label()
	_update_status_label()


func _on_player_fell_out_of_world() -> void:
	player.respawn(player_spawn.global_position)
	status_label.text = "Back to the start. %d of %d squares collected." % [collected_count, total_collectibles]


func _update_score_label() -> void:
	score_label.text = "Score: %d" % score


func _update_status_label() -> void:
	if collected_count >= total_collectibles:
		status_label.text = "All squares collected. Press R to play again."
	else:
		status_label.text = "Collect %d more squares." % (total_collectibles - collected_count)
