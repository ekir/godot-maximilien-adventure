extends Control

const TIPS_PREFIX = 'TIPS_'
const MAX_TIPS = 2

var rng = RandomNumberGenerator.new()


func _ready():
	UiManager.connect('ui_loose_life_show', self, '_on_Show')
	_generate_tips()


func _generate_tips() -> void:
	rng.randomize()
	var id:int = rng.randi_range(0, MAX_TIPS)
	$PanelContainer/VBoxContainer/TipsText.text = TranslationServer.translate(TIPS_PREFIX + str(id))


func _on_Show() -> void:
	$AnimationPlayer.play('TransitionIn')
	show()


func _remove_life() -> void:
	$LifeIndicator.get_child($LifeIndicator.get_child_count()-1).get_node('AnimationPlayer').connect('animation_finished', self, '_on_Life_animation_finish')	
	$LifeIndicator.get_child($LifeIndicator.get_child_count()-1).get_node('AnimationPlayer').play('FadeOut')


func reset_player() -> void:
	GameManager.player_loose_life()
	PlayerManager.retry_level()


func _close() -> void:
	PlayerManager.input_enable()
	UiManager.hide_lost_a_life_screen()
	hide()


func _on_Life_animation_finish(anim_name: String) -> void:
	assert anim_name == 'FadeOut'
	$AnimationPlayer.play('TransitionOut')