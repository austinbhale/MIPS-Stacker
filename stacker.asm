##############################################################################################
#												#
########################################## Stacker ########################################### 
#												#
# 	@author: Austin Hale (with Montek Singh's initial template)			   	#
#  	@date: 11/9/2020									#
#												#
# This program assumes the memory-IO map introduced in class specifically for the final	#
# projects.  In MARS, please select:  Settings ==> Memory Configuration ==> Default.		#
#												#
##############################################################################################

.data 0x10010000 			# Start of data memory
a_sqr:	.space 4
a:	.word 3

.text 0x00400000			# Start of instruction memory
main:
	lui 	$sp, 0x1001		# Initialize stack pointer to the 64th location above start of data
	ori 	$sp, $sp, 0x1000	# top of the stack is the word at address [0x10010ffc - 0x10010fff]
	addi $fp, $sp, -4 		# Set $fp to the start of main's stack frame
	
	###############################################
	# ANIMATE character on screen                 #
	#                                             #
	# To eliminate pauses (for Vivado simulation) #
	# replace the two "jal pause" instructions    #
	# by nops.                                    #
	###############################################

begin:
	jal 	get_key
	bne	$v0, 2, begin_button
	j	clean_board
	begin_button:
	jal	get_btns
	bne	$v0, 2, begin				# hit enter or top btn to begin the game, else loop infinitely here
	
# clear board. for 13 <= x <= 24; for 11 <= y <= 25;
# temporary stored registers: s4 = sprite, s5 = x, s6 = y, s7 = comparison
clean_board:
	li 	$s5, 12
	li 	$s6, 10
	j	LoopX

	LoopX:
	
	addi 	$s5, $s5, 1
	slti 	$s7, $s5, 25	
	beq 	$s7, 0, store_main_vals
	
	LoopY:
	
	addi 	$s6, $s6, 1
	slti 	$s7, $s6, 25
	li	$s4, 1			# Blue
	move 	$a1, $s5
	move 	$a2, $s6
	
	bne	$s6, 16, gold_replace
	li	$s4, 3			# Gold
	j	reg_replace
	gold_replace:
	bne	$s6, 11, reg_replace
	li	$s4, 4			# Bronze
	reg_replace:
	move	$a0, $s4
	jal	putChar_atXY	
	beq 	$s7, 1, LoopY
	li 	$s6, 10
	j 	LoopX

# default stored registers
store_main_vals:
	#li $s2, 23	# for MARS MMIO simulator or it throws a range error
	li $s0, 11	# speed that will decrement as you keep winning
	li $s1, 13	# col 13
	li $s2, 25	# row 25
	li $s3, 0	# 0 for continue, 1 for stop
	li $s4, 1	# -1 for left, 1 for right
	li $s6, 2	# decrements to 0 when starting a new row based on the current level
	li $s7, 2	# current level = 2 for 3 blocks, 1, and 0

animate_loop:	
	li	$a0, 5			# draw player 1 here
	move 	$a1, $s1
	move 	$a2, $s2
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	
	#debugging purposes in MARS
	#######################################
	#li	$a0, 2			# draw player 2 here
	#li $a1, 26
	#li $a2, 16
	#jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	#li	$a0, 2			# draw player 2 here
	#li $a1, 15
	#li $a2, 16
	#jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	#########################################
	
	#jal	get_accelX		# get front to back board tilt angle
	#sll	$a0, $v0, 12		# multiply by 2^12
	#jal	put_sound		# create sound with that as period
	#jal	get_accelY		# get left to right tilt angle
	#srl	$v0, $v0, 5		# keep leftmost 4 bits out of 9
	
	move	$a0, $s0
	jal 	pause_and_getkey	# pauses based on the speed of the animating blocks
	
	beq	$v0, 3, clean_board
	
	slti	$1, $s2, 11		# infinite loop on a win	
	bne	$1, $0, NEXT

	# Keypress implementation, loop until key release to prevent multiple moveUps
	beq	$v0, 0, check_button
	beq	$s3, 1, NEXT
	move	$s3, $v0                # save keys in $s registers to protect them from called procedures
	j	PLAYER1
		
	check_button:
	jal	get_btns		# get center button
	beq	$v0, 0, reset
	beq	$s3, 1, NEXT
	move	$s3, $v0 
	j	PLAYER1
	
	reset:
	li 	$s3, 0

PLAYER1:
	move 	$a0, $s5
	move 	$a1, $s1
	move 	$a2, $s2
	jal	move_player             # call move_player with PLAYER 1�s position and key
	move 	$s1, $v0
	move 	$s2, $v1
	
	# Current player's lights based on x value
	bne	$s7, 2, TwoBlock
	li	$a0, 7			# 0000000000000111
	j	PrepShift
	TwoBlock:
	bne	$s7, 1, OneBlock
	li	$a0, 3			# 0000000000000011
	j	PrepShift
	OneBlock:
	bne	$s7, 0, ZeroBlock		
	li	$a0, 1			# 0000000000000001
	j	PrepShift
	ZeroBlock:
	li	$a0, 0
	j	Lights
	PrepShift:
	sll	$a0, $a0, 2		# XX000000000111XX only use the 12 inner bits (ignore 2 left and 2 right)
	li	$t1, 24
	sub	$t0, $t1, $s1				
	sllv	$a0, $a0, $t0
	beq	$s7, 0, Lights
	# was moving left
	beq	$s4, 1, Lights
	li	$a3, 1
	bne	$s7, 2, Pass3LightR
	addi	$a3, $a3, 1
	Pass3LightR:
	srlv	$a0, $a0, $a3
	j	Lights
	Lights:
	jal	put_leds		# one LED will be lit

NEXT:
	j	animate_loop            # go back to start of animation loop
	
					
	###############################
	# END using infinite loop     #
	###############################
end:
	j	end          	# infinite loop "trap" because we don't have syscalls to exit


######## END OF MAIN #################################################################################

.text

#####################################
# procedure move_player
# $a0:  key
# $a1:  x coord
# $a2:  y coord
#
# return values:
# $v0:  new x coord
# $v1:  new y coord
#####################################

move_player:
    	addi    $sp, $sp, -8        	# Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         	# Save $ra
    	sw      $fp, 0($sp)        	# Save $fp
    	addi    $fp, $sp, 4        	# Set $fp to the start of proc1's stack frame
                    
	move 	$v0, $a1
	move 	$v1, $a2

Stop:
	beq	$s3, 1, MoveUp

Move:
	beq	$s4, -1, MoveLeft

MoveRight:
	addi 	$v0, $v0, 1 		# move right
	slti 	$1, $v0, 25		
	bne	$1, $0, DrawOver
	addi	$t0, $s7, -23
	### absolute value of $t0 ###
	sra 	$t1, $t0, 31   
	xor 	$t0, $t0, $t1   
	sub 	$t0, $t0, $t1 
	#############################
	move	$v0, $t0		
	li	$s4, -1			# initiate move left
	j	DrawOver

MoveLeft:
	addi 	$v0, $v0, -1 		# move left
	sgt	$1, $v0, 12		
	bne	$1, $0, DrawOver
	subi	$t0, $s7, -14
	### absolute value of $t0 ###
	sra 	$t1, $t0, 31   
	xor 	$t0, $t0, $t1   
	sub 	$t0, $t0, $t1 
	#############################
	move	$v0, $t0		
	li	$s4, 1			# initiate move right
	j	DrawOver

MoveUp:
	# Player advances
	subi    $v1, $v1, 1 		# move up
	
	# if y <= 24, we check the row below to see what's valid
	# Conditionals for checking a valid placement
	sgt 	$t3, $a2, 24
	beq 	$t3, 0, PlayerBuffer
	# rare edge case when a user clicks too fast on start, 
	# before the starting blocks initialize to 3
	slti	$t2, $s1, 15
	bne	$s4, 1, AfterChecks	# only at start going right
	bne	$t2, 1, AfterChecks
	# $s7 = $s1 - 13 (result is either 0 or 1)
	subi	$s7, $s1, 13
	j 	AfterChecks
	
	PlayerBuffer:
	# $s7 + (2 - $s7). buffer for 3 subtractions on a miss
	li	$t2, 2
	sub	$t2, $t2, $s7
	add	$s7, $t2, $s7
	
	# $a0 holds the replacement pixel after the play goes through it
	li	$a0, 1
	bne	$s2, 16, DrawGold
	li	$a0, 3			# Bronze
	j	DrawReg
	DrawGold:
	bne	$s2, 11, DrawReg
	li	$a0, 4			# Gold
	
	DrawReg:
	# cursor was moving left, so we look at the cursor and 2 on right
	beq 	$s4, 1, MovedRight
	move	$a1, $s1
	addi	$a2, $s2, 1
	jal 	getChar_atXY
	beq	$v0, 5, SkipR1
	subi	$s7, $s7, 1		# player loses a block
	beq	$v0, 0, SkipR1		# ignore out of bounds
	move	$a1, $s1
	move	$a2, $s2
	jal	putChar_atXY
	SkipR1: 
	# ensure the tails are lit
	addi	$a1, $s1, 1
	move	$a2, $s2
	jal 	getChar_atXY	
	beq	$v0, 5, UnderR1		# is a light blue block
	subi	$s7, $s7, 1
	j	SkipR2
	UnderR1:
	addi 	$t1, $s1, 1		# 1 right of the cursor
	move	$a1, $t1
	move	$a2, $s2
	addi	$a2, $s2, 1
	jal 	getChar_atXY
	beq	$v0, 5, SkipR2
	subi	$s7, $s7, 1		# player loses a block
	beq	$v0, 0, SkipR2		# ignore out of bounds
	move	$a1, $t1
	move	$a2, $s2
	jal	putChar_atXY
	SkipR2: 
	# ensure the tails are lit
	addi	$a1, $s1, 2
	move	$a2, $s2
	jal 	getChar_atXY	
	beq	$v0, 5, UnderR2		# is a light blue block
	subi	$s7, $s7, 1
	j	AfterChecks
	UnderR2:
	addi 	$t1, $s1, 2		# 2 right of the cursor
	move	$a1, $t1
	move	$a2, $s2
	addi	$a2, $s2, 1
	jal 	getChar_atXY
	beq	$v0, 5, AfterChecks
	subi	$s7, $s7, 1		# player loses a block
	beq	$v0, 0, AfterChecks	# ignore out of bounds
	move	$a1, $t1
	move	$a2, $s2
	jal	putChar_atXY
	j	AfterChecks
	
	# cursor was moving right, so we look at the cursor and 2 on left
	MovedRight:
	move	$a1, $s1
	move	$a2, $s2
	addi	$a2, $s2, 1
	jal 	getChar_atXY
	beq	$v0, 5, SkipL1
	subi	$s7, $s7, 1		# player loses a block
	beq	$v0, 0, SkipL1		# ignore out of bounds
	move	$a1, $s1
	move	$a2, $s2
	jal	putChar_atXY
	SkipL1: 
	# ensure the tails are lit
	subi	$a1, $s1, 1
	move	$a2, $s2
	jal 	getChar_atXY	
	beq	$v0, 5, UnderL1		# is a light blue block
	subi	$s7, $s7, 1
	j	SkipL2
	UnderL1:
	subi 	$t1, $s1, 1		# 1 left of the cursor
	move	$a1, $t1
	move	$a2, $s2
	addi	$a2, $s2, 1
	jal 	getChar_atXY
	beq	$v0, 5, SkipL2
	subi	$s7, $s7, 1		# player loses a block
	beq	$v0, 0, SkipL2		# ignore out of bounds
	move	$a1, $t1
	move	$a2, $s2
	jal	putChar_atXY
	SkipL2: 
	# ensure the tails are lit
	subi	$a1, $s1, 2
	move	$a2, $s2
	jal 	getChar_atXY	
	beq	$v0, 5, UnderL2		# is a light blue block
	subi	$s7, $s7, 1
	j	AfterChecks
	UnderL2:
	subi 	$t1, $s1, 2		# 2 left of the cursor
	move	$a1, $t1
	move	$a2, $s2
	addi	$a2, $s2, 1
	jal 	getChar_atXY
	beq	$v0, 5, AfterChecks
	subi	$s7, $s7, 1		# player loses a block
	beq	$v0, 0, AfterChecks	# ignore out of bounds
	move	$a1, $t1
	move	$a2, $s2
	jal	putChar_atXY
		
	AfterChecks:
	# if $s7 > -1, we keep playing
	sgt	$t1, $s7, -1
	beq	$t1, 1, PlayerPasses
	# loss sound
	# a4, e4, d4, c4, a3
	# {227273, 303372, 340524, 382219, 454545}
	li	$a0, 227273
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 303372
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 340524
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 382219
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 454545
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 0
	jal	put_sound
	j	begin
	
	PlayerPasses:
	# c6 - success sound
	# 95556
	li	$a0, 95556
	jal	put_sound
	li	$a0, 10
	jal	pause
	li	$a0, 0
	jal	put_sound
	
	# if y <= 10, we have a winner
	sgt 	$t3, $v1, 10
	beq 	$t3, 1, RowLevelPrep 	# still playing
	
	### winner animation + sound! ###
	# Sound (State Farm jingle): ab4, c5, eb5, g5, ab5, db6, c6, bb5, c6
	# {240786, 191113, 160706, 127552, 120394, 90193, 95556, 107258, 95556}
	li	$a0, 4
	jal	change_board_color
	li	$a0, 240786
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 5
	jal	change_board_color
	li	$a0, 191113
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 6
	jal	change_board_color
	li	$a0, 160706
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 8
	jal	change_board_color
	li	$a0, 127552
	jal	put_sound
	li	$a0, 60
	jal	pause
	li	$a0, 7
	jal	change_board_color
	li	$a0, 120394
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 9
	jal	change_board_color
	li	$a0, 90193
	jal	put_sound
	li	$a0, 60
	jal	pause
	li	$a0, 10
	jal	change_board_color
	li	$a0, 95556
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 9
	jal	change_board_color
	li	$a0, 107258
	jal	put_sound
	li	$a0, 30
	jal	pause
	li	$a0, 10
	jal	change_board_color
	li	$a0, 95556
	jal	put_sound
	li	$a0, 50
	jal	pause
	li	$a0, 0
	jal	put_sound
	j 	clean_board
	#########################
	
	RowLevelPrep:
	# prepare number of blocks for the next row (3, 2, or 1) 
	# default is $s7 = 2 (3 blocks)
	bne	$v1, 17, LVL2		# move to level 3 of 1 block
	li	$s7, 0
	j	NextRow
	LVL2:
	bne	$v1, 21, NextRow	# move to level 2 of 2 blocks
	# if $s7 = 0, skip
	beq	$s7, 0, NextRow
	li	$s7, 1
	NextRow:	
	move	$s6, $s7		# new row
	
	andi	$t0, $v1, 1		# set to 1 for odd row, 0 for even
	beq	$t0, 0, SetRight
	li	$v0, 13			# set to left-most column
	li	$s4, 1			# go right
	j	Speed
	SetRight:
	li	$v0, 24			# set to right-most column
	li	$s4, -1			# go left
	
	Speed:
	beq	$v1, 23, fast		# I Am Speed
	beq	$v1, 21, fast
	beq	$v1, 18, fast
	beq	$v1, 15, fast
	beq	$v1, 13, fast
	beq	$v1, 11, fast
	j	skipfast
	fast: subi $s0, $s0, 1
	skipfast:
	j	done_moving

DrawOver:
	bne	$s4, -1, ELSE
	sub	$t0, $0, $s7
	j	L1
	ELSE: 	move $t0, $s7
	L1:
	# $a0 holds the replacement pixel after the play goes through it
	li	$a0, 1
	bne	$a2, 16, Gold
	li	$a0, 3			# Bronze
	j	CheckClear
	Gold:
	bne	$a2, 11, CheckClear
	li	$a0, 4			# Gold
	CheckClear:
	sub	$a1, $a1, $t0
	bne	$s6, $0, ResetNew
	sgt	$1, $a1, 23
	bne	$1, $0, clear_right
	slti	$1, $a1, 13
	bne	$1, $0, clear_left
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	j	done_moving
	clear_right:
	li	$a1, 24
	jal	putChar_atXY
	j	done_moving
	clear_left:
	li	$a1, 13
	jal	putChar_atXY
	j	done_moving
ResetNew:
	subi	$s6, $s6, 1

done_moving:

return_from_move_player:
	addi    $sp, $fp, 4     # Restore $sp
	lw      $ra, 0($fp)     # Restore $ra
	lw      $fp, -4($fp)    # Restore $fp
	jr      $ra             # Return from procedure

change_board_color:
	addi	$sp, $sp, -8
	sw	$ra, 4($sp)
	sw	$a0, 0($sp)
	
	li 	$s5, 12
	li 	$s6, 10

	AnimLoopX:
	addi 	$s5, $s5, 1
	slti 	$s7, $s5, 25	
	beq 	$s7, 0, exit_loop
	
	AnimLoopY:
	addi 	$s6, $s6, 1
	slti 	$s7, $s6, 25
	move 	$a1, $s5
	move 	$a2, $s6
	jal	putChar_atXY	
	beq 	$s7, 1, AnimLoopY
	li 	$s6, 10
	j 	AnimLoopX
	
	exit_loop:
	lw	$a0, 0($sp)
	lw	$ra, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra

# =============================================================



.include "procs_board.asm"               # Use this line for board implementation
#.include "procs_mars.asm"                # Use this line for simulation in MARS
