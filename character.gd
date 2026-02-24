extends CharacterBody2D
const GRAVITY := 600.0

@export var health : int
@export var damage : int
@export var jump_intensity : float
@export var speed : float

@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter := $DamageEmitter

enum State {IDLE,WALK,ATTACK,TAKEOFF,JUMP,LAND}

var anim_map := {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
}

var height := 0.0
var height_speed := 0.0
var state = State.IDLE

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animation()
	handle_air_time(delta)
	flip_sprites()
	character_sprite.position = Vector2.UP * height
	move_and_slide()

func handle_movement():
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK

		
func handle_input() -> void:
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	if can_jump and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
	
func handle_animation() -> void:
	if animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])
	
		
func handle_air_time(delta:float) -> void:
	if state == State.JUMP:
		height += height_speed * delta
		if height < 0:
			height = 0
			state = State.LAND
		else:
			height_speed -= GRAVITY * delta



func flip_sprites() -> void:
	#facing right
	if velocity.x > 0:
		character_sprite.flip_h = false
		damage_emitter.scale.x = 1
	#facing left	
	elif velocity.x <0:
			character_sprite.flip_h = true
			damage_emitter.scale.x = -1	
func can_move() -> bool:
	return state == State.IDLE or state == State.WALK

func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK

func can_jump() -> bool:
	return state == State.IDLE or  state == State.WALK

func on_action_complete() -> void:
	state = State.IDLE

func on_takeoff_complete() -> void:
	state = State.JUMP
	height_speed = jump_intensity
	
func on_land_complete() -> void:
	state = State.IDLE

func on_emit_damage(damage_receiver:DamageReceiver) -> void:
	var direction := Vector2.LEFT if damage_receiver.global_position.x < global_position.x else Vector2.RIGHT
	
	damage_receiver.damage_received.emit(damage,direction)
	print(damage_receiver)
