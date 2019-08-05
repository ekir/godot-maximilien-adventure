"""
Dialogue Box. Manage npc_name and send dialogue sentenes to dialogue text.
@Class DialogueBox
"""
extends Control
class_name DialogBox
tool

# switch to next sentence
signal next_dialogue_text_sentence

export (String) var npc_name = 'NAME'
export (String) var dialog_key = 'DIALOGUE_PLACEHOLDER'

# editor
var editor_previous_dialog_key: String = 'DIALOGUE_PLACEHOLDER'
var editor_previous_npc_name: String = 'NAME'
var is_dialogue_finished: bool = false setget set_is_dialogue_finished, get_is_dialogue_finished


func _ready():
	var dialogue_text := $PanelContainer/VBoxContainer/Text
	
	dialogue_text.connect('dialogue_text_completed', self, '_on_Dialogue_text_completed')
	self.connect('next_dialogue_text_sentence', dialogue_text, '_on_Next_sentence')
	
	set_dialogue_value(TranslationServer.translate(npc_name), TranslationServer.translate(dialog_key))
	$Inputs.start_timer()


"""
Does dialogue text has displayed all sentences ?
"""
func _on_Dialogue_text_completed() -> void:
	set_is_dialogue_finished(true)


func set_is_dialogue_finished(finished: bool) -> void:
	is_dialogue_finished = finished


func get_is_dialogue_finished() -> bool:
	return is_dialogue_finished

"""
Update DialogueBox element in editor mode
@param {float} delta
"""
#warning-ignore:unused_argument
func _process(delta) -> void:
	if Engine.editor_hint:
		if editor_previous_dialog_key != dialog_key or editor_previous_npc_name != npc_name:
			editor_previous_dialog_key = dialog_key
			editor_previous_npc_name = npc_name
			set_dialogue_value(npc_name, TranslationServer.translate(dialog_key))


"""
Set npc name and send translated sentences to dialogue text
@param {string} new_npc_name
@param {string} new_dialogue_key
"""
func set_dialogue_value(new_npc_name: String, new_dialog_key: String) -> void:
	npc_name = new_npc_name
	dialog_key = new_dialog_key
	$PanelContainer/VBoxContainer/Name.text = TranslationServer.translate(npc_name)
	$PanelContainer/VBoxContainer/Text.init(TranslationServer.translate(dialog_key))


"""
Update inputs fording when this is the last dialogue to be displayed
"""
func last_dialogue() -> void:
	$Inputs.action = 'CLOSE'


"""
Next dialogue text sentence
"""
func next_sentence() -> void:
	emit_signal('next_dialogue_text_sentence')


"""
Show this dialogue box
"""
func show() -> void:
	$AnimationPlayer.play('Show')
	emit_signal('next_dialogue_text_sentence')


"""
Hide this dialogue box
"""
func hide() -> void:
	$AnimationPlayer.play('Hide')