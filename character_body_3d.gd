extends CharacterBody3D

const CUSTOM_GRAVITY = -40.0
const JUMP_VELOCITY = 20
const MOVE_SCALE = 10
const MOVE_SPEED = 15
const ROTATION_SCALE = 90
const ROTATION_SPEED = 200

var remaining_move : Vector2
var move_normed : Vector2
var is_moving : bool = false

var remaining_rotation : float
var is_rotating : bool = false

var anim_player

func _ready():
	# Get the AnimationPlayer node when the scene starts
	anim_player = $Barbarian/Animations

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
	var input_degree : int = round(rad_to_deg(atan2(input_dir.y, -input_dir.x)))
	var self_degree : int = round(rad_to_deg(self.rotation.y))
	input_degree = (input_degree + 360) % 360
	self_degree = (self_degree + 360) % 360
	
	if input_degree == self_degree:
		return false
	is_rotating = true
	
	var clockwise_diff = ((input_degree - self_degree) + 360) % 360
	var counterclockwise_diff = ((self_degree - input_degree) + 360) % 360
	
	print(clockwise_diff, " // ", counterclockwise_diff)
	if clockwise_diff < counterclockwise_diff:
		remaining_rotation = clockwise_diff
	else:
		remaining_rotation = -counterclockwise_diff
	return true

func rotate_player(delta: float) -> void:
	# y-axis : negative way
	if remaining_rotation < 0:
		if remaining_rotation < -ROTATION_SPEED * delta:
			self.rotation.y -= deg_to_rad(ROTATION_SPEED * delta)
			remaining_rotation += ROTATION_SPEED * delta
		else:
			self.rotation.y -= deg_to_rad(remaining_rotation)
			remaining_rotation = 0
	# y-axis : positive way
	else:
		if remaining_rotation > ROTATION_SPEED * delta:
			self.rotation.y += deg_to_rad(ROTATION_SPEED * delta)
			remaining_rotation -= ROTATION_SPEED * delta
		else:
			self.rotation.y += deg_to_rad(remaining_rotation)
			remaining_rotation = 0
	
	if remaining_rotation == 0:
		is_rotating = false

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += CUSTOM_GRAVITY * delta
	
	# Jump
	if Input.is_action_just_pressed("ui_space") and is_on_floor() and is_moving == false:
		velocity.y = JUMP_VELOCITY
		anim_player.play("Jump_Start")
	
	# Landing
	if velocity.y < 0 && self.position.y > 0 && self.position.y < 8:
		anim_player.play("Jump_Land")
	
	if is_on_floor():
		var move_done : bool = false
		# Move
		if is_moving:
			move_done = move_player(delta)
		# Rotate
		elif is_rotating:
			rotate_player(delta)
		else:
			var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			if input_dir:
				if not must_rotate(input_dir):
					set_move(input_dir)
					move_player(delta)
				else:
					rotate_player(delta)
	
	move_and_slide()
