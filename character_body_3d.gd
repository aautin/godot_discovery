extends CharacterBody3D

func is_between(value: int, min: int, max: int) -> bool:
	return value >= min and value <= max

const SPEED = 0.10
const JUMP_VELOCITY = 6
const ROTATION_SPEED = 10.0  # Adjust rotation speed as needed

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Current and destination angles
	var origin := rad_to_deg(self.rotation.y)
	var destination := rad_to_deg(atan2(input_dir.y, -input_dir.x))
	if destination < 0:
		destination += 360

	# Calculate angle difference
	var angle_difference = fposmod(destination - origin + 360.0, 360.0)
	if angle_difference > 180:
		angle_difference -= 360

	# Rotate smoothly based on angle difference
	if input_dir.length() > 0 && not is_between(angle_difference, 0, ROTATION_SPEED):
		if is_between(angle_difference, 0, 180):
			self.rotation.y += ROTATION_SPEED * delta  # Rotate to the right
		else:
			self.rotation.y -= ROTATION_SPEED * delta  # Rotate to the left
	else:
		# Update movement direction
		var direction := (Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			self.position.x += direction.x * SPEED
			self.position.z += direction.z * SPEED

	move_and_slide()
