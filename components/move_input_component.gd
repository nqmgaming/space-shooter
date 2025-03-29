class_name MoveInputComponent
extends Node

@export var move_component: MoveComponent
@export var move_stats: MoveStats

func _input(event: InputEvent) -> void:
	var input_axis = Input.get_axis("ui_left", "ui_right")
	
	move_component.velocity = Vector2(input_axis * move_stats.spped, 0)
	
