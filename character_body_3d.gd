extends CharacterBody3D

const CUSTOM_GRAVITY = -40.0
const JUMP_VELOCITY = 20
const MOVE_SCALE = 10
const MOVE_SPEED = 15
const ROTATION_SCALE = 90
const ROTATION_SPEED = 50

var remaining_move : Vector2
var move_normed : Vector2
var is_moving : bool = false

var remaining_rotation : float
var is_rotating : bool = false

var anim_player

func _ready():
	# Get the AnimationPlayer node when the scene starts
	anim_player = $Barbarian/Animations

func move(delta: float) -> bool:
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

	# Still a remaining_move to do ?
	if remaining_move[0] == 0 && remaining_move[1] == 0:
		is_moving = false
		remaining_move.x = 0
		remaining_move.y = 0
		anim_player.stop()
		return true
	return false

func must_rotate(input_dir : Vector2) -> bool:
	return false

func set_move(input_dir: Vector2) -> void:
	if input_dir.x:
		remaining_move.x = input_dir.x * MOVE_SCALE
	if input_dir.y:
		remaining_move.y = input_dir.y * MOVE_SCALE
	anim_player.play("Walking_B")
	is_moving = true
	move_normed = remaining_move.normalized()

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += CUSTOM_GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and is_moving == false:
		velocity.y = JUMP_VELOCITY
		anim_player.play("Jump_Start")
		print(1)

	# Landing
	if velocity.y < 0 && self.position.y > 0 && self.position.y < 8:
		anim_player.play("Jump_Land")
		print(2)

	# Move
	if is_on_floor():
		var MOVE_DONE : bool = false
		if is_moving:
			MOVE_DONE = move(delta)
		elif not is_rotating || MOVE_DONE == true:
			var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			if input_dir && not must_rotate(input_dir):
				set_move(input_dir)
				move(delta)

	move_and_slide()
