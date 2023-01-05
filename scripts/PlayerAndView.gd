extends CSGBox

# radius in pixels around the player where initial touch events for screen drag are ignored
const DEAD_RADIUS = 100

# delta to the field of view (FOV) for the camera when pinching (zooming with two fingers or mouse wheel)
const FOV_CHANGE = 1.0

# TODO
const RAY_LENGTH = 300

# the rotation of the ViewAnchor when the drag started
var previous_rotation = 0.0

# whether the primary mouse button is currently pressed
var mouse_pressed = false

# last known position of the mouse on the screen
var mouse_pos: Vector2

# for dragging, last known position on the world's floor
var start_dragging_pos  # type: Vector3

var drag_start_angle = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	previous_rotation = $ViewAnchor.rotation.y


func _physics_process(delta):
	if mouse_pressed:
		var current_pos = _cast_ray_to_floor(mouse_pos)
		if current_pos == null:
			return
		current_pos = current_pos.rotated(Vector3(0, 1, 0), -$ViewAnchor.rotation.y)
		if start_dragging_pos == null:
			start_dragging_pos = current_pos
			drag_start_angle = atan2(start_dragging_pos.z, start_dragging_pos.x)
			return
		var start_angle = atan2(start_dragging_pos.z, start_dragging_pos.x)
		var current_angle = atan2(current_pos.z, current_pos.x)
		var diff = start_angle - current_angle
		print("prev=", start_angle, " current=", current_angle, " diff=", diff, " rotY=", $ViewAnchor.rotation.y)
		$ViewAnchor.rotation.y = -diff
	else:
		start_dragging_pos = null


func _cast_ray_to_floor(position: Vector2): # -> Optional<Vector3>
	var camera = $ViewAnchor/PlayerView
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * RAY_LENGTH
	# print("ray from ", from, " to ", to, " for ", camera)
	
	var space_state = get_world().direct_space_state
	# use global coordinates, not local to node
	var result = space_state.intersect_ray(from, to, [], 2, false, true)
	
	if not result.empty():
		return result["position"]
	return null


func _input(event):
	if event is InputEventScreenPinch:
		if event.relative > 0:
			$ViewAnchor/PlayerView.fov -= FOV_CHANGE
		elif event.relative < 0:
			$ViewAnchor/PlayerView.fov += FOV_CHANGE
	
	if event is InputEventScreenDrag:
		mouse_pos = event.position	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		previous_rotation = $ViewAnchor.rotation.y
		mouse_pressed = event.pressed
