@     ___   _____ __  ______   ____ ___  ___ 
@    /   | / ___//  |/  /__ \ / __ \__ \|__ \
@   / /| | \__ \/ /|_/ /__/ // / / /_/ /__/ /
@  / ___ |___/ / /  / // __// /_/ / __// __/ 
@ /_/  |_/____/_/  /_//____/\____/____/____/ 
@
@ Author : Rayane ANNEN

@@ @brief uint32_t sum_asm(uint32_t n, ...)
@@ Computes the sum of ... (uint32_t), 0 if empty
@@ @param n (r0) the number of elements in ...
@@ @param ... variable number of uint32_t elements
@@ @return sum of ... or 0 if empty
.global sum_asm
sum_asm:
        @@@@@@@@@@@ A completer @@@@@@@@@@
        @ L'espace vide vous donne une idée de la taille de la solution
        @ prologue
        stmfd   sp!, {r1-r3}            @ push arguments on stack
        stmfd   sp!, {fp, lr}           
        add     fp, sp, #4              

        add     sp, sp, #8              @ jump to arguments
        eor     r1, r1, r1
        eor     r2, r2, r2
        
        while:
        cmp     r0, #0                  @ check if counter == 0
        beq     end                     @ loop if counter == 0
        ldmfd   sp!, {r2}               @ pop next argument
        add     r1, r1, r2              @ add to the sum
        sub     r0, r0, #1              @ decrement counter
        b       while                   @ loop
        
        end:
        mov     r0, r1                  @ return sum
        
        @ epilogue
        sub     sp, fp, #4              
        ldmfd   sp!, {fp, pc}           
        @@@@@@@@@@@ ----------- @@@@@@@@@@
