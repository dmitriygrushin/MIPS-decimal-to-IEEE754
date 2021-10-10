#Dmitriy, Grushin		 :)
.data
enterInt:			.asciiz 	"\n\nEnter Signed Integer Part.\n"
enterBiFrac:		.asciiz 	"Enter Fraction as Binary String.\n"
displayBits:		.asciiz 	"\nAll Bits of the Floating Point Number are: \n"
displayFloat:		.asciiz 	"\nThe Floating Point Number is: \n"
signBit:			.asciiz 	"\nSign Bit: "
expInDec:			.asciiz 	"\nExponent In Decimal: "
dash:				.asciiz 	" "
binaryFraction:		.space 		20
myArray:			.space 		4
.text

main:
	li 		$v0, 4					# Print: " Enter Int "
	la 		$a0, enterInt
	syscall
	
  	li 		$v0, 6					# GET: Int: Stored in: [ $f0 ] ( Will be turned into floating point automatically with #6 instruction ) 
	syscall

	swc1 	$f0, myArray($s4)		# store from $f0 into myArray: $s4[0]
	lw 		$s5, myArray($s4)		# load from myArray $s4[0] to $s5
	cvt.w.s	$f5, $f0				# Convert to a word from float
	mfc1	$s6, $f5				# move from Coproc 1 $f5 to $s6	
	bgtz 	$s6, prepExpPos			# if $s5 > 0: goto prepExpPos
	bltz 	$s6, prepExpNeg			# if $s5 < 0: goto prepExpNeg
comeBack2:							# After preping the EXP
	bgtz 	$s5, prepZero			# if $v0 > 0: goto prepZero
	bltz 	$s5, prepOne			# if $v0 < 0: goto prepOne
comeBack:							# After Preping the Sign Bit
	mov.s 	$f20, $f0    			# $f0 --> $f20

	li 		$t1, 0					# What breaks will be compared to
	mtc1 	$t1, $f8				# $t1 --> $f8 ( Coproc1 )
	c.eq.s 	$f8, $f20				# if: $f8 == $f20 Coproc1 true

	bc1t 	Exit					# Exit if floating point is 0	
Next1:
	li 		$v0, 4					# Print: " Enter Bi Franction "
	la 		$a0, enterBiFrac
	syscall
	    	    									
	la 		$a0, binaryFraction		# Reserve Space for binary fraction
    li 		$a1, 20					# .space 20
    li 		$v0, 8					# Read String: Because binary decimal is taken as a string
    syscall
	j printExponent					# Prints Exponent Value
returnBack2:   						# return after printing EXP
    beqz 	$s3, printZero			# Prints Sign Bit 0
    bgt 	$s3, $zero, printOne	# Prints Sign Bit: 1
returnBack:
#----------------------------Convert Binary String to Deciaml Float---------------------------------------------#    
    la 		$t2, binaryFraction		# $t2: Store Binary Fraction
	addi 	$t2, $t2, 1				# $t2++ for the next extry of binary
     	
	li 		$t1, 0					# What breaks will be compared to
	li		$t6, 1					# What breaks will be compared to
	mtc1	$t6, $f8				# $t6 --> $f8 ( Coproc 1 )
     	
	li 		$t3, 2
	mtc1 	$t1, $f4				# $t1 --> $f4 ( Coproc 1 ) 
     	
Loop:
	lb 		$a1, ($t2)				# load bite: $t2 --> $a1
	beq 	$a1, 10, OutLoop		# if $a1 = 10: goto Outloop
	sub 	$s2, $a1, 48			# $s2 = $a1 - [ 48 ]
     	
	mul 	$t6, $t6, $t3			# $t6 = $t6 * $t3
     		
	mtc1 	$s2, $f6				# $s2 --> $f6 ( Coproc 1 )
	mtc1 	$t6, $f7				# $t6 --> $f7 ( Coproc 1 )

	div.s 	$f10, $f6, $f7			# $f10 = $f6 / $f7 
	add.s 	$f4, $f4, $f10			# $f4 = $f4 + $f10	
	addi 	$t2, $t2, 1				# $t2++
	b Loop
	
OutLoop:
    li 		$t1, 0					# What breaks will be compared to
    mtc1 	$t1, $f3				# $t1 --> $f3 ( Coproc 1 )
     	
    c.lt.s 	$f3, $f20				# if: $f3 < $f20 Coproc1 0: true
    bc1t 	Next2					# if floating above true: goto Next2
    	
    li 		$t6, 1					# What breaks will be compared to
    mtc1 	$t6, $f8				# $t6 --> $f8 ( Coproc 1 )
     	
	sub.s 	$f4, $f8, $f4			# $f8 - $f4 Store in $f4  
	   
Next2:
	add.s 	$f12, $f4, $f20			# $f12 = $f4 + $f20	
     									
    li 		$v0, 4					# Print Price in Float
    la 		$a0, displayBits
    syscall
    	
    mfc1 	$t1, $f12				
#------------------------------WHERE THE BITS ARE PRINTED----------------------------------------------------------------#     	
    li 		$t2, 0					# dash counter 
	li 		$s2, 4					# After every 4th count there will be a dash
	li 		$s1, 32        		 	# loop counter 32bit  
	
loop1:
    rol 	$t1, $t1, 1    			# Rotate Left So that last bit becomes 1st to read it with out destroying it.
    and 	$t0, $t1, 1    			# Mask the last bit with AND
    add 	$t0, $t0, 48   			# Will print 0 || 1 depending on the AND operation [ 48 ] = 0 asciiz
    beq 	$t2, $s2, makeDash		# Break if: 4 bits were printed then make dash
    
return:
	jal outputBi
    addi 	$t2, $t2, 1				# dashCount++
    subi 	$s1, $s1, 1				# loop--
    bne 	$s1, $zero, loop1  		# if zero then get out of loop
	j Next3 
	   	     	
Next3:
    li 		$v0, 4					# Print: " The floting point number is: "
    la 		$a0, displayFloat
    syscall
    	
	li 		$v0, 2					# Print: Float
    syscall 
	j main
Exit:			
	li 		$v0, 10					# END
	syscall
#-----------------------FUNCTIONS/BREAKS/ETC------------------------------------------#
makeDash:
	li 		$v0, 4 					# Make A Dash " " 
	la 		$a0, dash
	syscall
	subi 	$t2, $t2, 4				# $t2 - 4 to reset counter to 0. To start counting from 0 --> 4
	j return

outputBi:
	move 	$a0, $t0				# Print the Binary 
	li 		$v0, 11
    syscall
    jr 		$ra
#---------------------------Sign Bit---------------------------------------------------#    
prepOne:
li 			$s3, 1					# Will be printed as sign
j 			comeBack				# Jump to: comeBack

printOne:
li 			$v0, 4					# Print: Sign Bit:
la 			$a0, signBit
syscall

li 			$v0, 1					# Print: SignBit #
move 		$a0, $s3
syscall

j 			returnBack				# Jump to: returnBack
#----------------------#
prepZero:
li 			$s3, 0					# Will be printed as sign
j 			comeBack				# Jump to: comeBack

printZero:
li 			$v0, 4					# Print: Sign Bit:			
la 			$a0, signBit
syscall

li 			$v0, 1					# Print: SignBit #
move 		$a0, $s3
syscall

j returnBack						# Jump to: returnBack
#------------------------------------------------------------#
prepExpPos:
srl $s7, $s6, 4						# SRL gives me the Exponent
j comeBack2

prepExpNeg:
not $s7, $s6						# If the Int is ( - ) it's turned into ( + ) to make it easier to SRL
srl $s7, $s7, 4
j comeBack2

printExponent:
li $v0, 4							# Print " Exponent In Decimal: "		
la $a0, expInDec
syscall
add $s7, $s7, 127
li $v0, 1							# Prints the Exponent in decimal
move $a0, $s7
syscall

j returnBack2							

