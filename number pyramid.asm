#Author: Boyan Hristov
#Date:	10/12/2018
#Program name: Number diamond
#About this program: it takes a an int number preferably
# between 2-9 and it displays a number diamond

.data
#.eqv	SPACE	' ' # doesn't work for some reason
#.eqv	NEWLINE	'\n' # doesn't work
.eqv	PRINT_INT	1
.eqv	PRINT_STR	4
.eqv	READ_INT	5
.eqv	TERMINATE	10
.eqv	PRINT_CHAR	11

msg:	.asciiz	"Enter int: "

.text
.globl main
main:
	la	$a0, msg
	ori	$v0, $0, PRINT_STR
	syscall
	
	ori	$v0, $0, READ_INT
	syscall
	
	or	$t0, $0, $v0 	# holds max num level/ also max num
	ori	$t1, $0, 1	# holds first level/ first num and last num
	ori	$t3, $0, 1	# holds current level	

upper_half:
	# print a newline on every loop iteration
	ori	$v0, $0, PRINT_CHAR
	ori	$a0, $0, '\n'
	syscall

	or	$a0, $0, $t3	# passing current level
	or	$a1, $0, $t0	# passing max num
	jal	num_spaces	# calculates number of spaces
	
	or	$a0, $0, $v0	# passing the number of spaces
	jal	print_spaces	# prents spaces on the current line
	
	or	$a0, $0, $t1	# passes the first num
	or	$a1, $0, $t3	# passes the current level
	jal	print_inc_numbers	# prints the nums in increasing order
	
	addi	$t3, $t3, 1	# increment current level
	seq	$t4, $t3, 2	# if we just reach 2 this means
				# that we were just at 1
				# this means that we don't want to print
				# the decrementing loop
				
	
	beq	$t4, 1, upper_half	# loops back and prints the next line
	
	addi	$a0, $a1, -1	# offsets the number, beginning number
	or	$a1, $0, $t1	# ending number
	jal	print_dec_numbers	# prints the nums in decreasing order
	
	# checks to see if we have reached the final level
	# because of the way we increment we will check to see if
	# current level - 1 is = to max level
	addi	$t5, $t3, -1
	seq	$t5, $t5, $t0
	
	beq	$t5, 0, upper_half
	
lower_half_prep:
	# $t0 - holds max num of levels
	addi	$t3, $t0, -1	# holds current level
	ori	$t1, $0, 1	# holds last level/ first num and last num
	
lower_half:
		# print a newline on every loop iteration
	ori	$v0, $0, PRINT_CHAR
	ori	$a0, $0, '\n'
	syscall

	or	$a0, $0, $t3	# passing current level
	or	$a1, $0, $t0	# passing max num level
	jal	num_spaces	# calculates number of spaces
	
	or	$a0, $0, $v0	# passing the number of spaces
	jal	print_spaces	# prents spaces on the current line
	
	or	$a0, $0, $t1	# passes the first num
	or	$a1, $0, $t3	# passes the current level
	jal	print_inc_numbers	# prints the nums in increasing order
	
	addi	$t3, $t3, -1	# decrement current level
	seq	$t4, $t3, 0	# if we just reach 0 this means
				# that we were just at 1
				# we don't want to print
				# the decrementing loop
				
	
	beq	$t4, 1, end_program	# loops back and prints the next line
	
	addi	$a0, $a1, -1	# offsets the number, beginning number
	or	$a1, $0, $t1	# ending number
	jal	print_dec_numbers	# prints the nums in decreasing order
	
	# checks to see if we have reached the final level
	# because of the way we increment we will check to see if
	# current level + 1 is = to max level
	addi	$t5, $t3, +1
	seq	$t5, $t5, $t0
	
	beq	$t5, 0, lower_half
	
end_program:
	ori	$v0, $0, TERMINATE
	syscall

# End of main

#**************************************

# Definitions of the procedures used

#**************************************
# Notea: 
#	registers $t4, $t5, $t6, $t7 are available to be used freely
#
#
#
#**************************************

# parameters:
#	$a0 - current level
#	$a1 - max level
# return: num of spaces required in $v0
num_spaces:
	sub	$v0, $a1, $a0
	jr	$ra

#*****************************************
# parameters:
#	$a0 - num spaces to print
# Registers used:
#	$t4 - loops until it reaches $a0
#	$t5 - holds num of spaces
#	$t6 - bool eval
# return: void
print_spaces:
	or	$t5, $0, $a0	# moves the num of spaces
	xor	$t4, $t4, $t4	# count of printed spaces
	
print_loop:
	# we don't want to print spaces if we are already greater
	slt	$t6, $t4, $t5	# is $t4 lesser than $t5
	beq	$t6, 0, end_print_space
	
	ori	$a0, $0, ' '
	ori	$v0, $0, PRINT_CHAR
	syscall
	
	#slt	$t6, $t4, $t5	# is $t4 lesser than $t5
	addi	$t4, $t4, 1	# increments spaces printed
	#beq	$t6, 1, print_loop # if true print another space
	b	print_loop
	
end_print_space:
	jr	$ra

#*****************************************
# parameters:
#	$a0 - holds first number
#	$a1 - holds max number
# return: void
# Registers used:
#	$t4 - start num; counter
#	$t5 - max num inclusive
#	$t6 - bool value
print_inc_numbers:
	or	$t4, $0, $a0 # min num; counter
	or	$t5, $0, $a1 # max num

print_inc_loop:
	or	$a0, $0, $t4
	ori	$v0, $0, PRINT_INT
	syscall
	
	seq	$t6, $t4, $t5
	addi	$t4, $t4, 1 # increm. loop
	beq	$t6, 0, print_inc_loop # if $t6 false
	
	jr	$ra

#*****************************************
# parameters:
#	$a0 - holds first number; max
#	$a1 - holds max number; min
# return: void
# Registers used:
#	$t4 - max num;
#	$t5 - end num; min
#	$t6 - bool value
print_dec_numbers:
	or	$t4, $0, $a0
	or	$t5, $0, $a1

print_dec_loop:
	or	$a0, $0, $t4
	ori	$v0, $0, PRINT_INT
	syscall
	
	seq	$t6, $t4, $t5 # is max == min?
	addi	$t4, $t4, -1 # dec max num
	beq	$t6, 0, print_dec_loop
	
	jr	$ra
	
#*****************************************
# End of Procedure definitions
# End of program