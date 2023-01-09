extends CSGBox

# length of the ray used for mouse point tracing (must be > 100)
const RAY_LENGTH = 500

export(NodePath) var zoom_min_path
export(NodePath) var zoom_max_path

export(float) var zoom = 1.0
export(float) var min_zoom = 0.1
export(float) var max_zoom = 1.0
export(float) var min_fov = 70.0
export(float) var max_fov = 50.0

onready var zoom_min = get_node(zoom_min_path)
onready var zoom_max = get_node(zoom_max_path)

# whether the primary mouse button is currently pressed
var mouse_pressed = false

# last known position of the mouse on the screen
var mouse_pos: Vector2

# for dragging, last known position on the world's floor
var start_dragging_pos  # type: Vector3

# for dragging, the start Y position of the camera
var drag_start_angle = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	recompute_zoom()


func _physics_process(delta):
	if mouse_pressed:
		var current_pos = _cast_ray_to_floor(mouse_pos)
		if current_pos == null:
			return
		current_pos = current_pos.rotated(Vector3(0, 1, 0), -$ViewAnchor.rotation.y)
		if start_dragging_pos == null:
			start_dragging_pos = current_pos
			drag_start_angle = $ViewAnchor.rotation.y
			return
		var start_angle = atan2(start_dragging_pos.z, start_dragging_pos.x)
		var current_angle = atan2(current_pos.z, current_pos.x)
		var diff = start_angle - current_angle
		$ViewAnchor.rotation.y = drag_start_angle - diff
	else:
		start_dragging_pos = null


func _cast_ray_to_floor(position: Vector2): # -> Optional<Vector3>
	var camera = $ViewAnchor/PlayerView
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * RAY_LENGTH
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(to, from, [], 2, false, true)
	
	if not result.empty():
		return result["position"]
	return null


func _input(event):
	if event is InputEventScreenPinch:
		zoom += event.relative * 0.001
		recompute_zoom()
	
	if event is InputEventScreenDrag:
		mouse_pos = event.position
	
	if event is InputEventScreenTouch:
		if event.index == 0:
		#if not event.pressed:
			mouse_pressed = event.pressed
		#elif event.index == 0 and event.pressed:
			mouse_pos = event.position

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		mouse_pressed = event.pressed
		mouse_pos = event.position


func recompute_zoom():
	if zoom > max_zoom:
		zoom = max_zoom
	if zoom < min_zoom:
		zoom = min_zoom

	var t = 1.0 - zoom
	t = t * t
	
	var a = Quat(zoom_min.transform.basis)
	var b = Quat(zoom_max.transform.basis)
	$ViewAnchor/PlayerView.fov = lerp(min_fov, max_fov, t)
	
	$ViewAnchor/PlayerView.transform.origin = Vector3(
		lerp(zoom_min.transform.origin.x, zoom_max.transform.origin.x, t),
		lerp(zoom_min.transform.origin.y, zoom_max.transform.origin.y, t * t),
		lerp(zoom_min.transform.origin.z, zoom_max.transform.origin.z, t)
	)
	$ViewAnchor/PlayerView.transform.basis = Basis(a.cubic_slerp(b, a, b, t))
