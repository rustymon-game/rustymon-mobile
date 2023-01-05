extends CSGBox

# for scrolling, the highest (max) value; the min value is zero
const MAX_SCROLLING = 36

# length of the ray used for mouse point tracing (must be > 100)
const RAY_LENGTH = 300

# whether the primary mouse button is currently pressed
var mouse_pressed = false

# last known position of the mouse on the screen
var mouse_pos: Vector2

# for dragging, last known position on the world's floor
var start_dragging_pos  # type: Vector3

# for dragging, the start Y position of the camera
var drag_start_angle = 0

# for scrolling, the current scroll level
var current_scrolling = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


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
		if event.relative < 0:
			if current_scrolling < MAX_SCROLLING:
				current_scrolling += 1
				$ViewAnchor.translation.y += 0.5
				$ViewAnchor/PlayerView.rotation_degrees.x -= 0.5
		elif event.relative > 0:
			if current_scrolling > 0:
				current_scrolling -= 1
				$ViewAnchor.translation.y -= 0.5
				$ViewAnchor/PlayerView.rotation_degrees.x += 0.5
	
	if event is InputEventScreenDrag:
		mouse_pos = event.position
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		mouse_pressed = event.pressed
		mouse_pos = event.position
		if not event.pressed:
			drag_start_angle = $ViewAnchor.rotation.y
