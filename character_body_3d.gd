extends CharacterBody3D

const CUSTOM_GRAVITY = -40.0
const JUMP_VELOCITY = 20

const MOVE_SCALE = 10
const MOVE_SPEED = 10

const ROTATION_SPEED = 4
const ROTATION_THRESHOLD = 0.1

var remaining_move : Vector2
var move_normed : Vector2
var is_moving : bool = false

var remaining_rotation : float
var is_rotating : bool = false

@onready var anim_player = $Barbarian/Animations

func set_move(input_dir: Vector2) -> void:
	if input_dir.x:
		remaining_move.x = input_dir.x * MOVE_SCALE
	if input_dir.y:
		remaining_move.y = input_dir.y * MOVE_SCALE
	anim_player.play("Walking_B")
	is_moving = true
	move_normed = remaining_move.normalized()

func move_player(delta: float) -> bool:
	# x-axis : negative way
	if remaining_move.x < 0:
		if remaining_move.x < move_normed.x * MOVE_SPEED * delta:
			self.position.x += move_normed.x * MOVE_SPEED * delta
			remaining_move.x -= move_normed.x * MOVE_SPEED * delta
		else:
			self.position.x += remaining_move.x
			remaining_move.x = 0
	# x-axis : positive way
	if remaining_move.x > 0:
		if remaining_move.x > move_normed.x * MOVE_SPEED * delta:
			self.position.x += move_normed.x * MOVE_SPEED * delta
			remaining_move.x -= move_normed.x * MOVE_SPEED * delta
		else:
			self.position.x += remaining_move.x
			remaining_move.x = 0
	
	# z-axis : negative way
	if remaining_move.y < 0:
		if remaining_move.y < move_normed.y * MOVE_SPEED * delta:
			self.position.z += move_normed.y * MOVE_SPEED * delta
			remaining_move.y -= move_normed.y * MOVE_SPEED * delta
		else:
			self.position.z += remaining_move.y
			remaining_move.y = 0
	# z-axis : positive way
	if remaining_move.y > 0:
		if remaining_move.y > move_normed.y * MOVE_SPEED * delta:
			self.position.z += move_normed.y * MOVE_SPEED * delta
			remaining_move.y -= move_normed.y * MOVE_SPEED * delta
		else:
			self.position.z += remaining_move.y
			remaining_move.y = 0
	
	if remaining_move.x == 0 && remaining_move.y == 0:
		is_moving = false
		anim_player.stop()
		return true
	return false

func must_rotate(input_dir : Vector2) -> bool:
	var input_degree : float = atan2(input_dir.y, -input_dir.x)
	var self_degree : float = self.rotation.y
	if input_degree < 0:
		input_degree += 2 * PI
	if self_degree < 0:
		self_degree += 2 * PI
	
	if self_degree - ROTATION_THRESHOLD <= input_degree \
		&& input_degree <= self_degree + ROTATION_THRESHOLD:
		return false
	is_rotating = true
	
	var clockwise_diff = input_degree - self_degree
	var counterclockwise_diff = self_degree - input_degree
	if clockwise_diff < 0:
		clockwise_diff += 2 * PI
	if counterclockwise_diff < 0:
		counterclockwise_diff += 2 * PI

	if clockwise_diff < counterclockwise_diff:
		remaining_rotation = clockwise_diff
	else:
		remaining_rotation = -counterclockwise_diff

	anim_player.play("Walking_B")
	return true

func rotate_player(delta: float) -> void:
	# y-axis : negative way
	if remaining_rotation < 0:
		if remaining_rotation < -ROTATION_SPEED * delta:
			self.rotation.y -= ROTATION_SPEED * delta
			remaining_rotation += ROTATION_SPEED * delta
		else:
			self.rotation.y -= remaining_rotation
			remaining_rotation = 0
	# y-axis : positive way
	elif remaining_rotation > 0:
		if remaining_rotation > ROTATION_SPEED * delta:
			self.rotation.y += ROTATION_SPEED * delta
			remaining_rotation -= ROTATION_SPEED * delta
		else:
			self.rotation.y += remaining_rotation
			remaining_rotation = 0
	
	if abs(remaining_rotation) < ROTATION_THRESHOLD:
		self.rotation.y = round(self.rotation.y / (PI / 2)) * (PI / 2)
		remaining_rotation = 0
		is_rotating = false
		anim_player.stop()

func next_action(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		if not must_rotate(input_dir):
			set_move(input_dir)
			move_player(delta)
		else:
			rotate_player(delta)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += CUSTOM_GRAVITY * delta
	
	# Jump
	if Input.is_action_just_pressed("ui_space") and is_on_floor() and is_moving == false:
		velocity.y = JUMP_VELOCITY
		anim_player.play("Jump_Start")
	
	# Land
	if velocity.y < 0 && self.position.y > 0 && self.position.y < 8:
		anim_player.play("Jump_Land")
	
	# Move or rotate
	if is_on_floor():
		if is_moving:
			move_player(delta)
		elif is_rotating:
			rotate_player(delta)
		else:
			next_action(delta)
	
	# Apply velocity
	move_and_slide()
