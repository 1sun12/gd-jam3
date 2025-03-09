extends CharacterBody2D

# PRIVATE VARIABLES
# =======================================================================
# controls the speed at which the player walks
const _SPEED: int = 100
# determines how many hits the player can take before dying
const _HEALTH: float = 100.0

# PUBLIC VARIABLES
# =======================================================================
var direction: Vector2 = Vector2(0,0)

# PRIVATE FUNCTIONS
# =======================================================================
# logic for movement and user-input
func _char_controls(delta):
	# adjust the velocity property on the CharacterBody2D which...
	# affects the move_and_slide() operation below
	velocity = _SPEED * direction
	# call move_and_slide() to apply physics and move the character
	move_and_slide()
	_char_controls_anims()

# logic for movement animations
func _char_controls_anims():
	# holds last movement, to help display the right idle anim.
	var last_dir: Vector2 = Vector2(0,0)
	# round the x and y value to 1, 0, or -1
	var rounded_dir: Vector2 = Vector2(round(direction.x), round(direction.y))
	# handle the 0.7 and -0.7 special case
	if abs(rounded_dir.x) > 0.5 && abs(rounded_dir.y) > 0.5:
		rounded_dir.x = 1.0 if direction.x > 0 else -1.0
		rounded_dir.y = 1.0 if direction.y > 0 else -1.0
	
	match rounded_dir:
		# normal movements
		# =======================================================================
		Vector2(0,-1):
			%AnimatedSprite2D.play("u_walk") # walk up
		Vector2(0,1):
			%AnimatedSprite2D.play("d_walk") # walk down
		Vector2(1,0):
			%AnimatedSprite2D.flip_h = true
			%AnimatedSprite2D.play("s_walk") # walk right
		Vector2(-1,0):
			%AnimatedSprite2D.flip_h = false
			%AnimatedSprite2D.play("s_walk") # walk left
		# diag movements
		# =======================================================================
		Vector2(1,-1):
			%AnimatedSprite2D.flip_h = true
			%AnimatedSprite2D.play("s_walk") # walk right (up)
		Vector2(-1, -1):
			%AnimatedSprite2D.flip_h = false
			%AnimatedSprite2D.play("s_walk") # walk left (up)
		Vector2(1, 1):
			%AnimatedSprite2D.flip_h = true
			%AnimatedSprite2D.play("s_walk") # walk right (down)
		Vector2(-1, 1):
			%AnimatedSprite2D.flip_h = false
			%AnimatedSprite2D.play("s_walk") # walk left (down)
		_: # default case; idle anims.
			%AnimatedSprite2D.play("d_idle")
	
# READY & PROCESS
# =======================================================================
func _physics_process(delta):
	# collect data from keyboard inputs to associate which dir. the...
	# ...the player is moving in
	direction = Input.get_vector("m_left", "m_right", "m_up", "m_down")
	print(direction)
	_char_controls(delta)
	
	
