# Author : Rayane Annen

.global asm_config_register

# int asm_config_register(int gpio_reg)
# input gpio_reg in eax
# output in eax
asm_config_register:
        pushl %ebp                # Save old stack frame
        movl  %esp, %ebp          # Set new stack base
        movl  8(%ebp), %eax       # copy the argument in eax
        pushl %ebx

        ########## A completer ##########

        # gpio_reg &= ~(unsigned int)0x1;
        xor %ecx, %ecx
        mov $0x1, %ecx          
        not %ecx                       
        and %ecx, %eax 

        # gpio_reg |= 0xF << 4;
        xor %ecx, %ecx
        mov $0xF, %ecx
        shl $4, %ecx
        or %ecx, %eax

        # gpio_reg &= ~UPPER_BYTE_MASK;
        xor %ecx, %ecx
        mov $0xFF000000, %ecx
        not %ecx
        and %ecx, %eax

        # gpio_reg |= (0x66 << 3*8);
        xor %ecx, %ecx
        mov $0x66, %ecx 
        shl $24, %ecx
        or %ecx, %eax

        # gpio_reg /= 8;
        shr $3, %eax

        # gpio_reg = (gpio_reg | 0xA5) & (0xFFEEDD << 3);
        xor %ecx, %ecx 
        xor %edx, %edx 
        mov %eax, %edx
        or $0xa5, %edx
        mov $0xFFEEDD, %ecx
        shl $3, %ecx
        and %ecx, %edx
        mov %edx, %eax

exit:
        popl  %ebx
        leave                     # Restore stack frame
        ret                       # Return to caller
