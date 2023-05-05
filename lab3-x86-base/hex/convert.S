# Author : ANNEN Rayane

.global char_to_hex

.equiv ascii_a, 0x41
.equiv ascii_0, 0x30
.equiv shift, 0x0A

char_to_hex:
	pushl %ebp                # Save old stack frame
	movl  %esp, %ebp          # Set new stack base
	movl  8(%ebp), %eax       # copy the argument in eax
	pushl %ebx

	########## A completer ##########
	xorw %bx, %bx

	movb %al, %bl			# Nibble low
	movb %al, %bh			# Nibble high

	andb $0x0F, %bl			# Clear nibble high
	shrb $4, %bh 			# Clear nibble low


	cmp $shift, %bl			
	jl .convert_to_number_low
.convert_to_letter_low:
	add $ascii_a - shift, %bl
	jmp .continue_high
	
.convert_to_number_low:
	add $ascii_0, %bl
	jmp .continue_high

.continue_high:
	cmp $shift, %bh
	jl .convert_to_number_high
.convert_to_letter_high:
	add $ascii_a - shift, %bh
	jmp .store_to_register
.convert_to_number_high:
	add $ascii_0, %bh
	jmp .store_to_register

.store_to_register:
	xor %eax, %eax

	orb $'0', %ah
	orb $'x', %al
	shl $16, %eax
	orb %bh, %ah
	orb %bl, %al

out:
    popl %ebx
    leave                     # Restore stack frame
    ret                       # Return to caller

