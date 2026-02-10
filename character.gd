extends CharacterBody2D

@export var health : int
@export var damage : int
@export var speed : float

@onready var animation_player := $AnimationPlayer

enum State {IDLE,WALK}

var state = State.IDLE

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animation()
	move_and_slide()

func handle_movement():
	if velocity.length() == 0:
		state = State.IDLE
	else:
		state = State.WALK
		
func handle_input() -> void:
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = direction  * speed
	
func handle_animation() -> void:
	if state == State.IDLE:
		animation_player.play("idle")
	elif state == State.WALK:
		animation_player.play("walk")
