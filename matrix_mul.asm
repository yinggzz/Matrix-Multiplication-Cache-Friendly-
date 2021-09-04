.data
TestNumber:	.word 0		# TODO: Which test to run!
				# 0 compare matrices stored in files Afname and Bfname
				# 1 test Proc using files A through D named below
				# 2 compare MADD1 and MADD2 with random matrices of size Size
				
Proc:		MADD2		# Procedure used by test 2, set to MADD1 or MADD2		
				
Size:		.word 64		# matrix size (MUST match size of matrix loaded for test 0 and 1)

Afname: 	.asciiz "A64.bin"
Bfname: 	.asciiz "B64.bin"
Cfname:		.asciiz "C64.bin"
Dfname:	 	.asciiz "D64.bin"

#################################################################
# Main function for testing assignment objectives.
# Modify this function as needed to complete your assignment.
# Note that the TA will ultimately use a different testing program.
.text
main:		la $t0 TestNumber
		lw $t0 ($t0)
		beq $t0 0 compareMatrix
		beq $t0 1 testFromFile
		beq $t0 2 compareMADD
		li $v0 10 # exit if the test number is out of range
        	syscall	

compareMatrix:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7 
		jal mallocMatrix	# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s0
		move $a1 $s1
		move $a2 $s7
		jal check 	
		
		li $v0 10      	# load exit call code 10 into $v0
        	syscall         	# call operating system to exit	

testFromFile:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix C
		move $s2 $v0		# $s2 is a pointer to matrix C
		la $a0 Cfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s2
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s3 $v0		# $s3 is a pointer to matrix D
		la $a0 Dfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s3
		jal loadMatrix		# D is the answer, i.e., D = AB+C 
	
		# TODO: add your testing code here
		move $a0, $s0	# A
		move $a1, $s1	# B
		move $a2, $s2	# C
		move $a3, $s7	# n
		
		la $ra ReturnHere
		la $t0 Proc	# function pointer
		lw $t0 ($t0)	
		jr $t0		# like a jal to MADD1 or MADD2 depending on Proc definition

ReturnHere:	move $a0 $s2	# C
		move $a1 $s3	# D
		move $a2 $s7	# n
		jal check	# check the answer

		li $v0, 10      	# load exit call code 10 into $v0
	        	syscall         	# call operating system to exit	

compareMADD:	la $s7 Size
		lw $s7 ($s7)	# n is loaded from Size
		mul $s4 $s7 $s7	# n^2
		sll $s5 $s4 2	# n^2 * 4

		move $a0 $s5
		li   $v0 9	# malloc A
		syscall	
		move $s0 $v0
		move $a0 $s5	# malloc B
		li   $v0 9
		syscall
		move $s1 $v0
		move $a0 $s5	# malloc C1
		li   $v0 9
		syscall
		move $s2 $v0
		move $a0 $s5	# malloc C2
		li   $v0 9
		syscall
		move $s3 $v0	
	
		move $a0 $s0	# A
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s1	# B
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s2	# C1
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats
		move $a0 $s3	# C2
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s2	# C1	# note that we assume C1 to contain zeros !
		move $a3 $s7	# n
		jal MADD1

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s3	# C2	# note that we assume C2 to contain zeros !
		move $a3 $s7	# n
		jal MADD2

		move $a0 $s2	# C1
		move $a1 $s3	# C2
		move $a2 $s7	# n
		jal check	# check that they match
	
		li $v0 10      	# load exit call code 10 into $v0
        	syscall         	# call operating system to exit	

##############################################################
# mallocMatrix ( int N )
# Allocates memory for an N by N matrix of floats
# The pointer to the memory is returned in $v0
mallocMatrix: 	mul  $a0, $a0, $a0	# Let $s5 be n squared
		sll  $a0, $a0, 2		# Let $s4 be 4 n^2 bytes
		li   $v0, 9		
		syscall			# malloc A
		jr $ra
	
###############################################################
# loadMatrix( char* filename, int width, int height, float* buffer )
.data
errorMessage: .asciiz "FILE NOT FOUND" 
.text
loadMatrix:	mul $t0 $a1 $a2 	# words to read (width x height) in a2
		sll $t0 $t0  2	  	# multiply by 4 to get bytes to read
		li $a1  0     		# flags (0: read, 1: write)
		li $a2  0     		# mode (unused)
		li $v0  13    		# open file, $a0 is null-terminated string of file name
		syscall
		slti $t1 $v0 0
		beq $t1 $0 fileFound
		la $a0 errorMessage
		li $v0 4
		syscall		  	# print error message
		li $v0 10         	# and then exit
		syscall		
fileFound:	move $a0 $v0     	# file descriptor (negative if error) as argument for read
  		move $a1 $a3     	# address of buffer in which to write
		move $a2 $t0	  	# number of bytes to read
		li  $v0 14       	# system call for read from file
		syscall           	# read from file
		# $v0 contains number of characters read (0 if end-of-file, negative if error).
                	# We'll assume that we do not need to be checking for errors!
		# Note, the bitmap display doesn't update properly on load, 
		# so let's go touch each memory address to refresh it!
		move $t0 $a3	# start address
		add $t1 $a3 $a2  	# end address
loadloop:	lw $t2 ($t0)
		sw $t2 ($t0)
		addi $t0 $t0 4
		bne $t0 $t1 loadloop		
		li $v0 16	# close file ($a0 should still be the file descriptor)
		syscall
		jr $ra	

##########################################################
# Fills the matrix $a0, which has $a1 entries, with random numbers
fillRandom:	li $v0 43	#random float syscall - into f0
		syscall		# random float, and assume $a0 unmodified!!
		swc1 $f0 0($a0)   #random float into a0
		addi $a0 $a0 4
		addi $a1 $a1 -1  #decrement a1
		bne  $a1 $zero fillRandom  #loop fillRandom
		jr $ra

##########################################################
# Fills the matrix $a0 , which has $a1 entries, with zero
fillZero:	sw $zero 0($a0)	# $zero is zero single precision float
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillZero
		jr $ra
		

######################################################
# TODO: void subtract( float* a0, float* a1, float* a2, int a3 )  a2 C  = a0 A  - a1 B #stored in another register, when done
subtract: 	
		#A = a0, B = a1, for each entry a3 = a0-a1
		addi $sp, $sp, -20
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $a1, 8($sp)
		sw $a3, 12($sp)
		sw $a2, 16($sp)
		# do not add a0 a1, use t register to get byte, for 1 - n^2 entries
		mul $a3, $a3, $a3  	#now a3 = n^2
		li $s0, 0 #counter
		move $s1, $a0
	
subtractInst:	
		l.s $f4, 0($s1)		# f4 - current entry in A
		l.s $f6, 0($a1) 	# f6 - current entry in B
		sub.s $f8, $f4, $f6     # f8 - entry in C = A-B
		swc1 $f8, ($a2)	
		
		addi $s0, $s0, 1
		beq $s0 $a3 subtractExit	#if s0=a3, exit subtract
		addi $s1, $s1, 4
		addi $a1, $a1, 4
		addi $a2, $a2, 4  
		j subtractInst 

subtractExit:
		#sub $a3, $zero, $a3
		#add $a2, $a2, $a3
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $a1, 8($sp)
		lw $a3, 12($sp)
		lw $a2, 16($sp)
		addi $sp, $sp, 20
		jr $ra

#######################################################
# TODO: float frobeneousNorm( float* A - a0, int N - a1 )
frobeneousNorm: 	

		addi $sp, $sp, -16
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $a0, 8($sp)
		sw $a1, 12($sp)
		
		li $s0 0 #counter
		mul $a1, $a1, $a1  	#now a1 = n^2
		mtc1 $zero, $f0 #set f0 as 0
		
		# sum of squares of all entries in A - store in s0
sumSquare: 	

		lwc1  $f4 ($a0)	 # current entry in f4
		mul.s $f4 $f4 $f4	#square of entry in f4
		add.s $f0 $f0 $f4
		
		addi $s0, $s0, 1 	 #increase counter
		beq $s0 $a1 frobExit	#if s0=n^2, exit frobeneousNorm
		addi $a0, $a0, 4 
		j sumSquare
		
			
frobExit: 	
		sqrt.s $f0, $f0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $a0, 8($sp)
		lw $a1, 12($sp)
		addi $sp, $sp, 16
		jr $ra

#################################################
# TODO: void check ( float* A -a0, float* B - a1, int N - a2 )
# Print the forbeneous norm of the difference of C and D
check: 		
		#calls subtract A, B, A, n
		# a0->a2, a2->a3
		addi $sp, $sp, -4
		sw $ra 0($sp)
		
		move $s0, $a2 	#s0 = n
		move $a2, $a0 #second argument = A
		move $a3, $s0 #a3 = n
		jal subtract #now a2 has the new matrix
		
		move $a0, $a2
		move $a1, $a3
		jal frobeneousNorm #reuslt in f0
		
		#print resulting single precision
		mov.s $f12, $f0 #have f12 store f0
		li $v0, 2
		syscall
		
		lw $ra 0($sp)
		addi $sp, $sp, 4
		jr $ra

##############################################################
# TODO: void MADD1( float*A - a0, float* B - a1, float* C - a2, N -a3 )
MADD1: 		# to multiply two matrices and add to C -> C
		addi $sp, $sp, -32
		sw $s0, 0($sp) #i
		sw $s1, 4($sp) #j
		sw $s2, 8($sp) #k
		sw $a0, 12($sp)
		sw $a1, 16($sp)
		sw $a3, 20($sp) #n
		sw $ra, 24($sp)
		sw $a2, 28($sp)

	#initialize i for the first for loop:  for ( i = 0; i < n; i ++)
		li $s0, 0
	
Loop1: 		
		beq $s0, $a3, Loop1Exit  #if i = n, exit
		li $s1, 0 		 #initialize j = 0 
		jal Loop2 		#goes into second loop
		addi $s0, $s0, 1 	# i++
		j Loop1
		
		

Loop2: 		addi $sp, $sp, -4
		sw $ra, ($sp)
		#for (j=0; j<n; j++)

Loop2Inst:	beq $s1, $a3, Loop2Exit  #if j = n, exit
		li $s2, 0 		 #initialize k = 0 
		jal Loop3 		#goes into third loop
		addi $s1, $s1, 1 	# j++
		j Loop2Inst
		
Loop2Exit: 
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra


Loop3: 	
		#for (k=0; k<n; k++)
		# s0 - i  s1 - j  s2 - k 
		beq $s2, $a3, Loop3Exit  #if k = n, exit
		
		# c[ij] += a[ik] * b [kj]
		mul $t0, $a3, $s0 #t0 = i*a3
		add $t0, $t0, $s1 #t0 = i*a3 +j
		mul $t1, $t0, 4 	#t1 has i*a3 +j * 4 - index to access C
		add $a2, $a2, $t1
		lwc1 $f4, ($a2)	#f4 has current C[i*a3 +j]
		# get -$t1
		sub $t0, $zero, $t1 	#t0 has -t1
		add $a2, $a2, $t0 	#store back
		
		mul $t0, $a3, $s0	##t0 = i*a3
		add $t0, $t0, $s2 	#t0 = i*a3 +k
		mul $t0, $t0, 4 	#t0 has i*a3 + k * 4 - index to access A
		add $a0, $a0, $t0
		lwc1 $f6, ($a0)		#f6 has A[i*a3 + k]
		sub $t0, $zero, $t0
		add $a0, $a0, $t0
		
		mul $t0, $a3, $s2	#t0 = k*a3 
		add $t0, $t0, $s1 	#t0 = k*a3 + j
		mul $t0, $t0, 4 	#t0 has k*a3 + j * 4 - index to access B
		add $a1, $a1, $t0
		lwc1 $f8, ($a1)		#f8 has B[k*a3 + j]
		sub $t0, $zero, $t0
		add $a1, $a1, $t0
		
		mul.s $f10, $f6, $f8 	 # f10 = a[i*a3 + k] * b [k*a3 + j]
		add.s $f10, $f4, $f10 	# f10 = c[i*a3 +j] + a[i*a3 + k] * b [k*a3 + j]
		
		#store f10 in C[t1]
		add $a2, $a2, $t1
		swc1 $f10, ($a2)
		sub $t1, $zero, $t1
		add $a2, $a2, $t1			
		
		addi $s2, $s2, 1 	# k++
		j Loop3
		
Loop3Exit: 
		jr $ra	#goes back to Loop2	

Loop1Exit:
		lw $s0, 0($sp) #i
		lw $s1, 4($sp) #j
		lw $s2, 8($sp) #k
		lw $a0, 12($sp)
		lw $a1, 16($sp)
		lw $a3, 20($sp) #n
		lw $ra, 24($sp)
		lw $a2, 28($sp)
		addi $sp, $sp, 32
		jr $ra


#########################################################
# TODO: void MADD2( float*A - a0, float* B - a1, float* C - a2, N - a3 )
MADD2: 		

		addi $sp, $sp, -52
		sw $s0, 0($sp) # jj - loop 1
		sw $s1, 4($sp) # kk - loop2
		sw $s2, 8($sp) # i - loop3
		sw $s3, 12($sp) # j - loop 4
		sw $s4, 16($sp) # k - loop5
		sw $s5, 20($sp) # min (jj + 4, n)
		sw $s6, 24($sp) # min (kk + 4, n)
		sw $a0, 28($sp) 
		sw $a1, 32($sp)
		sw $a3, 36($sp) #n
		sw $ra, 40($sp)
		sw $a2, 44($sp)
		sw $s7, 48($sp)
		
		li $s0, 0 #initialize jj



MLoop1: 		#for (jj = 0; jj<n; jj+= 4)
		# if s0>=a3, go to MLoop1Exit
		slt $t0, $s0, $a3,
		beq $t0, $zero, MLoop1Exit  #if jj = n, exit
		li $s1, 0 		 #initialize kk = 0 
		
		# compute min (jj + 4, n) in s5
		addi $t0, $s0, 4 #t0 = jj+4
		
		#store min of t0 and a3 in s5
		slt $t1, $t0, $a3 #if t0<a3 go to storeT0
		bne $t1, $zero, MstoreT0Loop1
		
		#else if a3<=t0, store a3 in s5
		move $s5, $a3
		
		jal MLoop2 		#goes into second loop
		addi $s0, $s0, 4 	# jj+=besize
		j MLoop1	
		
MstoreT0Loop1:       #stores t0 in s5
		move $s5, $t0	
		jal MLoop2 		#goes into second loop
		addi $s0, $s0, 4 	# jj+=besize
		j MLoop1	
		
		
MLoop2: 	# for (kk=0; kk<n; kk+=bsize)
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
MLoop2Inst:	slt $t0, $s1, $a3,
		beq $t0, $zero, MLoop2Exit  #if kk >= n, exit
		li $s2, 0 		 #initialize i = 0 
		
		# compute min (kk + 4, n) in s6
		addi $t0, $s1, 4 #t0 = kk+4
		
		#store min of t0 and a3 in s6
		slt $t1, $t0, $a3 #if t0<a3 go to storeT0
		bne $t1, $zero, MstoreT0
		
		#else if a3<=t0, store a3 in s6
		move $s6, $a3
		jal MLoop3 		#goes into third loop
		addi $s1, $s1, 4	# kk+=besize
		j MLoop2Inst
		
MstoreT0:       #stores t0 in s6
		move $s6, $t0
		
		jal MLoop3 		#goes into third loop
		addi $s1, $s1, 4	# kk+=besize
		j MLoop2Inst
		
MLoop3: 		# for (i = 0l i<n; i++) 
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
MLoop3Inst:	beq $s2, $a3, MLoop3Exit  #if i = n, exit
		move $s3, $s0 	 #initialize j = jj
		jal MLoop4 		#goes into fourth loop
		addi $s2, $s2, 1	# i++
		j MLoop3Inst
		
		
MLoop4: 		# for (j = jj, j< min(jj + b4, n); j++
		addi $sp, $sp, -4
		sw $ra, ($sp)
		
MLoop4Inst:	beq $s3, $s5, MLoop4Exit  #if j = min (jj + bsize,n), exit
		move $s4, $s1	 #initialize k = kk
		# sum (f20)= 0.0
		mtc1 $zero, $f20
		
		jal MLoop5 		#goes into fifth loop
		
		#c[i*n + j] + = sum (f20)
		mul $t0, $s2, $a3
		add $t0, $t0, $s3  #store (i*n + j)*4 in $t0
		mul $t0, $t0, 4 	#store (i*n + j)*4 in $t0
		
		# get c[i*n + j] in f4
		add $a2, $a2, $t0
		l.s $f4, ($a2) #load into f4
		
		add.s $f4, $f4, $f20 #f4 = sum+c[i*n + j]
		s.s $f4, ($a2) #store f4 back to C
		
		sub $t0, $zero, $t0 # -t0
		add $a2, $a2, $t0 #store back 
		
		addi $s3, $s3, 1	# j++
		j MLoop4Inst
		
MLoop5: 		# for (k = kk; k< min (kk + bsize, n); k++) k=s4

		slt $t6, $s4, $s6
		beq $t6, $zero, MLoop5Exit  #if k >= min (kk + bsize,n), exit
		
		###### sum (f20) += a[i*n + k] * b[k*n + j] #########
		# get A[i*n + k] in f4
		mul $t0, $s2, $a3 #t0 = i*n
		add $t0, $t0, $s4 # t0 = i*n + k
		mul $t0, $t0, 4 # t0 = (i*n + k)*4
		add $a0, $a0, $t0
		l.s $f4 ($a0) #load A[i*n + k] in f4
		sub $t0, $zero, $t0
		add $a0, $a0, $t0
		
		# get B[k*n + j] in f6
		mul $t0, $s4, $a3 #t0 = k*n
		add $t0, $t0, $s3 # t0 = k*n + j
		mul $t0, $t0, 4 # t0 = (k*n + j)*4
		add $a1, $a1, $t0
		l.s $f6 ($a1) #load B[k*n + j] in f6
		sub $t0, $zero, $t0
		add $a1, $a1, $t0
		
		mul.s $f4, $f4, $f6  # f4 = = A[i*n + k] * B[k*n + j]
		add.s $f20, $f20, $f4   #(f20) += a[i*n + k] * b[k*n + j]
		
		addi $s4, $s4, 1	# k++
		j MLoop5
		
MLoop5Exit: 
		jr $ra
		
MLoop4Exit: 
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
		
MLoop3Exit: 
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
		
		
MLoop2Exit: 
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra

MLoop1Exit:
		
		lw $s0, 0($sp) # jj - loop 1
		lw $s1, 4($sp) # kk - loop2
		lw $s2, 8($sp) # i - loop3
		lw $s3, 12($sp) # j - loop 4
		lw $s4, 16($sp) # k - loop5
		lw $s5, 20($sp) # min (jj + 4, n)
		lw $s6, 24($sp) # min (kk + 4, n)
		lw $a0, 28($sp) 
		lw $a1, 32($sp)
		lw $a3, 36($sp) #n
		lw $ra, 40($sp)
		lw $a2, 44($sp)
		lw $s7, 48($sp)
		addi $sp, $sp, 52
		jr $ra

