# Author : 

.global parity_word
.global check_parity

# int parity_word(int value)
# input value in eax
# output in eax
parity_word:
        pushl %ebp                      # Save old stack frame
        movl  %esp, %ebp                # Set new stack base
        movl 8(%ebp), %eax              # copy the argument in eax
        pushl %ebx

        ########## A completer ##########
        mov %eax, %ebx
        shr $16, %ebx   # ebx >> 16 bh = b2, bl = b1

        xor %bh, %bl    # bl = b2 xor b1
        xor %ah, %bl    # bl = bl xor b0
        mov %bl, %al    # store in al


        popl %ebx
        leave                           # Restore stack frame
        ret                             # Return to caller

# int check_word(int value)
# input value in eax
# output in eax
check_parity:
        pushl %ebp                      # Save old stack frame
        movl  %esp, %ebp                # Set new stack base
        movl 8(%ebp), %eax              # copy the argument in eax
        pushl %ebx

        ########## A completer ##########

        mov %eax, %ebx
        shr $16, %ebx

        xor %bh, %bl            # b2 xor b1
        xor %ah, %bl            # (b2 xor b1) xor b0
        xor %bl, %al            # return 0 if there is no error anything else otherwise
        movzbl %al, %eax        # store result to entire register

        popl %ebx
        leave                           # Restore stack frame
        ret                             # Return to caller
