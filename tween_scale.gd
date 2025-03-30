extends Node


@onready var tween: Tween = Tween.new()

func _ready() -> void:
	add_child(tween)  # Thêm Tween vào scene
	tween.start()  # Bắt đầu Tween
