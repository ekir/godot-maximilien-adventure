extends Area2D

export (int) var value = 1

func _ready() -> void:
	connect('body_entered', self, '_on_Player_enter')
	if not ProjectSettings.get_setting('Debug/sound'):
		$AudioStreamPlayer.stream = null
	$AnimationPlayer.play('Idle')


func _on_Player_enter(body: Player) -> void:
	assert body is Player
	GameManager.set_score(value)
	$AnimationPlayer.play('Collected')
	$AudioStreamPlayer.play()
	disconnect('body_entered', self, '_on_Player_enter')
	get_parent().call_deferred('remove_child', self)
	body.call_deferred('add_child', self)
	