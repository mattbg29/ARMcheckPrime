# FileName: guessNumber.s
# Author: Matthew Green
# Date: 11/07/2022
# Assignment: EN.605.204.83 Module 10 Choice 4
# Purpose: To prompt a user for a max number, then attempt to guess the user's
#    	   number between 1 and the max number using binary search, each time 
#	   asking the user if the true number is lower, equal to, or greater than the guess

.text
.global main
main:
	# program dictionary
	# r4 - the number of guesses the program has made
	# r5 - the program's guess
	# r6 - the user's response to the program guess
	# r7 - the guess lower bound 
	# r8 - the guess upper bound
	# r9 - a binary to represent that the last user feedback was lower (0) or higher (1)

	# push to stack
	SUB sp, sp, #28
	STR lr, [sp]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]
	STR r8, [sp, #20]
	STR r9, [sp, #24]

	# prompt and scan the max number from the user
	LDR r0, =promptMax
	BL printf
	LDR r0, =formatNum
	LDR r1, =maxNum
	BL scanf
	LDR r8, =maxNum
	LDR r8, [r8]

	# if maxNum is less than 1, exit
	MOV r0, #1
	CMP r8, r0
	BLE InvalidEntry

	# initialize lower bound to 1, number of guesses to 0, and the guess and binary 
	# flag for the last user input each to -1 as a placeholder
	MOV r7, #1
	MOV r4, #0
	MOV r5, #-1
	MOV r9, #-1

	# make a guess that the number is the average of the lower and upper bound
	# and prompt user for a response.  Add 1 to the program guess count.
	# If the new guess matches the last guess, then the program must be 1 away from
	# the correct answer and branches to OneAway to manage that circumstance. 
	#
	# Please note: this does not technically follow the specific format of checking
	#	the end condition first, because to do so would involve copying the code
	#	that calculates the guess and asks the user for their input in 3 separate
	#	places instead of just one, so I elected to include it first in the loop
	#	before checking for the end condition.  I hope that is alright! 
	StartLoop:
		ADD r4, r4, #1
		ADD r0, r8, r7
		MOV r1, #2	
		BL __aeabi_idiv // calculate the guess
		CMP r0, r5
		BEQ OneAway

		MOV r5, r0 // store the guess in r5

		LDR r0, =promptAnswer
		MOV r1, r5
		BL printf
		LDR r0, =formatNum
		LDR r1, =userAnswer
		BL scanf
		LDR r6, =userAnswer
		LDR r6, [r6]

		# Branch depending on user's response
		MOV r0, #0
		CMP r0, r6
		BEQ IsSmaller

		MOV r0, #1
		CMP r0, r6
		BEQ IsEqual

		MOV r0, #2
		CMP r0, r6
		BEQ IsGreater

		# If program arrives here, user has not input a 0, 1, or 2
		B InvalidEntry

		# If user's number is smaller than the guess, update the upper bound to the most recent
		# guess, mark that the most recent feedback is that it is smaller (set r9 to 0)  and 
		# start the loop over
		IsSmaller:
			MOV r9, #0
			MOV r8, r5
			B StartLoop

		# If the user's number is greater than the guess, update the lower bound to the 
		# most recent guess, set r9 to be 1 to indicate that the most recent feedback is that 
		# the user's number is greater than the guess,  and start the loop over
		IsGreater:
			MOV r9, #1
			MOV r7, r5
			B StartLoop

		# If the guess is one away and the most recent user message was that the number is less than
		# the guess (r9 = 0), subtract one and return this as the answer, else add 1 and return this
		# as the answer
		OneAway:
			MOV r0, #0
			CMP r0, r9
			BEQ SubtractOne

			# we are one away and were last too small; add one and end the program
				ADD r5, r5, #1
				B IsEqual

			# we are one away and were last too large; subtract one and end the program
			SubtractOne:
				SUB r5, r5, #1
				B IsEqual


		# If the program guessed correctly, output the correct guess and how many guesses this took and
		# end the loop
		IsEqual:
			LDR r0, =correctGuess
			MOV r1, r5
			BL printf

			LDR r0, =outNumGuesses
			MOV r1, r4
			BL printf
			B EndLoop
		
	InvalidEntry:
		LDR r0, =outInvalidEntry
		BL printf
		B EndLoop

	EndLoop:

	# pop from stack
	LDR lr, [sp]
	LDR r4, [sp, #4]
	LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	LDR r8, [sp, #20]
	LDR r9, [sp, #24]
	ADD sp, sp, #28
	MOV pc, lr


.data
	promptMax: .asciz "\nI am going to try to guess your secret number that is between 1 and some upper bound.\nEnter the maximum number for me to try to guess, greater than 1\n"
	formatNum: .asciz "%d"
	maxNum: .word 0
	outInvalidEntry: .asciz "Entry is invalid. Terminating program.\n"
	correctGuess: .asciz "\nYour number is %d\n"
	outNumGuesses: .asciz "\nThis took %d guesses.  Thanks for playing.\n\n" 
	promptAnswer: .asciz "\nMy guess is %d. Enter \n0 if your number is lower, \n1 if equal, or \n2 if higher\n"
	userAnswer: .asciz "%d"
