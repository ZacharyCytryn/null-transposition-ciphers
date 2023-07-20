.text
null_cipher_sf:
	lbu $t5 0($a0)				#Loads plaintext
	lbu $t6 0($a1)				#Loads ciphertext
	lw $t7 0($a2)				#Loads array of indices
	move $t8 $a3				#Loads number of indices
	li $t9 0					#Loads return counter (for plaintext chars not including null terminator)
	
	li $t0 0					#Loop iterator
	null_loop:
	beq $t0 $t8 null_exit		#end loop
	lw $t7 0($a2)				#Loads current index
	bnez $t7 counter_increment	#If not zero, increment counter
	counter_inc_return:
	j to_space					#Go to space loop
	return_space:
	addi $a2 $a2 4				#Increments index array
	addi $t0 $t0 1				#Increment $t0
	j null_loop
	
	counter_increment:
	addi $t7 $t7 -1				#Subtracts 1 from index (should start at 0)
	add $a1 $a1 $t7				#Adds index to ciphertext
	lbu $t3 0($a1)				#Stores unsigned byte in $t3
	sb $t3 0($a0)				#Stores letter in plaintext
	addi $a0 $a0 1				#Increments plaintext
	addi $t9 $t9 1				#Increments counter
	j counter_inc_return
	
	to_space:
	lbu $t6 0($a1)				#Loads letter from ciphertext
	li $t4 32					#Loads ASCII space in $t4
	beq $t6 $t4 is_space		#If space
	beqz $t6 is_space
	j isnt_space
		is_space:
		addi $a1 $a1 1			#Goes to letter right after space
		j return_space
		isnt_space:
		addi $a1 $a1 1			#Increment $a1
		j to_space
	
null_exit:
	li $t1 0					#Loads null terminator
	sb $t1 0($a0)				#Stores null terminator
	move $v0 $t9				#Moves counter to $a0
    jr $ra

transposition_cipher_sf:
	lbu $t5 0($a0)				#Loads plaintext
	lbu $t6 0($a1)				#Loads ciphertext
	move $t3 $a1				#Keeps original ciphertext
	move $t7 $a2				#ROWS (N)
	move $t8 $a3				#COLUMNS (M)
	mult $t7 $t8				#Multiply rows and columns
	mflo $t9					#Total number of letters (Includes '*')
	
	li $t0 0					#loop iterator
	trans_loop:
	beq $t0 $t7 trans_exit		#If iterator equals total, end loop
	lbu $t1 0($t3)				#Loads first letter of row for $t1
	j col_iterator
	return_from_col_loop:
	addi $t3 $t3 1				#Increments copy of ciphertext
	addi $t0 $t0 1				#Increments iterator
	j trans_loop
	
	col_iterator:
	move $a1 $t3				#Set $a1 to $t3
	li $t4 42					#Asterisk ASCII value
	li $t2 0					#Sets counter to 0
	col_loop:
	beq $t2 $t8 end_col_loop	#If iterator equals column number
	lbu $t1 0($a1)				#Loads letter into $t1
	beq $t1 $t4 asterisk_present#If there is an asterisk, don't store
	sb $t1 0($a0)				#Stores letter in plaintext
	addi $a0 $a0 1				#Increments plaintext
	asterisk_present:
	add $a1 $a1 $t7				#Increments ciphertext by rows
	addi $t2 $t2 1				#Increments counter
	j col_loop
	
	end_col_loop:
	j return_from_col_loop
	
	trans_exit:
	li $t1 0					#Loads null terminator
	sb $t1 0($a0)				#Stores null terminator
    jr $ra
    

decrypt_sf:
	addi $sp $sp -4				#Allocates memory
	sw $s1 0($sp)				#Saves register
	addi $sp $sp -4				#Allocates memory
	sw $s1 0($sp)				#Saves register
	addi $sp $sp -4				#Allocates memory
	sw $s2 0($sp)				#Saves register
	addi $sp $sp -4				#Allocates memory
	sw $s3 0($sp)				#Saves register
	addi $sp $sp -4				#Allocates memory
	sw $s4 0($sp)				#Saves register
	addi $sp $sp -4				#Allocates memory
	sw $s5 0($sp)				#Saves register
	addi $sp $sp -4				#Allocates memory
	sw $s6 0($sp)				#Saves register
	addi $sp $sp -4				#Allocates memory
	sw $s7 0($sp)				#Saves register
	lw $s6 32($sp)				#t4 is now number of indices
	lw $s7 36($sp)				#Loads offset
	addi $sp $sp -4				#Allocating memory
	sw $ra 0($sp)				#Storing return address
	move $t7 $a0				#Makes t7 a temp $a0
	move $s2 $a0				#Moves arg to $s2
	li $s0 0					#Loads 0 into $s0
	li $s1 0					#Loads 0 into $s1
	plain_loop:
		lbu $t8 0($t7)			#Loads letter
		beqz $t8 plain_loop_exit	#If letter == 0, exit loop
		addi $s0 $s0 1			#Increments counter
		addi $t7 $t7 1			#Increments ciphertext
		j plain_loop
	plain_loop_exit:
	li $t1 -1					#Loads -1 into $t1
	addi $s1 $s1 1				#Adds room for null terminator
	mult $s0 $t1				#Multiplies counter by -1
	mflo $s1					#-$t6
	add $sp $sp $s1				#Allocating memory for plaintext
	li $s3 0					#Loads 0 into counter
	move $t1 $a1				#Makes t1 a temp $a1
	length_loop:
		lbu $t3 0($t1)			#Loads letter
		beqz $t3 length_loop_exit	#If letter == 0, exit loop
		addi $s3 $s3 1			#Increments counter
		addi $t1 $t1 1			#Increments ciphertext
		j length_loop
	length_loop_exit:
	li $t1 -1					#Loads -1 into $t1
	addi $s3 $s3 1				#Adds room for null terminator
	mult $s3 $t1				#Multiplies $t0 by -1
	mflo $s4					#-$t0
	add $sp $sp $s4				#Allocates memory for ciphertext
	add $a0 $sp $0				#Sets arg to stack pointer address
	add $s5 $sp $0				#Sets arg to $s5
	jal transposition_cipher_sf	#Transposition function
	move $a0 $s5				#Brings arg to beginning of new plaintext
	move $a1 $a0				#Moves previous plaintext to new ciphertext
	move $a0 $s2				#Restores plaintext
	move $a3 $s6				#Loads number of indices
	move $a2 $s7				#Loads index array
	jal null_cipher_sf			#Null function
	add $sp $sp $s3				#Deallocates tranpose plaintext memory
	add $sp $sp $s0				#Deallocates memory
	lw $ra 0($sp)				#Loads original $ra
	addi $sp $sp 4				#Deallocates memory
	lw $s7 0($sp)				#Preserved register
	addi $sp $sp 4				#Deallocates memory
	lw $s6 0($sp)				#Preserved register
	addi $sp $sp 4				#Deallocates memory
	lw $s5 0($sp)				#Preserved register
	addi $sp $sp 4				#Deallocates memory
	lw $s4 0($sp)				#Preserved register
	addi $sp $sp 4				#Deallocates memory
	lw $s3 0($sp)				#Preserved register
	addi $sp $sp 4				#Deallocates memory
	lw $s2 0($sp)				#Preserved register
	addi $sp $sp 4				#Deallocates memory
	lw $s1 0($sp)				#Preserved register
	addi $sp $sp 4				#Deallocates memory
	lw $s0 0($sp)				#Preserved register
	addi $sp $sp 4				#Deallocates memory
    jr $ra
