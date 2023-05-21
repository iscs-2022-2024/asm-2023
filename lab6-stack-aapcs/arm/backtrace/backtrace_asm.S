@ ASM
@ Author : Rayane ANNEN

@@ @brief void show_backtrace() prints the backtrace up to main()
.global show_backtrace
.equiv STACK_TOP, -1                            @ stack top
show_backtrace:
        stmfd sp!, {fp, lr}
        add fp, sp, #4

        @@@@@@@@@@@ A completer @@@@@@@@@@

        ldr r0, =backtrace_string
        bl printf

        mov     r2, fp                          @ save frame pointer

        while:
                ldr     r1, [r2]                @ read address of the frame pointer (link register)

                cmp     r1, #STACK_TOP          @ compare the linked register with the stack top
                beq     end                     @ if equal, end the loop

                stmfd   sp!, {r2}               @ save r2 in the stack
                ldr     r0, =format_string
                bl      printf                  
                ldmfd   sp!, {r2}               @ restore the value of r2
                
                ldr     r2, [r2, #-4]           @ get the previous link register
                cmp     r2, #STACK_TOP          @ compare the linked register with the stack top

                bne     while                   @ if not equal, loop
        
        end:

	@@@@@@@@@@@ ----------- @@@@@@@@@@
        sub sp, fp, #4
        ldmfd sp!, {fp, pc}

.data

backtrace_string:
        .string "\nBacktrace :\n----\n"

format_string:
        .string "Previous link register : 0x%p\n"