extends CharacterBody3D

func is_between(value: int, min: int, max: int) -> bool:
	return value >= min and value <= max

const JUMP_VELOCITY = 6

const MOVE_SCALE = 100
const MOVE_SPEED = 5
var remaining_move : Array[float]
var is_moving : bool = false

const ROTATION_SCALE = 90
const ROTATION_SPEED = 5
var remaining_rotation : float
var is_rotating : bool = false


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Move
	if is_moving:
		if remaining_move[0] < MOVE_SPEED * delta:
			
		self.position.x += MOVE_SPEED * delta
		self.position.z += MOVE_SPEED * delta
		remaining_move[0] -= MOVE_SPEED * delta
		remaining_move[1] -= MOVE_SPEED * delta
	elif is_rotating:
		self.rotation.y += remaining_rotation * ROTATION_SPEED * delta
		remaining_rotation -= remaining_rotation * ROTATION_SPEED * delta

	var direction := (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		self.position.x += direction.x * SPEED
		self.position.z += direction.z * SPEED

	# Direction inputs
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	move_and_slide()
