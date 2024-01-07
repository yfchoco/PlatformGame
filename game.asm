



#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Yuhei Fukuhara, 1007515716, fukuhar3, yuhei.fukuhara@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 128 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3 
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health/score
# 2. Fail condition
# 3. Win condition
# 4. Moving objects
# 5. Moving platform
# 6. Disappearing platform
# 7. Different levels
# 8. Pick-up effect
# 9. Start menu
#
# Link to video demonstration for final submission:
# - https://play.library.utoronto.ca/watch/3ea4cff8b5a2e41dd85f60cc1283d24f

#
# Are you OK with us sharing the video with people outside course staff?
# - yes
#
# Any additional information that the TA needs to know:
# Some additional information I forgot to put in my video is that the speed of objects are different, 
# a bird is slightly faster than eggs since it is a bird, and this is done by not moving in certain iteration
# The basic control of the game is: press a to move left, press w to go up, and d to go right
#
#####################################################################

.eqv BASE_ADDRESS 0x10008000
.eqv DEEP_PINK 0xff1493
.eqv WHITE 0xffffff
.eqv ANTIQUE_WHITE 0xfaebd7
.eqv BLACK 0x000000
.eqv ORANGE_RED 0xff4500
.eqv YELLOW 0xffff00
.eqv YELLOW_GREEN 0x9acd32
.eqv BROWN 0xa0522d
.eqv HOT_PINK 0xff69b4
.eqv SADDLE_BROWN 0x8b4513
.eqv RED 0xff0000
.eqv NAVAJO_WHITE 0xffdead
.eqv SKY_BLUE 0x87CEEB
.eqv CORN_YELLOW 0xfff380
.eqv ORANGE 0xffa500
.eqv MAGENTA 0xff00ff
.eqv LIME 0x00ff00
.eqv DARK_PURPLE 0x4b0150
.eqv SILVER 0xc0c0c0
.eqv PARCHMENT 0xffffc2

# position of right end
.eqv RIGHT_END 8192

.eqv RIGHTMOST_X 64
.eqv EGG_X_RESET 56
.eqv BIRD_X_RESET 49
.eqv TREE_X_RESET 49
.eqv MUSHROOM_X_RESET 56
.eqv STONE_X_RESET 44

.data 
	# character position
	chick_pos:	.word 23, 1 # initial position of chick (y = 23, x = 1)
	chick_end: 	.word 31, 9 # low right corner of chick
	
	chicken_pos: 	.word 20, 0 # initial position of chicken (y = 20, x = 0)
	chicken_end: 	.word 31, 11 # low right corner of chicken
	
	# objects
	egg_pos: 	.word 22, 56 # initial position of egg
	egg_end: 	.word 30, 64 # low right corner of egg
	egg_status:	.word 0 # if egg_status = 0 then no egg
	
	poisonous_pos: 	.word 22, 56 # initial position of poisonou egg
	poisonous_end: 	.word 30, 64 # low right corner of poisonous egg
	poisonous_status:	.word 0 # if poisonous_status = 0 then no poisonous egg
	
	bird_pos:	.word 0, 49 # initial position of bird
	bird_end:	.word 10, 64 # low right corner of bird
	bird_status:	.word 0 # if bird_status = 0 then no bird
	
	tree_pos:	.word 11, 44 # initial position of tree
	tree_end:	.word 31, 59 # low right corner of tree
	tree_status:	.word 1 # if tree_status = 0 then no tree
	
	mushroom_pos:	.word 24, 56 # initial position of mushroom
	mushroom_end:	.word 32, 64 # low right corner of mushroom
	mushroom_status:.word 0 # if tree_status = 0 then no mushroom
	
	stone_pos:	.word 20, 44 # initial position of stone
	stone_end:	.word 32, 64 # low right corner of stone
	stone_height:	.word 12 # height of stone
	stone_status:	.word 1 # if stone_status = 0 then no stone
	
	# start and end
	start_pos:	.word 15, 8 # position of start
	exit_pos:	.word 15, 40 # position of exit
	
	#hp and score
	hp_pos:		.word 1, 1 # initial position of hp
	hp_end:		.word 5, 15 # low right corner of hp
	hp:		.word 5 # character's life
	
	score: 		.word 0 # score
	
	
	status: 	.word 0 # if status = 0 then chick, 1 then chicken
	
	collision_stat:	.word 0 # if collision_stat = 0 then no collision, 1 if there is 

	
	iteration:	.word 0 # iteration of game
	
	end_pos:	.word 12, 21 # position of bye
	
	game_over_pos:	.word 11, 25 # position of game_over
	
	# level
	level:		.word 1
	
	wait:		.word 150
	
	on_stone: 	.word 0 # 1 if on top of stone
	
     
.text

.globl main

main:
	la $s0, score # s0 is going to store address of score
	la $s3, hp # $s3 is going to store address of hp
	
	# Start Screen
	j start_screen
start:
	jal level_update
	
	jal wait_update
	lw $t0, wait
	
	li $v0, 32
	move $a0, $t0# Wait x mili second depending on level
	syscall
	
	#jal check_restart

	health_status:
	lw $t0, 0($s3) # current hp
	blez $t0, game_over # if hp <= 0 then game over
	
	check_score:
	lw $t0, 0($s0) # current score
	li $t1, 5
	bge $t0, $t1, win
	
	set:
	jal background_color # color background
	jal draw_hp # draw hp
	jal obj_random_pos # assign random position to obj
	jal move_obj # move object
	jal check_on_top # check if character on top of stone
	jal gravity # character fall by gravity
	
	# draw other objects
	draw_obj:
	jal draw_stone
	jal draw_tree
	jal draw_eggs
	jal draw_poisonous
	jal draw_bird
	jal draw_mushroom
	# draw score
	jal draw_score # draw score
	
	### draw character
	# check if chick or chicken
	lw $t0, status 
	is_chick:
	bne $t0, $zero, is_chicken # status = 1 then chicken
	jal draw_chick
	j game

	# if chicken
	is_chicken:
	jal draw_chicken
	

	
game: 
	jal collide 
	j move_char

game_over:
	# wait for few seconds then jump to start screen
	jal background_color
	jal game_over_screen
	li $v0, 32
	li $a0, 5000 # Wait 5 seconds
	syscall
	j restart
	
win:
	# wait for feew seconds then jump to start screen
	jal background_color
	jal win_screen
	li $v0, 32
	li $a0, 5000 # Wait 5 seconds
	syscall
	j restart
exit:
	jal background_color
	bye: 
	jal bye_screen
	
end: 
	li $v0, 10
	syscall	
	
restart:
	# restart 
	# chick_pos and chick_end
    	la $t0, chick_pos
    	li $t1, 23
    	li $t2, 1
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, chick_end
    	li $t1, 31
    	li $t2, 9
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	# chicken_pos and chicken_end
    	la $t0, chicken_pos
    	li $t1, 20
    	li $t2, 0
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, chicken_end
    	li $t1, 31
    	li $t2, 11
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	# egg_pos, egg_end, and egg_status
    	la $t0, egg_pos
    	li $t1, 22
    	li $t2, 56
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, egg_end
    	li $t1, 30
    	li $t2, 64
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, egg_status
    	sw $zero, 0($t0)

    	# poisonous_pos, poisonous_end, and poisonous_status
    	la $t0, poisonous_pos
    	li $t1, 22
    	li $t2, 56
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, poisonous_end
    	li $t1, 30
    	li $t2, 64
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, poisonous_status
    	sw $zero, 0($t0)

    	# bird_pos, bird_end, and bird_status
    	la $t0, bird_pos
    	li $t1, 0
    	li $t2, 49
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, bird_end
    	li $t1, 10
    	li $t2, 64
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, bird_status
    	sw $zero, 0($t0)

    	# tree_pos, tree_end, and tree_status
    	la $t0, tree_pos
    	li $t1, 11
    	li $t2, 44
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, tree_end
    	li $t1, 31
    	li $t2, 59
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, tree_status
    	li $t1, 1
    	sw $t1, 0($t0)

    	# mushroom_pos, mushroom_end, and mushroom_status
    	la $t0, mushroom_pos
    	li $t1, 24
    	li $t2, 56
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, mushroom_end
    	li $t1, 32
    	li $t2, 64
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, mushroom_status
    	sw $zero, 0($t0)

    	# stone_pos, stone_end, and stone_status
    	la $t0, stone_pos
    	li $t1, 20
    	li $t2, 44
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, stone_end
    	li $t1, 32
    	li $t2, 64
    	sw $t1, 0($t0)
    	sw $t2, 4($t0)

    	la $t0, stone_status
    	li $t1, 1
    	sw $t1, 0($t0)

    	# hp
    	li $t0, 5
    	la $t2, hp
    	sw $t0, 0($t2)

    	# score
    	li $t0, 0
    	la $t2, score
    	sw $t0, 0($t2)

    	# status
    	li $t0, 0
    	la $t2, status
    	sw $t0, 0($t2)

    	# collision_stat
    	li $t0, 0
    	la $t2, collision_stat
    	sw $t0, 0($t2)

    	# Initialize level, wait, on_stone, iteration
    	la $t0, level
    	li $t1, 1
    	sw $t1, 0($t0)

    	la $t0, wait
    	li $t1, 150
    	sw $t1, 0($t0)

    	la $t0, on_stone
    	sw $zero, 0($t0)

    	la $t0, iteration
    	sw $zero, 0($t0)
    	
    	j start_screen
    
level_update:
	# check iteration
	lw $t0, iteration
	li $t1, 400
	li $t2, 200
	li $t3, 1
	beq $t0, $t1, lv_3
	beq $t0, $t2, lv_2
	j update_done
	
	lv_3:
	li $t3, 3
	j updating
	
	lv_2:
	li $t3, 2
	j updating
	
	updating:
	la $t0, level
	sw $t3, 0($t0)
	
	# add 1 more obj
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal obj_random
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	update_done:
	jr $ra
	
wait_update:
	# update wait based on level
	la $t0, wait
	lw $t1, level
	
	li $t2, 1
	li $t3, 2
	
	beq $t1, $t2, wait_150 # if level 1
	beq $t1, $t3, wait_100 # if level 2
	wait_50:
	li $t4, 50
	j wait_updated
	
	wait_100:
	li $t4, 100
	j wait_updated
	
	wait_150:
	li $t4, 150
	
	wait_updated:
	sw $t4, 0($t0)
	
	jr $ra
	
start_screen:
	jal background_color
	
	print_start: # Print word "start"
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, start_pos
	lw $t2, 0($t1) # y axis of start
	lw $t3, 4($t1) # x axis of start
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of start
	add $t0, $t0, $t2

	li $t1, RED
	li $t2, YELLOW
	li $t3, DEEP_PINK
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t2, 40($t0)
	sw $t2, 44($t0)
	
	sw $t1, 256($t0)
	sw $t2, 272($t0)
	sw $t2, 276($t0)
	sw $t2, 280($t0)
	sw $t3, 288($t0)
	sw $t2, 296($t0)
	sw $t2, 304($t0)
	
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t2, 532($t0)
	sw $t3, 540($t0)
	sw $t3, 548($t0)
	sw $t2, 552($t0)
	sw $t2, 556($t0)
	sw $t1, 564($t0)
	sw $t1, 568($t0)
	sw $t1, 572($t0)
	
	sw $t1, 780($t0)
	sw $t2, 788($t0)
	sw $t3, 796($t0)
	sw $t3, 800($t0)
	sw $t3, 804($t0)
	sw $t2, 808($t0)
	sw $t2, 816($t0)
	sw $t1, 824($t0)
	
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t2, 1044($t0)
	sw $t3, 1052($t0)
	sw $t3, 1060($t0)
	sw $t2, 1064($t0)
	sw $t2, 1072($t0)
	sw $t1, 1080($t0)
	
	
print_exit:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, exit_pos
	lw $t2, 0($t1) # y axis of exit
	lw $t3, 4($t1) # x axis of exit
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of exit
	add $t0, $t0, $t2
	
	li $t1, MAGENTA
	li $t2, LIME
	li $t3, DARK_PURPLE
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 24($t0)
	sw $t3, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	
	sw $t1, 256($t0)
	sw $t2, 272($t0)
	sw $t2, 280($t0)
	sw $t1, 296($t0)
	
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t2, 532($t0)
	sw $t3, 544($t0)
	sw $t1, 552($t0)
	
	sw $t1, 768($t0)
	sw $t2, 784($t0)
	sw $t2, 792($t0)
	sw $t3, 800($t0)
	sw $t1, 808($t0)
	
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t2, 1040($t0)
	sw $t2, 1048($t0)
	sw $t3, 1056($t0)
	sw $t1, 1064($t0)
	

wait_for_input:	
	li $t0, 0xffff0000 # Address of Word
	lw $t1, 0($t0) # will contain 1 if new input
	beq $t1, 1, keypress_happened
	j wait_for_input
	
	keypress_happened:
	lw $t2, 4($t0) # key input
	beq $t2, 0x61, start_chosen # draw box to start if 'a' pressed
	beq $t2, 0x64, exit_chosen # draw box to exit if 'd' pressed
	
	start_chosen:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, start_pos
	lw $t2, 0($t1) # y axis of start
	lw $t3, 4($t1) # x axis of start
	addi $t2, $t2, -2 # y of box
	addi $t3, $t3, -2 # x of box
	
	# push start axes
	addi $sp, $sp, -8
	sw $t2, -4($sp)
	sw $t3, 0($sp)
	
	jal draw_box
	j confirm_start
	
	exit_chosen:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, exit_pos
	lw $t2, 0($t1) # y axis of exit
	lw $t3, 4($t1) # x axis of exit
	addi $t2, $t2, -2 # y of box
	addi $t3, $t3, -2 # x of box
	# push exit axes
	addi $sp, $sp, -8
	sw $t2, -4($sp)
	sw $t3, 0($sp)

	jal draw_box
	j confirm_exit
draw_box:
	# Pop address (start or exit)
	lw $t3, 0($sp) # x axis
	lw $t2, -4($sp) # y axis
	addi $sp, $sp, 8
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of start
	add $t0, $t0, $t2
	
	li $t2, BLACK
	# Draw
	sw $t2, 0($t0) 
	sw $t2, 76($t0)
	sw $t2, 2048($t0)
	sw $t2, 2124($t0)
	
	jr $ra
	
	confirm_start:
	#confirm start, go to exit chosen if not confirmed
	li $t0, 0xffff0000 # Address of Word
	lw $t1, 0($t0) # will contain 1 if new input
	beq $t1, 1, start_keypress_2
	j confirm_start
	
	confirm_exit:
	#confirm exit, go to start chosen if not confirmed
	li $t0, 0xffff0000 # Address of Word
	lw $t1, 0($t0) # will contain 1 if new input
	beq $t1, 1, exit_keypress_2
	j confirm_exit
	
	start_keypress_2:
	lw $t2, 4($t0) # key input
	beq $t2, 0x61, start_confirmed # assign one random object
	# otherwise go back to start screen
	j start_screen
	start_confirmed:
	# push $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal obj_random
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# start
	j start
	
	exit_keypress_2:
	lw $t2, 4($t0) # key input
	beq $t2, 0x64, exit # go to exit if 'd' pressed
	
	# otherwise go back to the start screen
	j start_screen
	
	
	
background_color:
	li $t0, BASE_ADDRESS  # $t0 stores the base address for display
	li $t1, SKY_BLUE 
	li $t3, WHITE
	addi $t4, $t0, 1280 # until 5th line
	addi $t2, $t0, RIGHT_END # $t2 stores the right end of display
	
	cloud:
	beq $t0, $t4, cloud_done
	sw $t3, 0($t0)
	addi $t0, $t0, 4
	j cloud
	cloud_done:
	
	color_in_prog:
	beq $t0, $t2, background_done
	sw $t1, 0($t0) # color blue
	addi $t0, $t0, 4 # $t0 stores the next pixel
	j color_in_prog
	background_done:
	# do nothing
	jr $ra # Jump to the caller

draw_hp:
	# 4 x 17
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, hp_pos
	lw $t2, 0($t1) # y axis of hp
	lw $t3, 4($t1) # x axis of hp
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of hp
	add $t0, $t0, $t2
	
	li $t1, YELLOW_GREEN
	li $t2, RED
	li $t3, ORANGE
	li $t4, YELLOW
	li $t5, SKY_BLUE
	
	# heart
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 776($t0)
	
	lw $t6, 0($s3) # current hp
	hp5:
	li $t7, 5
	blt $t6, $t7, hp4
	sw $t1, 340($t0)
	sw $t1, 336($t0)
	sw $t1, 332($t0)
	hp4:
	li $t7, 4
	blt $t6, $t7, hp3
	sw $t5, 328($t0)
	sw $t5, 324($t0)
	sw $t5, 320($t0)
	hp3:
	li $t7, 3
	blt $t6, $t7, hp2
	sw $t4, 316($t0)
	sw $t4, 312($t0)
	sw $t4, 308($t0)
	hp2:
	li $t7, 2
	blt $t6, $t7, hp1
	sw $t3, 304($t0)
	sw $t3, 300($t0)
	sw $t3, 296($t0)
	hp1:
	sw $t2, 292($t0)
	sw $t2, 288($t0)
	sw $t2, 284($t0)
	
	jr $ra
	
draw_score:
	lw $t0, status
	draw_on_chick:
	bne $t0, $zero, draw_on_chicken
	la $s1, chick_pos
	j draw_score_cont
	draw_on_chicken:
	la $s1, chicken_pos
	draw_score_cont:
	# $t2 contains chicken_pos or chick_pos depending on status
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	lw $t2, 0($s1) # y axis of character 
	lw $t3, 4($s1) # x axis of character 

	addi $t2, $t2, -2

	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of score
	add $t0, $t0, $t2
	
	lw $t1, score
	li $t2, 0
	
	li $t3, MAGENTA
	# draw score boxes
	draw_score_box:
	beq $t2, $t1, end_score
	sw $t3, 0($t0)
	addi $t2, $t2, 1
	addi $t0, $t0, 8
	j draw_score_box
	
	end_score:
	jr $ra
	
draw_chick:
	# 8 x 8
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, chick_pos
	lw $t2, 0($t1) # y axis of chick
	lw $t3, 4($t1) # x axis of chick
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of chick
	add $t0, $t0, $t2
	
	li $t1, CORN_YELLOW
	li $t2, BLACK
	li $t3, ORANGE
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	
	sw $t1, 264($t0)
	sw $t1, 272($t0)
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t2, 532($t0)
	sw $t1, 536($t0)
	sw $t3, 540($t0)
	
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t1, 788($t0)
	sw $t1, 792($t0)
	
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1044($t0)
	
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1300($t0)
	
	sw $t3, 1544($t0)
	sw $t3, 1548($t0)
	
	sw $t3, 1804($t0)
	sw $t3, 1808($t0)
	
	jr $ra

draw_chicken:
	#11 x 11
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t6, chicken_pos
	lw $t7, 0($t6) # y axis of chicken
	lw $t8, 4($t6) # x axis of chicken
	sll $t7, $t7, 8 # y * 256
	sll $t8, $t8, 2 # x * 4
	add $t7, $t7, $t8 # address of chicken
	add $t0, $t0, $t7
	
	li $t1, WHITE # $t1 stores the white colour code
	li $t2, BLACK # $t2 stores the black colour code
	li $t3, DEEP_PINK # $t3 stores the deep pink colour code
	li $t4, ANTIQUE_WHITE # $t4 stores the antique white colour code
	li $t5, ORANGE_RED # $t5 stores the orange red colour code
	
	# chicken's crown
	sw $t3, 24($t0)
	sw $t3, 28($t0)
	
	# chicken's face & body
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	sw $t1, 284($t0)
	sw $t1, 288($t0)
	
	sw $t1, 532($t0)
	sw $t1, 536($t0)
	sw $t2, 540($t0)
	sw $t1, 544($t0)
	
	sw $t1, 788($t0)
	sw $t1, 792($t0)
	sw $t1, 796($t0)
	sw $t1, 800($t0)
	sw $t5, 804($t0)
	sw $t5, 808($t0)
	
	sw $t1, 1044($t0)
	sw $t1, 1048($t0)
	sw $t1, 1052($t0)
	sw $t1, 1056($t0)
	sw $t3, 1060($t0)
	
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1300($t0)
	sw $t1, 1304($t0)
	sw $t1, 1308($t0)
	sw $t1, 1312($t0)
	
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t4, 1548($t0)
	sw $t4, 1552($t0)
	sw $t4, 1556($t0)
	sw $t4, 1560($t0)
	sw $t1, 1564($t0)
	sw $t1, 1568($t0)
	
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t4, 1804($t0)
	sw $t4, 1808($t0)
	sw $t4, 1812($t0)
	sw $t4, 1816($t0)
	sw $t1, 1820($t0)
	sw $t1, 1824($t0)
	
	sw $t1, 2052($t0)
	sw $t1, 2056($t0)
	sw $t1, 2060($t0)
	sw $t1, 2064($t0)
	sw $t1, 2068($t0)
	sw $t1, 2072($t0)
	sw $t1, 2076($t0)
	sw $t1, 2080($t0)
	
	# chicken leg
	sw $t5, 2320($t0)
	
	sw $t5, 2576($t0)
	sw $t5, 2580($t0)
	
	jr $ra
	
draw_eggs:
	# if egg_status = 0 then don't draw
	lw $t0, egg_status
	beqz $t0, draw_poisonous
	
	draw_normal:
	# 8 x 8
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	li $t1, WHITE # $t1 stores the white colour code
	li $t6, YELLOW # $t3 stores the yellow colour code
	la $t2, egg_pos
	
	lw $t3, 0($t2) # y axis of egg
	lw $t4, 4($t2) # x axis of egg
	sll $t3, $t3, 8 # y * 256
	sll $t4, $t4, 2 # x * 4
	add $t3, $t3, $t4 # address of egg
	add $t0, $t0, $t3
	
	sw $t6, 12($t0)
	sw $t6, 16($t0)
	
	sw $t6, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t6, 276($t0)
	
	sw $t6, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t6, 536($t0)
	
	sw $t6, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t1, 788($t0)
	sw $t6, 792($t0)
	
	sw $t6, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1044($t0)
	sw $t1, 1048($t0)
	sw $t6, 1052($t0)
	
	sw $t6, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1300($t0)
	sw $t1, 1304($t0)
	sw $t6, 1308($t0)
	
	sw $t6, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1556($t0)
	sw $t1, 1560($t0)
	sw $t6, 1564($t0)
	
	sw $t6, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	sw $t1, 1808($t0)
	sw $t1, 1812($t0)
	sw $t6, 1816($t0)
	
	sw $t6, 2056($t0)
	sw $t6, 2060($t0)
	sw $t6, 2064($t0)
	sw $t6, 2068($t0)
	
	draw_poisonous:
	
	lw $t0, poisonous_status
	beqz $t0, exit_draw_eggs
	
	# if poisonous then change color
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	li $t1, DARK_PURPLE
	li $t6, MAGENTA
	la $t2, poisonous_pos
	
	lw $t3, 0($t2) # y axis of poisonous egg
	lw $t4, 4($t2) # x axis of poisonous egg
	sll $t3, $t3, 8 # y * 256
	sll $t4, $t4, 2 # x * 4
	add $t3, $t3, $t4 # address of poisonous egg
	add $t0, $t0, $t3
	
	sw $t6, 12($t0)
	sw $t6, 16($t0)
	
	sw $t6, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t6, 276($t0)
	
	sw $t6, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t6, 536($t0)
	
	sw $t6, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t1, 788($t0)
	sw $t6, 792($t0)
	
	sw $t6, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1044($t0)
	sw $t1, 1048($t0)
	sw $t6, 1052($t0)
	
	sw $t6, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1300($t0)
	sw $t1, 1304($t0)
	sw $t6, 1308($t0)
	
	sw $t6, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1556($t0)
	sw $t1, 1560($t0)
	sw $t6, 1564($t0)
	
	sw $t6, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	sw $t1, 1808($t0)
	sw $t1, 1812($t0)
	sw $t6, 1816($t0)
	
	sw $t6, 2056($t0)
	sw $t6, 2060($t0)
	sw $t6, 2064($t0)
	sw $t6, 2068($t0)
	
	exit_draw_eggs:
	jr $ra
	
draw_bird:
	# if bird_status = 0 then don't draw
	lw $t0, bird_status
	beqz $t0, exit_draw_bird
	# 10 x 15
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, bird_pos
	lw $t2, 0($t1) # y axis of bird
	lw $t3, 4($t1) # x axis of bird
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of bird
	add $t0, $t0, $t2
	
	li $t1, HOT_PINK # $t1 stores the hot pink colour code
	li $t2, ANTIQUE_WHITE # $t2 stores the antique white colour code
	li $t3, SADDLE_BROWN
	
	sw $t1, 32($t0)
	
	sw $t1, 284($t0)
	sw $t1, 288($t0)
	sw $t1, 292($t0)
	
	sw $t1, 540($t0)
	sw $t2, 544($t0)
	sw $t1, 548($t0)
	
	sw $t1, 792($t0)
	sw $t2, 796($t0)
	sw $t2, 800($t0)
	sw $t1, 804($t0)
	sw $t1, 808($t0)

	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1044($t0)
	sw $t2, 1048($t0)
	sw $t2, 1052($t0)
	sw $t2, 1056($t0)
	sw $t2, 1060($t0)
	
	sw $t3, 1280($t0)
	sw $t1, 1284($t0)
	sw $t3, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1300($t0)
	sw $t2, 1304($t0)
	sw $t2, 1308($t0)
	sw $t2, 1312($t0)
	sw $t2, 1316($t0)
	
	sw $t3, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t2, 1552($t0)
	sw $t2, 1556($t0)
	sw $t2, 1560($t0)
	sw $t2, 1564($t0)
	sw $t2, 1568($t0)
	sw $t1, 1572($t0)
	sw $t1, 1576($t0)
	sw $t1, 1580($t0)
	sw $t1, 1584($t0)
	
	sw $t2, 1808($t0)
	sw $t2, 1812($t0)
	sw $t2, 1816($t0)
	sw $t2, 1820($t0)
	sw $t2, 1824($t0)
	sw $t2, 1828($t0)
	sw $t1, 1832($t0)
	sw $t1, 1836($t0)
	sw $t1, 1840($t0)
	sw $t1, 1844($t0)
	sw $t1, 1848($t0)
	
	sw $t3, 2092($t0)
	
	sw $t3, 2352($t0)
	
	exit_draw_bird:
	jr $ra
	
draw_tree:
	# if tree_status = 0 then don't draw
	lw $t0, tree_status
	beqz $t0, exit_draw_tree
	# 15 x 20
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, tree_pos
	lw $t2, 0($t1) # y axis of tree
	lw $t3, 4($t1) # x axis of tree
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of tree
	add $t0, $t0, $t2
	
	li $t1, YELLOW_GREEN # $t1 stores the yellow green colour code
	li $t2, BROWN # $t2 stores the brown colour code
	
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 272($t0)
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	sw $t1, 284($t0)
	sw $t1, 288($t0)
	sw $t1, 292($t0)
	sw $t1, 296($t0)
	
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 536($t0)
	sw $t1, 540($t0)
	sw $t1, 544($t0)
	sw $t1, 548($t0)
	sw $t1, 552($t0)
	
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t1, 788($t0)
	sw $t1, 792($t0)
	sw $t1, 796($t0)
	sw $t1, 800($t0)
	sw $t1, 804($t0)
	sw $t1, 808($t0)
	sw $t1, 812($t0)
	sw $t1, 816($t0)
	
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1044($t0)
	sw $t1, 1048($t0)
	sw $t1, 1052($t0)
	sw $t1, 1056($t0)
	sw $t1, 1060($t0)
	sw $t1, 1064($t0)
	sw $t1, 1068($t0)
	sw $t1, 1072($t0)
	
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1044($t0)
	sw $t1, 1048($t0)
	sw $t1, 1052($t0)
	sw $t1, 1056($t0)
	sw $t1, 1060($t0)
	sw $t1, 1064($t0)
	sw $t1, 1068($t0)
	sw $t1, 1072($t0)

	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1300($t0)
	sw $t2, 1304($t0)
	sw $t2, 1308($t0)
	sw $t2, 1312($t0)
	sw $t1, 1316($t0)
	sw $t1, 1320($t0)
	sw $t1, 1324($t0)
	sw $t1, 1328($t0)
	
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1556($t0)
	sw $t2, 1560($t0)
	sw $t2, 1564($t0)
	sw $t2, 1568($t0)
	sw $t1, 1572($t0)
	sw $t1, 1576($t0)
	sw $t1, 1580($t0)
	sw $t1, 1584($t0)
	
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	sw $t1, 1808($t0)
	sw $t1, 1812($t0)
	sw $t2, 1816($t0)
	sw $t2, 1820($t0)
	sw $t2, 1824($t0)
	sw $t1, 1828($t0)
	sw $t1, 1832($t0)
	sw $t1, 1836($t0)
	sw $t1, 1840($t0)
	
	sw $t1, 2048($t0)
	sw $t1, 2052($t0)
	sw $t1, 2056($t0)
	sw $t1, 2060($t0)
	sw $t1, 2064($t0)
	sw $t1, 2068($t0)
	sw $t2, 2072($t0)
	sw $t2, 2076($t0)
	sw $t2, 2080($t0)
	sw $t1, 2084($t0)
	sw $t1, 2088($t0)
	sw $t1, 2092($t0)
	sw $t1, 2096($t0)
	sw $t1, 2100($t0)
	sw $t1, 2104($t0)
	
	sw $t1, 2304($t0)
	sw $t1, 2308($t0)
	sw $t1, 2312($t0)
	sw $t1, 2316($t0)
	sw $t1, 2320($t0)
	sw $t1, 2324($t0)
	sw $t2, 2328($t0)
	sw $t2, 2332($t0)
	sw $t2, 2336($t0)
	sw $t1, 2340($t0)
	sw $t1, 2344($t0)
	sw $t1, 2348($t0)
	sw $t1, 2352($t0)
	sw $t1, 2356($t0)
	sw $t1, 2360($t0)
	
	sw $t2, 2568($t0)
	sw $t2, 2572($t0)
	sw $t2, 2584($t0)
	sw $t2, 2588($t0)
	sw $t2, 2592($t0)
	sw $t2, 2604($t0)
	sw $t2, 2608($t0)
	
	sw $t2, 2824($t0)
	sw $t2, 2828($t0)
	sw $t2, 2840($t0)
	sw $t2, 2844($t0)
	sw $t2, 2848($t0)
	sw $t2, 2860($t0)
	sw $t2, 2864($t0)
	
	sw $t2, 3088($t0)
	sw $t2, 3092($t0)
	sw $t2, 3096($t0)
	sw $t2, 3100($t0)
	sw $t2, 3104($t0)
	sw $t2, 3108($t0)
	sw $t2, 3112($t0)
	
	sw $t2, 3344($t0)
	sw $t2, 3348($t0)
	sw $t2, 3352($t0)
	sw $t2, 3356($t0)
	sw $t2, 3360($t0)
	sw $t2, 3364($t0)
	sw $t2, 3368($t0)
	
	sw $t2, 3608($t0)
	sw $t2, 3612($t0)
	sw $t2, 3616($t0)
	
	sw $t2, 3864($t0)
	sw $t2, 3868($t0)
	sw $t2, 3872($t0)

	
	sw $t2, 4120($t0)
	sw $t2, 4124($t0)
	sw $t2, 4128($t0)
	
	sw $t2, 4376($t0)
	sw $t2, 4380($t0)
	sw $t2, 4384($t0)

	
	sw $t2, 4632($t0)
	sw $t2, 4636($t0)
	sw $t2, 4640($t0)
	
	sw $t2, 4888($t0)
	sw $t2, 4892($t0)
	sw $t2, 4896($t0)
	
	exit_draw_tree:
	jr $ra
	
draw_mushroom:
	# if mushroom_status = 0 then don't draw
	lw $t0, mushroom_status
	beqz $t0, exit_draw_mushroom
	# 8 x 8
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, mushroom_pos
	lw $t2, 0($t1) # y axis of mushroom
	lw $t3, 4($t1) # x axis of mushroom
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of mushroom
	add $t0, $t0, $t2
	
	li $t1, RED # $t1 stores the red colour code
	li $t2, WHITE # $t2 stores the white colour code
	li $t3, NAVAJO_WHITE # $t3 stores the navajo white colour code
	
	sw $t2, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t2, 20($t0)
	
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	
	sw $t2, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 536($t0)
	sw $t2, 540($t0)
	
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t2, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t2, 788($t0)
	sw $t1, 792($t0)
	sw $t1, 796($t0)
	
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t2, 1040($t0)
	sw $t1, 1044($t0)
	
	sw $t3, 1288($t0)
	sw $t3, 1292($t0)
	sw $t3, 1296($t0)
	sw $t3, 1300($t0)
	
	sw $t3, 1544($t0)
	sw $t3, 1548($t0)
	sw $t3, 1552($t0)
	sw $t3, 1556($t0)
	
	exit_draw_mushroom:
	jr $ra
	
draw_stone:
	# if stone_status = 0 then don't draw
	lw $t0, stone_status
	beqz $t0, end_draw_stone
	# 12 x ?
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, stone_pos
	lw $t2, 0($t1) # y axis of stone
	lw $t3, 4($t1) # x axis of stone
	
	ble $t3, $zero, partially_gone
	
	li $t4, 0 # the pixels gone
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t3, $t3, $t2 # address of stone
	add $t0, $t0, $t3
	j draw_stone_cont
	
	partially_gone:
	abs $t4, $t3 # pixels gone
	li $t3, 0 # set x to zero
	sll $t2, $t2, 8 # y * 256
	add $t3, $t3, $t2 # address of stone
	add $t0, $t0, $t3
	
	draw_stone_cont:
	li $t5, 20 # width of stone
	sub $t5, $t5, $t4 # remaining to print
	
	lw $t1, stone_height
	move $t6, $t0 # store temporary top left 
	move $t2, $zero # counter for y
	move $t7, $zero # counter for x
	
	li $t3, SILVER
	
	draw_stone_x:
	beq $t7, $t5, end_draw_stone
	
	draw_stone_y:
	beq $t2, $t1, draw_stone_y_done
	sw $t3, 0($t0)
	addi $t0, $t0, 256
	addi $t2, $t2, 1
	j draw_stone_y
	
	draw_stone_y_done:
	addi $t7, $t7, 1
	addi $t6, $t6, 4
	move $t0, $t6
	move $t2, $zero
	j draw_stone_x
	
	end_draw_stone:
	jr $ra
	
	
move_char:
	# Move character
	li $t0, 0xffff0000 # Address of Word
	lw $t1, 0($t0) # will contain 1 if new input
	beq $t1, 1, moving
	#j move_char
	j start
	
	moving:
	lw $t2, 4($t0) # key input
	
	lw $t6, status # check if chick or chicken
	moving_chick:
	bne $t6, $zero, moving_chicken
	la $t3, chick_pos
	la $t6, chick_end
	j moving_action
	moving_chicken:
	la $t3, chicken_pos
	la $t6, chicken_end
	moving_action:	
	lw $t4, 0($t3) # y axis
	lw $t5, 4($t3) # x axis
	lw $t7, 0($t6) # y axis of end 
	lw $t8, 4($t6) # x axis of end
	beq $t2, 0x61, move_left # move left if 'a' pressed
	beq $t2, 0x77, move_up # move up if 'w' pressed
	beq $t2, 0x64, move_right # move right if 'd' pressed
	beq $t2, 0x70, restart # go to exit if 'p' pressed
	
	move_left:
	beq $t5, $zero, start # if x axis is zero then can't go left
	addi $t5, $t5, -1 # shift 1 left
	addi $t8, $t8, -1 # shift right end 1 left
	sw $t5, 4($t3) # update x axis
	sw $t8, 4($t6) # update right end x axis
	j start 

	move_up:
	ble $t4, $zero, start # if y axis is less or equal to zero then can't go up
	addi $t4, $t4, -2 # shift 2 up
	addi $t7, $t7, -2 # shift right end 2 up
	sw $t4, 0($t3) # update y axis
	sw $t7, 0($t6) # update right end y axis
	j start 
	
	move_right:
	li $s2, 64
	beq $t8, $s2, start # if x end axis is 64 then can't go right
	addi $t5, $t5, 1 # shift 1 right
	addi $t8, $t8, 1 # shift right end 1 right
	sw $t5, 4($t3) # update y axis
	sw $t8, 4($t6) # update right end y axis
	j start 

	
collide:
	# check if there are any collisions
	
	# if character is on stone then skip collision
	lw $t0, on_stone
	bne $t0, $zero, no_collision
	
	lw $t0, status
	collide_chick:
	li $t3, 1
	beq $t0, $t3, collide_chicken
	la $s1, chick_pos
	la $t2, chick_end
	j collide_cont
	collide_chicken:
	
	la $s1, chicken_pos
	la $t2, chicken_end
	
	collide_cont:
	# $t2 contains chicken_pos or chick_pos depending on status
	lw $t3, 0($s1) # y axis of character (y1)
	lw $t4, 4($s1) # x axis of character (x1)
	
	lw $t5, 0($t2) # y axis of lower right of character (y2)
	lw $t6, 4($t2) # x axis of lower right of character (x2)
	
	# check collision with egg
	with_egg:
	# if egg DNE then skip checking collision
	lw $s1, egg_status
	beqz $s1, with_poisonous
	
	
	la $t0, egg_pos
	la $t1, egg_end
	
	lw $t2, 0($t0) # y axis of egg (y3)
	lw $t7, 4($t0) # x axis of egg (x3)
	
	lw $t8, 0($t1) # y axis of lower right of egg (y4)
	lw $t9, 4($t1) # x axis of lower right of egg (x4)
	
	# push $ra and all other to $sp
	addi $sp, $sp, -20
	sw $ra, -16($sp)
	sw $t2, -12($sp)
	sw $t7, -8($sp)
	sw $t8, -4($sp)
	sw $t9, 0($sp)
	jal check_collision
	# pop $ra
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# check collision_stat
	lw $t0, collision_stat
	
	# if collided with egg then increase score
	if_egg_collide:
	beq $t0, $zero, with_poisonous
	
	lw $t0, status
	chick_and_egg:
	li $t1, 1
	beq $t0, $t1, chicken_and_egg
	# increase score if collide w chick
	lw $t0, 0($s0) # load score
	addi $t0, $t0, 1 # add 1 
	sw $t0, 0($s0) # write 
	
	j w_egg_cont
	
	chicken_and_egg:
	# increase score by 2 if w chicken
	lw $t0, 0($s0) # load score
	addi $t0, $t0, 2 # add 2
	sw $t0, 0($s0) # write 
	
	w_egg_cont:
	# delete egg (set egg_status to 0)
	la $t0, egg_status
	sw $zero, 0($t0)
	# push current $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal obj_random
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	la $t0, egg_pos
	la $t1, egg_end
	
	li $t2, EGG_X_RESET # new x axis of egg
	sw $t2, 4($t0) 
	
	li $t8, RIGHTMOST_X # new x axis of egg end
	sw $t8, 4($t1) 
	
	# check collision with poisonous egg
	with_poisonous:
	# if poisonous egg DNE then skip checking collision
	lw $s1, poisonous_status
	beqz $s1, with_bird
	
	
	la $t0, poisonous_pos
	la $t1, poisonous_end
	
	lw $t2, 0($t0) # y axis of poisonous egg (y3)
	lw $t7, 4($t0) # x axis of poisonous egg (x3)
	
	lw $t8, 0($t1) # y axis of lower right of poisonous egg (y4)
	lw $t9, 4($t1) # x axis of lower right of poisonous egg (x4)
	
	# push $ra and all other to $sp
	addi $sp, $sp, -20
	sw $ra, -16($sp)
	sw $t2, -12($sp)
	sw $t7, -8($sp)
	sw $t8, -4($sp)
	sw $t9, 0($sp)
	jal check_collision
	# pop $ra
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# check collision_stat
	lw $t0, collision_stat
	
	# if collided with egg then increase score
	if_poisonous_collide:
	beq $t0, $zero, with_bird
	
	lw $t0, status
	chick_and_poison:
	li $t1, 1
	beq $t0, $t1, chicken_and_poison
	# decrease score
	lw $t0, 0($s3) # load hp
	addi $t0, $t0, -1 # decrease 1 
	sw $t0, 0($s3) # write 
	j w_poison_cont
	
	chicken_and_poison:
	# push $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal transform_back
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	w_poison_cont:
	# delete poisonous egg (set poisonous _status to 0)
	la $t0, poisonous_status
	sw $zero, 0($t0)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal obj_random
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	la $t0, poisonous_pos
	la $t1, poisonous_end
	
	li $t2, EGG_X_RESET # new x axis of poisonous egg
	sw $t2, 4($t0) 
	
	li $t8, RIGHTMOST_X # new x axis of poisonous egg end
	sw $t8, 4($t1) 
	
	
	# check collision with bird
	with_bird:
	# if bird DNE then skip checking collision
	lw $t0, bird_status
	beqz $t0, with_mushroom
	
	la $t0, bird_pos
	la $t1, bird_end
	lw $t2, 0($t0) # y axis of bird (y3)
	lw $t7, 4($t0) # x axis of bird (x3)
	
	lw $t8, 0($t1) # y axis of lower right of bird (y4)
	lw $t9, 4($t1) # x axis of lower right of bird (x4)
	
	# push $ra and all other to $sp
	addi $sp, $sp, -20
	sw $ra, -16($sp)
	sw $t2, -12($sp)
	sw $t7, -8($sp)
	sw $t8, -4($sp)
	sw $t9, 0($sp)
	jal check_collision
	# pop $ra
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# check collision_stat
	lw $t0, collision_stat
	# if collided with bird then decrease hp
	if_bird_collide:
	beq $t0, $zero, with_mushroom
	
	lw $t0, status
	chick_and_bird:
	li $t1, 1
	beq $t0, $t1, chicken_and_bird
	# decrease hp
	lw $t0, 0($s3) # load hp
	addi $t0, $t0, -1 # decrease 1 
	sw $t0, 0($s3) # write 
	j w_bird_cont
	
	chicken_and_bird:
	# push $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal transform_back
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	w_bird_cont:
	# delete bird (set bird_status to 0)
	la $t0, bird_status
	sw $zero, 0($t0)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal obj_random
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	la $t0, bird_pos
	la $t1, bird_end
	
	li $t2, BIRD_X_RESET # new x axis of bird
	sw $t2, 4($t0) 
	
	li $t8, RIGHTMOST_X # new x axis of bird end
	sw $t8, 4($t1) 
	 
	 
	# check collision with mushroom
	with_mushroom:
	# if mushroom DNE then skip checking collision
	lw $t0, mushroom_status
	beqz $t0, no_collision
	
	la $t0, mushroom_pos
	la $t1, mushroom_end
	lw $t2, 0($t0) # y axis of mushroom (y3)
	lw $t7, 4($t0) # x axis of mushroom (x3)
	
	lw $t8, 0($t1) # y axis of lower right of mushroom (y4)
	lw $t9, 4($t1) # x axis of lower right of mushroom (x4)
	
	# push $ra and all other to $sp
	addi $sp, $sp, -20
	sw $ra, -16($sp)
	sw $t2, -12($sp)
	sw $t7, -8($sp)
	sw $t8, -4($sp)
	sw $t9, 0($sp)
	jal check_collision
	# pop $ra
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# check collision_stat
	lw $t0, collision_stat
	
	# if collided with mushroom then turn into chicken and add 3 hp
	if_mushroom_collide:
	beq $t0, $zero, no_collision
	
	# increase hp
	#lw $t0, 0($s3) # load hp
	#addi $t0, $t0, 1 # add 1
	#sw $t0, 0($s3) # write 
	# delete mushroom (set mushroom_status to 0)
	la $t0, mushroom_status
	sw $zero, 0($t0)
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal obj_random
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	la $t0, mushroom_pos
	la $t1, mushroom_end
	
	li $t2, MUSHROOM_X_RESET # new x axis of mushroom
	sw $t2, 4($t0) 
	
	li $t8, RIGHTMOST_X # new x axis of mushroom end
	sw $t8, 4($t1)

	# turn into chicken
	# if already chicken then do nothing
	lw $t2, status
	bgtz $t2, no_collision
	
transform_chicken:
	# transform into chicken
	la $t0, status
	li $t1, 1
	sw $t1, 0($t0) # change status to 1
	# get position of chick
	la $s1, chick_pos
	la $s2, chick_end
	lw $t0, 0($s1) # y of chick
	lw $t1, 4($s1) # x of chick
	addi $t0, $t0, -3 # -3 on y when turning into chicken
	addi $t1, $t1, -2 # -2 on x when turning into chicken
	lw $t2, 0($s2) # y of lower right of chick
	lw $t3, 4($s2) # x of lower right of chick
	
	# update position of chicken
	la $s1, chicken_pos
	la $s2, chicken_end
	sw $t0, 0($s1) # update y of chicken
	sw $t1, 4($s1) # update x of chicken
	sw $t2, 0($s2) # updae lower right y of chicken
	sw $t3, 4($s2) # updae lower right x of chicken
	
	
	no_collision:
	jr $ra
	
transform_back:
	# transform back into chick
	# pop caller's $ra
	lw $s4, 0($sp)
	addi $sp, $sp, 4
	
	la $t0, status
	sw $zero, 0($t0) # change status to 0
	
	# get position of chicken
	la $s1, chicken_pos
	la $s2, chicken_end
	lw $t0, 0($s1) # y of chicken
	lw $t1, 4($s1) # x of chicken
	addi $t0, $t0, 3 # +3 on y when turning into chick
	addi $t1, $t1, 2 # +2 on x when turning into chick
	lw $t2, 0($s2) # y of lower right of chicken
	lw $t3, 4($s2) # x of lower right of chicken
	
	# update position of chicken
	la $s1, chick_pos
	la $s2, chick_end
	sw $t0, 0($s1) # update y of chick
	sw $t1, 4($s1) # update x of chick
	sw $t2, 0($s2) # update lower right y of chick
	sw $t3, 4($s2) # update lower right x of chick
	# push caller's $ra
	addi $sp, $sp, -4
	sw $s4, 0($sp)
	
	jr $ra
	
check_collision:
	# check collision
	# pop everything
	lw $s2, -16($sp) # $ra of caller
	lw $t2, -12($sp) # (y3)
	lw $t7, -8($sp) # (x3)
	lw $t8, -4($sp) # (y4)
	lw $t9, 0($sp) # (x4)
	addi $sp, $sp, 20
	
	# Check x3 <= x2 <= x4 or x3 <= x1 <= x4 or x1 <= x3 && x4 <= x2
	# Check x3 <= x2
	ble $t7, $t6, x3_leq_x2
	j false # if x3 > x2 then x3 > x1 so false

	x3_leq_x2: # when x3 <= x2
	# Check x2 <= x4
	ble $t6, $t9, check_y # x3 <= x2 <= x4 met so check y
	# Check x1 <= x3
	ble $t4, $t7, check_y # x1 <= x3 && x4 <= x2 met so check y

	x3_leq_x1: # if x2 > x4, check x1 <= x4
	# Check x1 <= x4
	ble $t4, $t9, x1_leq_x4
	j false # x1 > x4 so false

	x1_leq_x4: # when x1 <= x4
	# Check x3 <= x1
	ble $t7, $t4, check_y
	j false # x3 > x1 so false


	check_y:
	# Check y3 <= y2 <= y4 or y3 <= y1 <= y4 or y1 <= y3 && y2 >= y4
	# Check y3 <= y2
	ble $t2, $t5, y3_leq_y2
	j false # y3 > y2 so y3 > y1 so false

	y3_leq_y2: # y3 <= y2
	# Check y2 <= y4
	ble $t5, $t8, true # if y3<= y2 <= y4 then true
	# Check y1 <= y3
	ble $t3, $t2, true # if y1 <= y3 && y2 >= y4 then true

	y3_leq_y1: # Check y3 <= y1
	ble $t2, $t3, y3_leq_y1_leq_y4
	j false # if y3 > y1 then false

	y3_leq_y1_leq_y4:
	# Check y1 <= y4
	ble $t3, $t8, true # y3 <= y1 <= y4 so true
	j false # if y1 > y4 then false

	# True 
	true:
	# change collision stat to 1
	li $t0, 1
	la $t1, collision_stat
	sw $t0, 0($t1)
	
	# push caller's $ra 
	addi $sp, $sp, -4
	sw $s2, 0($sp)
	
	jr $ra

	# False
	false:
	# change collision stat to 0
	la $t1, collision_stat
	sw $zero, 0($t1)
	
	# push caller's $ra 
	addi $sp, $sp, -4
	sw $s2, 0($sp)
	
	jr $ra
	
move_obj:
	# move obj
	move_egg:
	# if egg DNE then skip moving egg
	la $t6, egg_status
	lw $t0, 0($t6)
	beqz $t0, move_poisonous
	
	# once in 2 iteration
	lw $t0, iteration
	li $t1, 2
	div $t0, $t1
	mfhi $t3 # remainder
	
	bne $t3, $zero, move_poisonous
	
	# move egg
	la $t1, egg_pos
	la $t2, egg_end
	li $t3, -1 # x to move
	# push to $sp
	addi $sp, $sp, -24
	li $t7, EGG_X_RESET
	sw $t7, -20($sp) # push EGG_X_RESET in case it resets
	sw $ra, -16($sp) # push $ra
	sw $t1, -12($sp) # address of obj_pos
	sw $t2, -8($sp) # address of obj_end
	sw $t3, -4($sp) # how many x to move
	sw $t6, 0($sp) # address of obj_status
	jal move_obj_func # call function
	lw $ra, 0($sp) # pop $ra
	addi $sp, $sp, 4
	
	move_poisonous:
	# if poisonous egg DNE then skip moving poisonous egg
	la $t6, poisonous_status
	lw $t0, 0($t6)
	beqz $t0, move_bird
	
	# once in 2 iteration
	lw $t0, iteration
	li $t1, 2
	div $t0, $t1
	mfhi $t3 # remainder
	
	bne $t3, $zero, move_bird
	
	# move poisonous egg
	la $t1, poisonous_pos
	la $t2, poisonous_end
	li $t3, -1 # x to move
	# push to $sp
	addi $sp, $sp, -24
	li $t7, EGG_X_RESET
	sw $t7, -20($sp) # push EGG_X_RESET in case it resets
	sw $ra, -16($sp) # push $ra
	sw $t1, -12($sp) # address of obj_pos
	sw $t2, -8($sp) # address of obj_end
	sw $t3, -4($sp) # how many x to move
	sw $t6, 0($sp) # address of obj_status
	jal move_obj_func # call function
	lw $ra, 0($sp) # pop $ra
	addi $sp, $sp, 4
	
	move_bird:
	# if bird DNE then skip moving bird
	la $t6, bird_status
	lw $t0, 0($t6)
	beqz $t0, move_mushroom
	
	# twice in 3 iteration
	lw $t0, iteration
	li $t1, 3
	div $t0, $t1
	mfhi $t3 # remainder
	
	beq $t3, $zero, move_mushroom
	# move bird
	la $t1, bird_pos
	la $t2, bird_end
	li $t3, -1 # x to move
	# push to $sp
	addi $sp, $sp, -24
	li $t7, BIRD_X_RESET
	sw $t7, -20($sp) # push BIRD_X_RESET in case it resets
	sw $ra, -16($sp) # push $ra
	sw $t1, -12($sp) # address of obj_pos
	sw $t2, -8($sp) # address of obj_end
	sw $t3, -4($sp) # how many x to move
	sw $t6, 0($sp) # address of obj_status
	jal move_obj_func # call function
	lw $ra, 0($sp) # pop $ra
	addi $sp, $sp, 4
	
	move_mushroom:
	# if mushroom DNE then skip moving mushroom
	la $t6, mushroom_status
	lw $t0, 0($t6)
	beqz $t0, move_stone
	
	# once in 3 iteration
	lw $t0, iteration
	li $t1, 3
	div $t0, $t1
	mfhi $t3 # remainder
	
	bne $t3, $zero, move_stone
	
	# move mushroom
	la $t1, mushroom_pos
	la $t2, mushroom_end
	li $t3, -1 # x to move
	# push to $sp
	addi $sp, $sp, -24
	li $t7, MUSHROOM_X_RESET
	sw $t7, -20($sp) # push MUSHROOM_X_RESET in case it resets
	sw $ra, -16($sp) # push $ra
	sw $t1, -12($sp) # address of obj_pos
	sw $t2, -8($sp) # address of obj_end
	sw $t3, -4($sp) # how many x to move
	sw $t6, 0($sp) # address of obj_status
	jal move_obj_func # call function
	lw $ra, 0($sp) # pop $ra
	addi $sp, $sp, 4
	
	
	move_stone:
	# if stone DNE then skip moving stone
	la $t6, stone_status
	lw $t0, 0($t6)
	beqz $t0, move_end
	
	# once in 2 iteration
	lw $t0, iteration
	li $t1, 2
	div $t0, $t1
	mfhi $t3 # remainder
	
	bne $t3, $zero, move_end
	
	# move stone
	la $t1, stone_pos
	la $t2, stone_end
	li $t3, -1 # x to move
	# push to $sp
	addi $sp, $sp, -24
	li $t7, STONE_X_RESET
	sw $t7, -20($sp) # push STONE_X_RESET in case it resets
	sw $ra, -16($sp) # push $ra
	sw $t1, -12($sp) # address of obj_pos
	sw $t2, -8($sp) # address of obj_end
	sw $t3, -4($sp) # how many x to move
	sw $t6, 0($sp) # address of obj_status
	jal move_stone_func # call function
	lw $ra, 0($sp) # pop $ra
	addi $sp, $sp, 4
	
	move_end:
	# add 1 to iteration
	la $t0, iteration
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	
	jr $ra
	
	
move_obj_func:
	# function to move obj given address of obj_pos and obj_end
	# pop Reset x, $ra and address of obj_pos, obj_end
	lw $t7, -20($sp) # OBJ_X_RESET
	lw $t0, -16($sp) # $ra
	lw $t1, -12($sp) # address of obj_pos
	lw $t2, -8($sp) # address of obj_end
	lw $t3, -4($sp) # how many x to move
	lw $t6, 0($sp) # address of obj_status
	addi $sp, $sp, 24
	
	lw $t4, 4($t1) # x of obj
	lw $t5, 4($t2) # x of obj end
	add $t4, $t4, $t3 # decrease x of obj by $t3
	add $t5, $t5, $t3 # decrease x of obj end by $t3
	sw $t4, 4($t1) # update x of obj
	sw $t5, 4($t2) # update x of obj end
	# if x of obj >= 0 then end or else delete obj
	bgez $t4, end_move_func
	delete_obj:
	# delete obj (set obj_status to 0)
	sw $zero, 0($t6)
	
	sw $t7, 4($t1) # update x of obj
	li $t5, RIGHTMOST_X
	sw $t5, 4($t2) # update x of obj end
	# if deleted object then create a new object
	# push current $ra
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal obj_random
	# pop $ra
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	end_move_func:
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	jr $ra
	
move_stone_func:
	# function to move stone given address of stone_pos and stone_end
	# pop Reset x, $ra and address of stone_pos, stone_end
	lw $t7, -20($sp) # STONE_X_RESET
	lw $t0, -16($sp) # $ra
	lw $t1, -12($sp) # address of stone_pos
	lw $t2, -8($sp) # address of stone_end
	lw $t3, -4($sp) # how many x to move
	lw $t6, 0($sp) # address of stone_status
	addi $sp, $sp, 24
	
	lw $t4, 4($t1) # x of stone
	lw $t5, 4($t2) # x of stone end
	add $t4, $t4, $t3 # decrease x of stone by $t3
	add $t5, $t5, $t3 # decrease x of stone end by $t3
	sw $t4, 4($t1) # update x of stone
	sw $t5, 4($t2) # update x of stone end
	# if x of stone end >= 0 then end or else delete stone
	bgez $t5, end_move_stone_func
	delete_stone:
	# delete stone (set stone_status to 0)
	sw $zero, 0($t6)
	
	sw $t7, 4($t1) # update x of stone
	li $t5, RIGHTMOST_X
	sw $t5, 4($t2) # update x of stone end
	
	end_move_stone_func:
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	jr $ra

	
obj_random_pos:
	bird_random_pos:
	# if bird exists then skip random position for bird
	la $s1, bird_status
	lw $t0, 0($s1)
	bnez  $t0, stone_random
	# random value between 0 and 16 for y of bird
	li $v0, 42
	li $a0, 0
	li $a1, 17
	syscall
	# store the random value + 5as new y for bird
	move $t0, $a0
	addi $t0, $t0, 5
	
	la $t1, bird_pos
	la $t2, bird_end
	
	sw $t0, 0($t1) # update bird pos
	addi $t0, $t0, 10 # bird height is 10
	sw $t0, 0($t2) # update bird end
	
	
	stone_random:
	# if stone exists then skip random position for stone
	la $s1, stone_status
	lw $t0, 0($s1)
	bnez  $t0, end_random_pos
	# random value between 0 and 10 for y of bird
	li $v0, 42
	li $a0, 0
	li $a1, 11
	syscall
	# store the random value + 8 as new height for stone
	move $t0, $a0
	addi $t0, $t0, 8
	
	la $t1, stone_height
	sw $t0, 0($t1)
	
	la $t1, stone_pos
	la $t2, stone_end
	
	lw $t3, 0($t2)
	sub $t3, $t3, $t0
	sw $t3, 0($t1) # update y of stone pos
	
	li $t0, 1
	sw $t0, 0($s1) # update stone status to 1
	
	end_random_pos:
	jr $ra
	

bye_screen:
	# draw bye screen when exit chosen
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, end_pos
	lw $t2, 0($t1) # y axis of bye
	lw $t3, 4($t1) # x axis of bye
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of bye
	add $t0, $t0, $t2
	
	li $t1, HOT_PINK
	li $t2, PARCHMENT
	li $t3, BLACK
	li $t4, RED
	li $t5, YELLOW
	li $t6, SILVER
	li $t7, ORANGE
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	addi $t0, $t0, 256
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t1, 44($t0)
	sw $t3, 48($t0)
	sw $t3, 52($t0)
	sw $t3, 56($t0)
	sw $t5, 60($t0)
	sw $t5, 68($t0)
	sw $t4, 72($t0)
	sw $t4, 76($t0)
	sw $t4, 80($t0)
	sw $t1, 84($t0)
	
	addi $t0, $t0, 256
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t1, 44($t0)
	sw $t3, 48($t0)
	sw $t3, 56($t0)
	sw $t5, 60($t0)
	sw $t5, 68($t0)
	sw $t4, 72($t0)
	sw $t1, 84($t0)
	
	addi $t0, $t0, 256
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t1, 44($t0)
	sw $t3, 48($t0)
	sw $t3, 52($t0)
	sw $t3, 56($t0)
	sw $t5, 60($t0)
	sw $t5, 68($t0)
	sw $t4, 72($t0)
	sw $t4, 76($t0)
	sw $t4, 80($t0)
	sw $t1, 84($t0)
	
	addi $t0, $t0, 256
	sw $t5, 0($t0)
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t3, 12($t0)
	sw $t2, 16($t0)
	sw $t3, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t5, 32($t0)
	sw $t5, 36($t0)
	sw $t1, 44($t0)
	sw $t3, 48($t0)
	sw $t3, 56($t0)
	sw $t5, 64($t0)
	sw $t4, 72($t0)
	sw $t1, 84($t0)
	
	addi $t0, $t0, 256
	sw $t5, 0($t0)
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t7, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t5, 32($t0)
	sw $t5, 36($t0)
	sw $t6, 40($t0)
	sw $t1, 44($t0)
	sw $t3, 48($t0)
	sw $t3, 52($t0)
	sw $t3, 56($t0)
	sw $t5, 64($t0)
	sw $t4, 72($t0)
	sw $t4, 76($t0)
	sw $t4, 80($t0)
	sw $t1, 84($t0)
	
	addi $t0, $t0, 256
	sw $t5, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t5, 28($t0)
	sw $t6, 36($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	addi $t0, $t0, 256
	sw $t5, 8($t0)
	sw $t5, 12($t0)
	sw $t5, 16($t0)
	sw $t5, 20($t0)
	sw $t5, 24($t0)
	sw $t6, 32($t0)
	
	addi $t0, $t0, 256
	sw $t5, 12($t0)
	sw $t5, 16($t0)
	sw $t5, 20($t0)
	sw $t6, 28($t0)
	
	addi $t0, $t0, 256
	sw $t7, 12($t0)
	sw $t7, 20($t0)
	
	addi $t0, $t0, 256
	sw $t7, 8($t0)
	sw $t7, 12($t0)
	sw $t7, 20($t0)
	sw $t7, 24($t0)
	
	jr $ra
	
game_over_screen:
	# draw game over screen when exit chosen
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, game_over_pos
	lw $t2, 0($t1) # y axis of bye
	lw $t3, 4($t1) # x axis of bye
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of game_over
	add $t0, $t0, $t2
	
	li $t1, WHITE
	li $t2, CORN_YELLOW
	li $t3, BLACK
	li $t4, ORANGE
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	addi $t0, $t0, 512
	
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t2, 32($t0)
	
	addi $t0, $t0, 256
	
	sw $t1, 0($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t2, 32($t0)
	sw $t2, 36($t0)
	sw $t1, 56($t0)
	
	addi $t0, $t0, 256
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t2, 32($t0)
	sw $t2, 36($t0)
	sw $t2, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t2, 16($t0)
	sw $t3, 20($t0)
	sw $t3, 24($t0)
	sw $t2, 28($t0)
	sw $t3, 32($t0)
	sw $t3, 36($t0)
	sw $t2, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t4, 28($t0)
	sw $t2, 32($t0)
	sw $t2, 36($t0)
	sw $t2, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	addi $t0, $t0, 256
	
	sw $t1, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t2, 32($t0)
	sw $t2, 36($t0)
	sw $t2, 40($t0)
	sw $t2, 44($t0)
	sw $t1, 48($t0)
	
	addi $t0, $t0, 256
	
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t4, 20($t0)
	sw $t4, 24($t0)
	sw $t2, 28($t0)
	sw $t4, 32($t0)
	sw $t4, 36($t0)
	sw $t2, 40($t0)
	sw $t2, 44($t0)
	
	addi $t0, $t0, 256
	
	sw $t2, 20($t0)
	sw $t4, 24($t0)
	sw $t2, 28($t0)
	sw $t4, 32($t0)
	sw $t2, 36($t0)
	
	jr $ra
	
win_screen:
	# draw bye screen when exit chosen
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	la $t1, end_pos
	lw $t2, 0($t1) # y axis of bye
	lw $t3, 4($t1) # x axis of bye
	sll $t2, $t2, 8 # y * 256
	sll $t3, $t3, 2 # x * 4
	add $t2, $t2, $t3 # address of bye
	add $t0, $t0, $t2
	
	li $t1, HOT_PINK
	li $t2, PARCHMENT
	li $t3, BLACK
	li $t4, RED
	li $t5, YELLOW
	li $t6, SILVER
	li $t7, ORANGE
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	addi $t0, $t0, 256
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t1, 44($t0)
	
	sw $t3, 48($t0)
	sw $t3, 64($t0)
	sw $t5, 68($t0)
	sw $t4, 72($t0)
	sw $t4, 84($t0)

	sw $t1, 88($t0)
	
	addi $t0, $t0, 256
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t1, 44($t0)
	
	sw $t3, 48($t0)
	sw $t3, 64($t0)
	sw $t5, 68($t0)
	sw $t4, 72($t0)
	sw $t4, 76($t0)
	sw $t4, 84($t0)
	
	sw $t1, 88($t0)
	
	addi $t0, $t0, 256
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t1, 44($t0)
	
	sw $t3, 48($t0)
	sw $t3, 56($t0)
	sw $t3, 64($t0)
	sw $t5, 68($t0)
	sw $t4, 72($t0)
	sw $t4, 80($t0)
	sw $t4, 84($t0)
	
	sw $t1, 88($t0)
	
	addi $t0, $t0, 256
	sw $t5, 0($t0)
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t3, 12($t0)
	sw $t2, 16($t0)
	sw $t3, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t5, 32($t0)
	sw $t5, 36($t0)
	sw $t1, 44($t0)
	
	sw $t3, 48($t0)
	sw $t3, 56($t0)
	sw $t3, 64($t0)
	sw $t5, 68($t0)
	sw $t4, 72($t0)
	sw $t4, 84($t0)
	
	sw $t1, 88($t0)
	
	addi $t0, $t0, 256
	sw $t5, 0($t0)
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t7, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t2, 28($t0)
	sw $t5, 32($t0)
	sw $t5, 36($t0)
	sw $t6, 40($t0)
	sw $t1, 44($t0)
	
	sw $t3, 52($t0)
	sw $t3, 60($t0)
	sw $t5, 68($t0)
	sw $t4, 72($t0)
	sw $t4, 84($t0)
	sw $t1, 88($t0)
	
	addi $t0, $t0, 256
	sw $t5, 4($t0)
	sw $t2, 8($t0)
	sw $t2, 12($t0)
	sw $t2, 16($t0)
	sw $t2, 20($t0)
	sw $t2, 24($t0)
	sw $t5, 28($t0)
	sw $t6, 36($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	addi $t0, $t0, 256
	sw $t5, 8($t0)
	sw $t5, 12($t0)
	sw $t5, 16($t0)
	sw $t5, 20($t0)
	sw $t5, 24($t0)
	sw $t6, 32($t0)
	
	addi $t0, $t0, 256
	sw $t5, 12($t0)
	sw $t5, 16($t0)
	sw $t5, 20($t0)
	sw $t6, 28($t0)
	
	addi $t0, $t0, 256
	sw $t7, 12($t0)
	sw $t7, 20($t0)
	
	addi $t0, $t0, 256
	sw $t7, 8($t0)
	sw $t7, 12($t0)
	sw $t7, 20($t0)
	sw $t7, 24($t0)
	
	jr $ra
	
gravity:
	# character fall by gravity
	
	# if character is on stone then no gravity
	lw $t0, on_stone
	bne $t0, $zero, fall_end 
	
	# once in 2 * level iteration
	lw $t0, iteration
	lw $t2, level
	
	li $t1, 2
	mult $t1, $t2
	mflo $t1
	
	div $t0, $t1
	mfhi $t3 # remainder
	
	bne $t3, $zero, fall_end
	
	lw $t0, status
	# if chick
	chick_fall:
	li $t2, 1
	beq $t0, $t2, chicken_fall
	la $t0, chick_pos
	la $t1, chick_end
	j fall_cont
	# if chicken
	chicken_fall:
	la $t0, chicken_pos
	la $t1, chicken_end
	# continue
	fall_cont:
	lw $t2, 0($t0) # y of character
	lw $t3, 0($t1) # y of character end
	
	# if y of character end < 31 then move down but if not don't move
	li $t4, 31
	bge $t3, $t4, fall_end
	
	addi $t2, $t2, 1 # increase 1 to go down
	addi $t3, $t3, 1 # increase 1 to go down
	
	sw $t2, 0($t0) # update y of character
	sw $t3, 0($t1) # update y of character end
	
	fall_end:
	jr $ra
	
check_on_top:
	# check if character is on top of stone
	lw $t0, status
	# if chick
	chick_on_top:
	bne $t0, $zero, chicken_on_top
	la $t0, chick_pos
	la $t1, chick_end
	j check_on_top_cont
	# if chicken
	chicken_on_top:
	la $t0, chicken_pos
	la $t1, chicken_end
	
	check_on_top_cont:
	la $t2, stone_pos
	lw $t3, 0($t2) # y of stone pos
	lw $t4, 4($t2) # x of stone pos
	
	lw $t7, 4($t0) # x of char pos
	
	lw $t5, 0($t1) # y of char end
	lw $t6, 4($t1) # x of char end
	
	# check if y of char end = y of stone pos
	bne $t5, $t3, not_on_top
	# check if x of stone <= x of char pos && x of char end <= x of stone + 20
	bgt $t4, $t7, not_on_top
	addi $t4, $t4, 20
	bgt $t6, $t4, not_on_top
	# it is on top
	la $t8, on_stone
	li $t9, 1
	sw $9, 0($t8)
	j exit_check_on_top
	
	not_on_top:
	la $t8, on_stone
	sw $zero, 0($t8)
	
	exit_check_on_top:
	jr $ra
	
obj_random:
	# generate random value between 0-5 and change status of the object 
	# pop caller's $ra
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	
	li $v0, 42
	li $a0, 0
	li $a1, 6
	syscall
	
	move $t1, $a0
	li $t4, 1
	# if 0 then normal egg, 1, 2 then poisonous egg, 3, 4 then bird, 5 then mushroom
	# likeliness of egg: 1/6, poisonous egg: 1/3, bird: 1/3, mushroom: 1/6
	li $t2, 5
	beq $t1, $t2, make_mushroom
	li $t2, 4
	beq $t1, $t2, make_bird
	li $t2, 3
	beq $t1, $t2, make_bird
	li $t2, 2
	beq $t1, $t2, make_poisonous
	li $t2, 1
	beq $t1, $t2, make_poisonous
	make_egg:
	la $t3, egg_status
	lw $t5, 0($t3)
	# if egg already exists then make bird
	beq $t5, $t4, make_bird
	sw $t4, 0($t3)
	j obj_random_end
	
	make_bird:
	la $t3, bird_status
	lw $t5, 0($t3)
	# if bird already exists then make poisonous
	beq $t5, $t4, make_poisonous
	sw $t4, 0($t3)
	j obj_random_end
	
	make_poisonous:
	la $t3, poisonous_status
	lw $t5, 0($t3)
	# if poisonous already exists then make mushroom
	beq $t5, $t4, make_mushroom
	sw $t4, 0($t3)
	j obj_random_end
	
	make_mushroom:
	la $t3, mushroom_status
	lw $t5, 0($t3)
	# if mushroom already exists then make egg
	beq $t5, $t4, make_egg
	sw $t4, 0($t3)
	
	obj_random_end:
	# push caller's $ra
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	
	jr $ra
