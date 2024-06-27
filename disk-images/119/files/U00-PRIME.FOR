	PROGRAM PRIME
C
C   Repeatedly asks for input of a number and prints
C   out its smallest factor, or says it is prime
C
	INTEGER*2  FACTOR,MAXFAC
	INTEGER    NUMBER
C   Start of main loop
   10	WRITE(1,900)
900	FORMAT(' Input a positive number',
     -         ' less than a thousand million: ')
	READ (1,800) NUMBER
800	FORMAT(I9)
	IF (NUMBER) 10, 10, 20
   20	WRITE (1,920) NUMBER
920	FORMAT(' Smallest factor of ',I9,' is :')
C   Is it divisible by 2?
	FACTOR = 2
	IF (MOD(NUMBER,2)) 30, 60, 30
C   Number is odd, so try all odd divisors up to sqrt(number)
   30   MAXFAC = SQRT(FLOAT(NUMBER)) + 1
	DO 40 FACTOR = 3,MAXFAC,2
	IF (MOD(NUMBER,FACTOR)) 40, 60, 40
   40	CONTINUE
C   Number is prime
   50	WRITE (1,940)
940	FORMAT(6H Prime/)
	GOTO 10
C   Number is composite, provided "factor" is not "number"
   60   IF (FACTOR.GE.NUMBER) GOTO 50
	WRITE (1,960) FACTOR
960	FORMAT(I6/)
	GOTO 10
	END
