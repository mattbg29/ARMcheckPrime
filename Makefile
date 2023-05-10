All: checkIfPrime guessNumber
CC=gcc

checkIfPrime: checkIfPrime.o
	$(CC) $@.o -g -o $@

guessNumber: guessNumber.o 
	$(CC) $@.o -g -o $@

.s.o:
	$(CC) $(@:.o=.s) -g -c -o $@
