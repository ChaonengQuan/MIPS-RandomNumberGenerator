###
# Multiple Choice Question Simulator(with starting sound)
#	Scenario:	Final exam is tomorrow, but you did not study at all(of course).
#			Therefore, you open this Multiple Choice Question Simulator to see how lucky you are.
#	How it works:
#			Number 0,1,2,3 each represent the first,second,third,fourth answer of mutiple choice questions.
#			All you need to do is enter a number from 0 to 3, just like what you will do on the final exam.
#			The program will keep track of how many times you tried untill the correct answer, and show how
#			lucky you are based on that information.
# @author Chaoneng Quan

##
# Registers used in main()
# $s0 -- the generated random number
# $s1 -- the user input number
# $s2 -- how many time the user has tried untill the correct answer

.data
	TitleMsg:	.asciiz 	"--------------------------------------------------Multiple Choice Question Simulator--------------------------------------------------\n"
	ScenarioMsg:	.asciiz 	"You are now in the final exam classroom scratching your head while looking at the exam paper, and you find this: \n"
	StartMsg:	.asciiz		"Question: 1 + 1 = 2, what is the result of universe expansion?\nChoose the correct anwer from 0 to 3(inclusive)\n"
	InputMsg:	.asciiz 	"Enter the answer you guessed: \n"
	TooLowMsg:	.asciiz 	"Too low, try again.\n"
	TooHighMsg:	.asciiz 	"Too high,try again.\n"
	WinningMsg:	.asciiz 	"That is the correct answer! You Win!!!\n"
	# Below are different quips based on how many times you tried
	zeroTryMsg:	.asciiz 	"You are very lucky today! Do no study just go to the final!\n"
	oneTryMsg:	.asciiz 	"You are kind of lucky today. It took you two tries, studying more will probably help."
	twoTryMsg:	.asciiz 	"You are not that lucky today. Study hard!"
	threeTryMsg:	.asciiz 	"You are absolutly not lucky today! Only study can save you."
	moreTryMsg:	.asciiz 	"Now you know the answer becuase you have tried all other possible answers?"
.text 

##
# This function does the following:
#	1. radomly generates a integer then store it in $s0
#
# Also contains the logic flow of game
#	main(){
#		playStartingSound();
#		printStartingMessages();
#		While(userInput != generatedNumber){
#			if(promptAndCheckUserInput(generatedNumber) == 0)
#				guessedCorrectly();
#				printQuip(userTried);
#			if(promptAndCheckUserInput(generatedNumber) == 1)
#				guessedTooLow();
#			if(promptAndCheckUserInput(generatedNumber) == 2)
#				guessedTooHign();
#			numTried++;
#		}
#	}
main:	
	jal 	playStartingSound
	jal 	printStartingMessages
	# Set up random number generator
	# 	$a0 will be holding the generated integer
	addi	$v0,	$zero,	42		# Service code for generating random int within a range
	addi	$a1,	$zero,	4		# set the upper bond for random ints to be 4(exclusive)
	syscall
	# 	Store the generated number in the $s0 register
	add	$s0,	$zero,	$a0
	#	keep tract how many time user have tried
	add	$s2,	$zero,	$zero		# default 0								
loop:
	add	$a0,	$zero,	$s0		# passing random number by parameter
	jal	promptAndCheckUserInput
	#	check the return value
	bne	$v0,	$zero,	LowOrHigh
	jal 	printGuessedCorrectly
	add	$a0,	$zero,	$s2
	jal 	printQuip
LowOrHigh:
	addi	$t1,	$zero,	1
	beq	$v0,	$t1,	Low		# if returned 1, then prompt user their number is too low
	jal 	printGuessedTooHigh
	addi	$s2,	$s2,	1		# userGuess++
	j loop
Low:
	jal 	printGuessedTooLow
	addi	$s2,	$s2,	1		# userGuess++
	j loop
		
##
# This function does the following:
#	1. compare the user input with the random number	
# Return:
#	0 -- if they are equal
#	1 -- userInput <  the random number
#	2 -- userinput >  the random number
promptAndCheckUserInput:
	# Fucnction prologue
	addiu 	$sp, 	$sp, 	-24 		# allocate stack space -- default of 24 here
	sw 	$fp, 	0($sp) 			# save caller's frame pointer
	sw 	$ra, 	4($sp)			# save return address
	addiu 	$fp, 	$sp, 	20	 	# setup fucntion's frame pointer
	
	add	$t0,	$zero,	$a0		# save generated random number to $t0
	# pring a message to prompt user to enter a number
	addi	$v0,	$zero,	4
	la	$a0,	InputMsg	
	syscall
	# reading user input and store it to $t1
	addi	$v0,	$zero,	5
	syscall
	move	$t1,	$v0			# move the user input from $v0 to $t1
	# check user input with generated number
	bne	$t1,	$t0,	notEqual		# if they are not equal, jump to not equal
	addi	$v0,	$zero,	0			# return 0 if userInput == the random number
	j checkDone
notEqual:
	slt	$t2,	$t1,	$t0
	beq	$t2,	$zero,	tooHigh			# if user guessed is greater than the generated number
	addi	$v0,	$zero,	1			# return 0 if userInput < the random number
	j checkDone
tooHigh:
	addi	$v0,	$zero,	2			# return 0 if userInput > the random number
	j checkDone

checkDone:
	# Function epilogue
	lw 	$ra, 	4($sp) 			# get return address from stack
	lw 	$fp, 	0($sp) 			# restore the caller's frame pointer
	addiu 	$sp, 	$sp, 	24 		# restore the caller's stack pointer
	jr 	$ra 				# return to caller's code

###----------print functions----------###

##
# This function does the following:
#	1. print game starting messages 
printStartingMessages:
	# Fucnction prologue
	addiu 	$sp, 	$sp, 	-24 		# allocate stack space -- default of 24 here
	sw 	$fp, 	0($sp) 			# save caller's frame pointer
	sw 	$ra, 	4($sp)			# save return address
	addiu 	$fp, 	$sp, 	20	 	# setup fucntion's frame pointer

	# Print messages for game starting
	addi	$v0,	$zero,	4	
	la	$a0,	TitleMsg
	syscall
	addi	$v0,	$zero,	4
	la	$a0,	ScenarioMsg
	syscall
	addi	$v0,	$zero,	4	
	la	$a0,	StartMsg
	syscall

	# Function epilogue
	lw 	$ra, 	4($sp) 			# get return address from stack
	lw 	$fp, 	0($sp) 			# restore the caller's frame pointer
	addiu 	$sp, 	$sp, 	24 		# restore the caller's stack pointer
	jr 	$ra 				# return to caller's code
	
##
# This function does the following:
#	1. print a message to prompt the user the number is too low
printGuessedTooLow:
	# Fucnction prologue
	addiu 	$sp, 	$sp, 	-24 		# allocate stack space -- default of 24 here
	sw 	$fp, 	0($sp) 			# save caller's frame pointer
	sw 	$ra, 	4($sp)			# save return address
	addiu 	$fp, 	$sp, 	20	 	# setup fucntion's frame pointer
	
	addi	$v0,	$zero,	4
	la	$a0,	TooLowMsg
	syscall

	# Function epilogue
	lw 	$ra, 	4($sp) 			# get return address from stack
	lw 	$fp, 	0($sp) 			# restore the caller's frame pointer
	addiu 	$sp, 	$sp, 	24 		# restore the caller's stack pointer
	jr 	$ra 				# return to caller's code
	
##
# This function does the following:
#	1. print a message to prompt the user the number is too high
printGuessedTooHigh:
	# Fucnction prologue
	addiu 	$sp, 	$sp, 	-24 		# allocate stack space -- default of 24 here
	sw 	$fp, 	0($sp) 			# save caller's frame pointer
	sw 	$ra, 	4($sp)			# save return address
	addiu 	$fp, 	$sp, 	20	 	# setup fucntion's frame pointer
	
	addi	$v0,	$zero,	4
	la	$a0,	TooHighMsg
	syscall

	# Function epilogue
	lw 	$ra, 	4($sp) 			# get return address from stack
	lw 	$fp, 	0($sp) 			# restore the caller's frame pointer
	addiu 	$sp, 	$sp, 	24 		# restore the caller's stack pointer
	jr 	$ra 				# return to caller's code
	
##
# This function does the following:
#	1. print a wining message
printGuessedCorrectly:
	# Fucnction prologue
	addiu 	$sp, 	$sp, 	-24 		# allocate stack space -- default of 24 here
	sw 	$fp, 	0($sp) 			# save caller's frame pointer
	sw 	$ra, 	4($sp)			# save return address
	addiu 	$fp, 	$sp, 	20	 	# setup fucntion's frame pointer
	
	addi	$v0,	$zero,	4
	la	$a0,	WinningMsg
	syscall
	
	# Function epilogue
	lw 	$ra, 	4($sp) 			# get return address from stack
	lw 	$fp, 	0($sp) 			# restore the caller's frame pointer
	addiu 	$sp, 	$sp, 	24 		# restore the caller's stack pointer
	jr 	$ra 				# return to caller's code
	
##
#
#
printQuip:
	# Fucnction prologue
	addiu 	$sp, 	$sp, 	-24 		# allocate stack space -- default of 24 here
	sw 	$fp, 	0($sp) 			# save caller's frame pointer
	sw 	$ra, 	4($sp)			# save return address
	addiu 	$fp, 	$sp, 	20	 	# setup fucntion's frame pointer
	
	addi	$v0,	$zero,	4
	add	$t9,	$a0,	$zero
		
	addi	$t0,	$zero,	0
	addi	$t1,	$zero,	1
	addi	$t2,	$zero,	2
	addi	$t3,	$zero,	3
	
	slt	$t5,	$t9,	$t3
	beq	$t5,	$zero,	moreTry
	beq	$t9,	$t0,	zeroTry
	beq	$t9,	$t1,	oneTry
	beq	$t9,	$t2,	twoTry
	beq	$t9,	$t3,	threeTry
zeroTry:
	la	$a0,	zeroTryMsg
	syscall	
	j quipDone
oneTry:
	la	$a0,	oneTryMsg
	syscall	
	j quipDone
twoTry:
	la	$a0,	twoTryMsg
	syscall	
	j quipDone
threeTry:
	la	$a0,	threeTryMsg
	syscall	
	j quipDone	
moreTry:
	la	$a0,	moreTryMsg
	syscall	
quipDone:
	addi	$v0,	$zero,	10
	syscall
	
	# Function epilogue
	lw 	$ra, 	4($sp) 			# get return address from stack
	lw 	$fp, 	0($sp) 			# restore the caller's frame pointer
	addiu 	$sp, 	$sp, 	24 		# restore the caller's stack pointer
	jr 	$ra 				# return to caller's code
###----------Sound funtions----------###

##
# This function does the following:
#	1. play a tune indicating that the game has started 
# Parameters:
#	$a0 = pitch (0-127)
#	$a1 = duration in milliseconds
#	$a2 = instrument (0-127)
#	$a3 = volume (0-127)
playStartingSound:
	# Fucnction prologue
	addiu 	$sp, 	$sp, 	-24 		# allocate stack space -- default of 24 here
	sw 	$fp, 	0($sp) 			# save caller's frame pointer
	sw 	$ra, 	4($sp)			# save return address
	addiu 	$fp, 	$sp, 	20	 	# setup fucntion's frame pointer
	
	addi	$v0,	$zero,	33
	addi	$a0,	$zero,	75		# pitch = 82	D#
	addi	$a1,	$zero,	500		# duration = 0.5s
	addi	$a2,	$zero,	0		# instrument = piano
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	82		# pitch = 76	A#
	addi	$a1,	$zero,	500		# duration = 0.5s
	addi	$a2,	$zero,	0		# instrument = piano
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	82		# pitch = 76	A#
	addi	$a1,	$zero,	250		# duration = 0.25s
	addi	$a2,	$zero,	0		# instrument = piano
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	80		# pitch = 80	G#
	addi	$a1,	$zero,	250		# duration = 0.25s
	addi	$a2,	$zero,	0
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	82		# pitch = 76	A#
	addi	$a1,	$zero,	500		# duration = 0.5s
	addi	$a2,	$zero,	0		# instrument = piano
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	80		# pitch = 80	G#
	addi	$a1,	$zero,	250		# duration = 0.25s
	addi	$a2,	$zero,	0
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	78		# pitch = 78	F#
	addi	$a1,	$zero,	250		# duration = 0.25s
	addi	$a2,	$zero,	0
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	80		# pitch = 80	G#
	addi	$a1,	$zero,	500		# duration = 0.5s
	addi	$a2,	$zero,	0
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	80		# pitch = 80	G#
	addi	$a1,	$zero,	250		# duration = 0.25s
	addi	$a2,	$zero,	0
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	78		# pitch = 78	F#
	addi	$a1,	$zero,	250		# duration = 0.25s
	addi	$a2,	$zero,	0
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	75		# pitch = 82	D#
	addi	$a1,	$zero,	250		# duration = 0.25s
	addi	$a2,	$zero,	0		# instrument = piano
	addi	$a3,	$zero,	100
	syscall
	addi	$a0,	$zero,	78		# pitch = 78	F#
	addi	$a1,	$zero,	250		# duration = 0.25s
	addi	$a2,	$zero,	0
	addi	$a3,	$zero,	100
	syscall
	
	# Function epilogue
	lw 	$ra, 	4($sp) 			# get return address from stack
	lw 	$fp, 	0($sp) 			# restore the caller's frame pointer
	addiu 	$sp, 	$sp, 	24 		# restore the caller's stack pointer
	jr 	$ra 				# return to caller's code				