# FileName: checkIfPrime.s
# Author: Matthew Green
# Date: 11/07/2022
# Assignment: EN.605.204.83 Module 10 Choice 2
# Purpose: To determine if the user's number is prime

.text
.global main
main:
	# program directory
	# r4 - user input, n
	# r5 - number n is divided by to check if remainder is 0, from 0 to n/2
	# r6 - n/2, the largest number to check for divisibility
	# r7 - used to incremenent r5 by itself over and over until 
	#      the number is either equal to or greater than n

	# push to stack
	SUB sp, sp, #20
	STR lr, [sp]
	STR r4, [sp, #4]
	STR r5, [sp, #8]
	STR r6, [sp, #12]
	STR r7, [sp, #16]

	# prompt for and scan user input
	LDR r0, =prompt1
	BL printf
	LDR r0, =format1
	LDR r1, =num1
	BL scanf
	LDR r4, =num1
	LDR r4, [r4]

	# if n = -1, exit
	MOV r0, #-1
	CMP r0, r4
	BEQ ExitEarly

	# if n < 3, declare invalid and exit
	MOV r0, #3
	CMP r4, r0
	BLT InvalidEntry

	# Entry is valid. Initialize starting divisor (r5) to 2, store this number in 
	# r7 for it to be incremented if necessary, and store n/2 in r6
	MOV r5, #2
	MOV r0, r4
	MOV r1, #2
	BL __aeabi_idiv
	MOV r6, r0
	MOV r7, r5

	# check loop ending condition: if the number n is either divisible or not divisible
	# by a number less than or equal to half of n. If the number we are dividing n by
	# is neither equals to or greater than n, we must increment it by its own value
	# and check again.
	StartLoop:
		CMP r4, r7
		BEQ IsDivisible
		CMP r4, r7
		BLT NotDivisible
		ADD r7, r7, r5
		B StartLoop

	# n is divisible by some number 2 through n/2, and thus is not prime
	IsDivisible:
		LDR r0, =outIsDivisible
		MOV r1, r4
		BL printf
		B EndLoop

	# n is not divisible by the current number; increment the current number by 1.
	# if this new number > n/2, n is prime. Else, start the loop over with the new divisor.
	NotDivisible:
		ADD r5, r5, #1
		MOV r7, r5
		CMP r5, r6
		BLE StartLoop

	# if we reach this line, we checked all divisors from 2 to n/2 and none had a remainder 0,
	# so the input is prime
		LDR r0, =outIsPrime
		MOV r1, r4
		BL printf
		B EndLoop

	InvalidEntry:
		LDR r0, =outInvalidEntry
		BL printf
		B EndLoop

	ExitEarly:
		LDR r0, =outExitEarly
		BL printf
		B EndLoop

	EndLoop:

	# pop from stack
	LDR lr, [sp]
	LDR r4, [sp, #4]
	LDR r5, [sp, #8]
	LDR r6, [sp, #12]
	LDR r7, [sp, #16]
	ADD sp, sp, #20
	MOV pc, lr

.data
	prompt1: .asciz "\nEnter a number greater than 2, or enter -1 to exit\n"
	format1: .asciz "%d"
	num1: .word 0
	outExitEarly: .asciz "\nTerminating early\n"
	outInvalidEntry: .asciz "\nInvalid Entry. Number must be greater than 2.\n"
	outIsDivisible: .asciz "The number %d is not prime.\n"
	outIsPrime: .asciz "The number %d is prime.\n" 
