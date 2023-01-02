extends CSGBox

# radius in pixels around the player where initial touch events for screen drag are ignored
const DEAD_RADIUS = 100

# delta to the field of view (FOV) for the camera when pinching (zooming with two fingers or mouse wheel)
const FOV_CHANGE = 1.0

# the rotation of the ViewAnchor when the drag started
var previous_rotation = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventScreenPinch:
		if event.relative > 0:
			$ViewAnchor/PlayerView.fov += FOV_CHANGE
		elif event.relative < 0:
			$ViewAnchor/PlayerView.fov -= FOV_CHANGE
	
	if event is InputEventScreenDrag:
		var pos_x = event.position[0]
		var pos_y = event.position[1]
		
		var center_x = OS.get_real_window_size()[0] / 2
		var center_y = OS.get_real_window_size()[1] / 2
		
		var diff_x = center_x - pos_x
		var diff_y = center_y - pos_y
		var distance = sqrt(diff_x * diff_x + diff_y * diff_y)
		
		if distance > DEAD_RADIUS:
			var alpha = sin(diff_y / distance)
			#print("alpha=", alpha, " diff_y=", diff_y, " distance=", distance, " frac=", diff_y / distance)
		
			if pos_x > center_x:
				if pos_y < center_y:
					# upper right
					$ViewAnchor.rotation.y = -alpha * PI / 2 + previous_rotation
				if pos_y > center_y:
					# lower right
					$ViewAnchor.rotation.y = -alpha * PI / 2 + previous_rotation
					
			elif pos_x < center_x:
				if pos_y < center_y:
					# upper left
					$ViewAnchor.rotation.y = alpha * PI / 2 + PI + previous_rotation
				if pos_y > center_y:
					# lower left
					$ViewAnchor.rotation.y = alpha * PI / 2 + PI + previous_rotation
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			previous_rotation = $ViewAnchor.rotation.y
