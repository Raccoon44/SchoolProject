extends KinematicBody2D

class_name PlayerKinematic2D

#Basic Movement and Gravity
const up = Vector2(0,-1)
const gravity = 20
const maxFallSpeed = 200
const maxSpeed = 150
const jumpForce = 400
var lastMotionY = Vector2()
var facingRight = true
var facingDirection = 1
#Knockback
var canControl = true
var knockbackDirection
var direction
var knockbacked
#Health and Damage
var health = 100
var dead = false
var canBeHit = true
const maxHealth = 100
var attackDamage = 10

var motion = Vector2()

func _ready():
	get_node("/root/Hud/HealthBar").set_value(health)
	add_to_group("Player")

var hasWallJump = false
var hasDash = false
var attacking = false
var ableToAttack = true

# warning-ignore:unused_argument
func _physics_process(delta):
	#Gravity
	motion.y += gravity
	if motion.y > maxFallSpeed:
		motion.y = maxFallSpeed
		
	#Basic Movement
	if Input.is_action_pressed("Right") and canControl == true and dashing == false: #D
		if attacking == false:
			if is_on_floor():
				get_node("/root/World/Player/AnimationPlayer").play("Run")
			get_node("/root/World/Player/Sprite").flip_h = false
			get_node("/root/World/Player/Sprite").position.x = 8
			motion.x = maxSpeed
			facingRight = true
			facingDirection = 1
		else:
			motion.x = 0
			facingRight = true
			facingDirection = 1
	elif Input.is_action_pressed("Left") and canControl == true and dashing == false: #A
		if attacking == false:
			if is_on_floor():
				get_node("/root/World/Player/AnimationPlayer").play("Run")
			get_node("/root/World/Player/Sprite").flip_h = true
			get_node("/root/World/Player/Sprite").position.x = -8
			motion.x = -maxSpeed
			facingRight = false
			facingDirection = -1
		else:
			motion.x = 0
			facingRight = false
			facingDirection = -1
	else:
		motion.x = 0
	
	#Animations
	if dashing == true and dead == false:
		get_node("/root/World/Player/AnimationPlayer").play("Dash")
	if motion.x == 0 and is_on_floor() and attacking == false and dashing == false and dead == false:
		get_node("/root/World/Player/AnimationPlayer").play("Idle")
		
	if motion.y < 0 and dead == false and is_on_floor() == false:
		get_node("/root/World/Player/AnimationPlayer").play("Jump")
	if motion.y == 0 and dead == false:
		get_node("/root/World/Player/AnimationPlayer").play("Fall")
	
	if dead == true:
		get_node("/root/World/Player/AnimationPlayer").play("Death")
	
	#Jump
	if is_on_floor():
		if Input.is_action_just_pressed("Jump"): #Space
			motion.y = -jumpForce
	if is_on_floor() :
		ableToAttack = true
		canControl = true
	if not is_on_floor():
		motion.x = lerp(motion.x, 0, 0.25)
		ableToAttack = false
		
	#Health
	if health <= 0:
		dead = true
		yield(get_tree().create_timer(1), "timeout")
		get_node("/root/Hud").visible = false
		get_tree().change_scene("res://Scenes//Menu/MainMenu.tscn")
	
	#Knockback
	if knockbacked == true and canControl == true:
		canControl = false
		motion.x = 2400 * knockbackDirection
		motion.y = -200
		knockbacked = false
	
	if canControl == false:
		get_node("/root/World/Player/AnimationPlayer").play("Hit")
	
	#Light Attack
	if Input.is_action_just_pressed("LightAttack"): #U
		attackDamage = 10 
		if ableToAttack == true and facingRight == true and attacking == false: #Right Attack
			attacking = true
			get_node("/root/World/Player/AnimationPlayer").play("LightAttack")
			yield(get_tree().create_timer(0.15), "timeout")
			$PlayerAttackRight/CollisionShape2D.disabled = false
			yield(get_tree().create_timer(0.15), "timeout")
			attacking = false
			$PlayerAttackRight/CollisionShape2D.disabled = true
		elif ableToAttack == true and facingRight == false and attacking == false: #Left Attack
			attacking = true
			get_node("/root/World/Player/AnimationPlayer").play("LightAttack")
			yield(get_tree().create_timer(0.15), "timeout")
			$PlayerAttackLeft/CollisionShape2D.disabled = false
			yield(get_tree().create_timer(0.15), "timeout")
			attacking = false
			$PlayerAttackLeft/CollisionShape2D.disabled = true
			
	#Heavy Attack
	if Input.is_action_just_pressed("HeavyAttack"): #I
		attackDamage = 30
		if ableToAttack == true and facingRight == true and attacking == false: #Right Attack
			attacking = true
			get_node("/root/World/Player/AnimationPlayer").play("HeavyAttack")
			yield(get_tree().create_timer(0.30), "timeout") #Preparing To Attack
			$PlayerAttackRight/CollisionShape2D.disabled = false
			yield(get_tree().create_timer(0.30), "timeout") #Attacking
			attacking = false
			$PlayerAttackRight/CollisionShape2D.disabled = true
		elif ableToAttack == true and facingRight == false and attacking == false: #Left Attack
			attacking = true
			get_node("/root/World/Player/AnimationPlayer").play("HeavyAttack")
			yield(get_tree().create_timer(0.30), "timeout") #Preparing To Attack
			$PlayerAttackLeft/CollisionShape2D.disabled = false
			yield(get_tree().create_timer(0.30), "timeout") #Attacking
			attacking = false
			$PlayerAttackLeft/CollisionShape2D.disabled = true
	
	#Abilities
	if hasWallJump == true and attacking == false:
		wallJump()
	if hasDash == true and attacking == false:
		dash()
	motion = move_and_slide(motion,up)

const wallStick = 0
const wallJump_pushback = 2500

var stuckRightWall = true
var wallStuck = false

func wallJump():
	if is_on_wall():
		#(Re)stick
		if not is_on_floor() and is_on_wall() and Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
			if Input.is_action_pressed("Left"):
				stuckRightWall = false
			if Input.is_action_pressed("Right"):
				stuckRightWall = true
			wallStuck = true
			canDash = true #Dash Reset
		else:
			if not is_on_floor():
				if stuckRightWall == false:
					get_node("/root/World/Player/Sprite").flip_h = false
				if stuckRightWall == true:
					get_node("/root/World/Player/Sprite").flip_h = true
				get_node("/root/World/Player/AnimationPlayer").play("WallSlide")
			wallStuck = false
		if wallStuck:
			motion.y = 0
			if not is_on_floor():
				get_node("/root/World/Player/AnimationPlayer").play("WallHang")
			if motion.y < wallStick:
				motion.y = wallStick
			
		#Wall Jumps
		if wallStuck == true:
			if is_on_wall() and Input.is_action_just_pressed("Jump") and Input.is_action_pressed("Right") \
			and not Input.is_action_pressed("Left"): #Right Wall Jump
				motion.y = -jumpForce
				motion.x = -wallJump_pushback
			if is_on_wall() and Input.is_action_just_pressed("Jump") and Input.is_action_pressed("Left") \
			and not Input.is_action_pressed("Right"): #Left Wall Jump
				motion.y = -jumpForce
				motion.x = wallJump_pushback
	else:
		wallStuck = false

const dashAmount = 200
var canDash = true
var dashing = false
var dashOnFloor = true

func dash():
	if Input.is_action_just_pressed("Dash") and canDash == true: #Shift
		$DashTimer.start() #Dash
		#get_tree().create_tween().tween_property(self, "position:x", position.x + dashAmount * facingDirection, 1)
		motion.x = 4500 * facingDirection
		canDash = false
		dashing = true
		dashOnFloor = false
		
#Wall Jump Activation
func _on_WallJumpItem_body_entered(body):
	if body.is_in_group("Player"):
		hasWallJump = true

#Dash Activation
func _on_DashItem_body_entered(body):
	if body.is_in_group("Player"):
		hasDash = true

#Contact Damage From Enemy
func _on_PlayerHurtbox_body_entered(body):
	if body.is_in_group("Enemy"):
		if canBeHit == true and body.dead == false:
			health = health - body.attackDamage
			get_node("/root/Hud/HealthBar").set_value(health)
			
			#Player Knockback
			knockbackDirection = BasicEnemy.playerKnockbackSide
			direction = knockbackDirection * -1
			knockbacked = true
			$CanBeHitTimer.start()
			canBeHit = false

#Dash End
func _on_DashTimer_timeout():
	canDash = true
	dashing = false
	dashOnFloor = true

#Right Attack on Enemy
func _on_PlayerAttackRight_body_entered(body):
	if body.is_in_group("Enemy"):
		if body.dead == false:
			body.health = body.health - attackDamage
			if body.health <= 0:
				yield(get_tree().create_timer(1.3), "timeout")
				body.queue_free()
		
		#Enemy Knockback
		if body.dead == false:
			body.knockbackDirection = facingDirection
			body.direction = body.knockbackDirection * -1
			body.knockbacked = true

#Left Attack on Enemy
func _on_PlayerAttackLeft_body_entered(body):
	if body.is_in_group("Enemy"):
		if body.dead == false:
			body.health = body.health - attackDamage
			if body.health <= 0:
				yield(get_tree().create_timer(1.3), "timeout")
				body.queue_free()
		
		#Enemy Knockback
		if body.dead == false:
			body.knockbackDirection = facingDirection
			body.direction = body.knockbackDirection * -1
			body.knockbacked = true

#Invulnerability
func _on_CanBeHitTimer_timeout():
	canBeHit = true

#Finish
func _on_Finish_body_entered(body):
	if body.is_in_group("Player"):
		yield(get_tree().create_timer(0.5), "timeout")
		get_node("/root/Hud").visible = false
		get_tree().change_scene("res://Scenes//Menu/MainMenu.tscn")
