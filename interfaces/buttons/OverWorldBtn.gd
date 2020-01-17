"""
Should load overworld scene on press
"""
extends Button


func _ready():
	connect('pressed', self, '_on_Pressed')
	text = TranslationServer.translate(text)


"""
@signal pressed
"""
func _on_Pressed() -> void:
	get_tree().paused = false
	LevelManager.goto_scene("res://interfaces/overworld/OverWorld.tscn")