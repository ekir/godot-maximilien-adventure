extends Character
class_name Player

signal player_position_changed(new_position)
signal player_global_position_changed(new_position)

#warning-ignore:unused_signal
signal player_death

# cache
onready var Physics2D: Node2D = $Physics2D
onready var Hit: Node2D = $Hit

# player params
var previous_position: Vector2 = Vector2.ZERO
var grounded_position: Vector2 = Vector2.ZERO

#warning-ignore:unused_class_variable
var npc_to_talk_position: Vector2 = Vector2.ZERO
#warning-ignore:unused_class_variable
var can_talk: bool = false
#warning-ignore:unused_class_variable
var chest_position: Vector2 = Vector2.ZERO
#warning-ignore:unused_class_variable
var can_open_door: bool = false
#warning-ignore:unused_class_variable
var is_entering_door: bool = false

var is_waiting_for_next_dialogue: bool = false
var can_open_chest: bool = false
var input_enable: bool = true


func _ready() -> void:
	# Signals
	$AnimationPlayer.connect('animation_finished', self, '_on_Animation_finished')
	$Health.connect('take_damage', self, '_on_Getting_hit')
	$Health.connect('health_changed', $UI/PlayerHUD/HealthBar, '_on_Health_changed')
	$Sprite/LastGroundedPositionChecker.connect('body_exited', self, '_on_last_grounded_position_changed')
	$IsOnOneWayPlatform.connect('is_on_one_way_platform', self, '_on_One_way_plaform')
	DialogueManager.connect('end_dialogue', self, '_on_End_dialogue')
	ChestManager.connect('inactive_chest', self, '_on_Inactive_chest')
	DoorManager.connect('teleport', self, '_on_Teleport')

	assert has_node('Camera') == true
	
	# set camera
	CameraManager.set_camera(get_node('Camera'))
	CameraManager.connect('camera_transition_entered', self, '_on_Input_behaviour_change')
	CameraManager.connect('camera_transition_finished', self, '_on_Input_behaviour_change')
	
	# init
	GameManager.set_new_checkpoint(position) 
	PlayerManager.set_player(self)
	._initialize_state()
	
	if ProjectSettings.get_setting('Debug/debug_mode'):
		DebugManager.set_player(self)


""" 
Delegate the call to child
@param {float} delta
"""
func _physics_process(delta: float) -> void:
	current_state.update(self, delta)
	Physics2D.compute_gravity(self, delta)
	if previous_position != position:
		_on_position_changed()
		_on_global_position_changed()
		if ProjectSettings.get_setting('Debug/debug_mode'):
			DebugManager.set_player_velocity(velocity)


""" 
Hurt player
@param {bool} alive
"""
func _on_Getting_hit(alive: bool) -> void:
	is_alive = alive
	Hit.get_hit(self, is_alive)


""" 
Change state in state machine
@param {string} state_name
"""
func _change_state(state_name: String) -> void:
	if ProjectSettings.get_setting('Debug/debug_mode'):
		DebugManager.set_player_state(state_name)
	._change_state(state_name)


""" 
Catch and deleg input to the state machine
@param {InputEvent} event
"""
func _input(event: InputEvent) -> void:
	if input_enable:
		current_state.handle_input(self, event)


"""
Should send the last position where the player was on the ground
@param {PhysicsBody2D} body
"""
#warning-ignore:unused_argument
func _on_last_grounded_position_changed(body: PhysicsBody2D) -> void:
	grounded_position = position
	DebugManager.set_player_respawn(grounded_position)


"""
Teleport player to a new position
eg. When entering a door
@param {Vector2} new_position
"""
func _on_Teleport(new_position: Vector2) -> void:
	global_position = new_position


"""
Block player input
"""
func _on_Input_behaviour_change() -> void:
	input_enable = !input_enable


"""
Get the last player position
"""
func _on_position_changed() -> void:
	previous_position = position
	emit_signal('player_position_changed', position)


"""
Get the last global player position
"""
func _on_global_position_changed() -> void:
	previous_position = position
	emit_signal('player_global_position_changed', get_global_position())


"""
Switch between crouch and stand collision shape
"""
func _toggle_collision_shape() -> void:
	$StandCollisionShape.disabled = !$StandCollisionShape.disabled
	$SlideCollisionShape.disabled = !$SlideCollisionShape.disabled


"""
Player has stop dialoging
"""
func _on_End_dialogue() -> void:
	is_waiting_for_next_dialogue = false


"""
Callback when a player has open a chest and should not be able to
do it again
"""
func _on_Inactive_chest() -> void:
	can_open_chest = false


"""
Can jump through one way platform
@param {bool} value
"""
func _on_One_way_plaform(value: bool) -> void:
	is_on_one_way_platform = value


"""
Cooldown timer
"""
func start_cooldown() -> void:
	$CooldownTimer.start()
	$CooldownBar.start()


"""
Respawn player
"""
func respawn() -> void:
	if is_alive:
		position = grounded_position