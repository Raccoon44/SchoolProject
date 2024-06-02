extends KinematicBody2D

#Basic Movement and Gravity
const up = Vector2(0,-1)
const gravity = 20
const maxFallSpeed = 200
const maxSpeed = 75
export var moveDirection = 1
#Knockback
var knockbackDirection
var direction
var knockbacked = false
var playerKnockbackSide #Player
#Health and Damage
export var health = 50
export var attackDamage = 20
var dead = false

var motion = Vector2()

func _ready():
	add_to_group("Enemy")

var playerDetected = false
var playerSide

# warning-ignore:unused_argument
func _physics_process(delta):
	#Gravity
	motion.y += gravity
	if motion.y > maxFallSpeed:
		motion.y = maxFallSpeed

	#Basic movement
	if is_on_floor() == true and knockbacked == false and playerDetected == false and dead == false:
		$AnimationPlayer.play("Walk")
		motion.x = maxSpeed * moveDirection

	if knockbacked == true:
		motion.x = lerp(motion.x, 0, 0.775)
	
	#Wall Turn Around
	if is_on_wall() == true and playerDetected == false:
		moveDirection = moveDirection * -1
		yield(get_tree().create_timer(0.1), "timeout")

	motion = move_and_slide(motion,up)

	#Animations
	if moveDirection == 1:
		transform.x.x = 1
	elif moveDirection == -1:
		transform.x.x = -1
	
	#Death and Animation
	if health <= 0:
		dead = true
	
	if dead == true:
		$AnimationPlayer.play("Death")
		motion.x = lerp(motion.x, 0, 0.775)
	
	#Knockback
	if knockbacked == true:
		if Player.attackDamage == 10: #Hit by Light Attack
			motion.x = 400 * knockbackDirection
			$AnimationPlayer.play("Hit")
			yield(get_tree().create_timer(0.3), "timeout")
			knockbacked = false
		if Player.attackDamage == 30: #Hit by Heavy Attack
			motion.x = 600 * knockbackDirection
			$AnimationPlayer.play("Hit")
			yield(get_tree().create_timer(0.6), "timeout")
			knockbacked = false
		if playerDetected == false: #Hit While Unalert
			playerDetected = true
			moveDirection = moveDirection * -1
			playerSide = moveDirection

	#Alert Chase
	if playerDetected == true and is_on_floor() == true and knockbacked == false and dead == false:
		$AnimationPlayer.play("Walk")
		motion.x = maxSpeed * 2 * playerSide

func _on_KnockbackLeft_body_entered(body): #Knockback to Left
	if body.is_in_group("Player"):
		if moveDirection == 1:
			BasicEnemy.playerKnockbackSide = -1
		elif moveDirection == -1:
			BasicEnemy.playerKnockbackSide = 1

func _on_KnockbackRight_body_entered(body): #Knockback to Right
	if body.is_in_group("Player"):
		if moveDirection == 1:
			BasicEnemy.playerKnockbackSide = 1
		elif moveDirection == -1:
			BasicEnemy.playerKnockbackSide = -1

#Detect Player
func _on_DetectPlayer_body_entered(body):
	if body.is_in_group("Player"):
		for body in $DetectPlayer.get_overlapping_bodies():
			playerSide = moveDirection
			playerDetected = true
	else:
		playerDetected = false

#Ledge Turn Around
func _on_LedgeCheck_body_exited(body):
	if playerDetected == false:
		moveDirection = moveDirection * -1
		yield(get_tree().create_timer(0.1), "timeout")
