extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var move_component: MoveComponent = $MoveComponent as MoveComponent
@onready var scale_component: ScaleComponent = $ScaleComponent as ScaleComponent
@onready var flash_component: FlashComponent = $FlashComponent as FlashComponent

func _ready() -> void:
	scale_component.tween_scale()
	flash_component.flash()
	visible_on_screen_notifier_2d.screen_exited.connect(on_screen_exited)
	
func on_screen_exited() -> void:
	print("Laser exited screen - destroying")
	queue_free()
	
func _process(_delta: float) -> void:
	# As a fallback, manually check if we're outside the screen boundaries
	var screen_size = get_viewport_rect().size
	if global_position.y < -50 or global_position.y > screen_size.y + 50 or \
	   global_position.x < -50 or global_position.x > screen_size.x + 50:
		print("Laser manually detected outside screen - destroying")
		queue_free()
