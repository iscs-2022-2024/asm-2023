@ ASM
@ Author : Rayane ANNEN

@ absdiff(X, Y, R) -> R = |X-Y|
.macro absdiff R, X, Y
        sub     \R, \X, \Y               @ R = X - Y
        cmp     \R, #0                   @ compare R with 0
        rsblt   \R, \R, #0               @ compute R = 0 - R if R < 0 (take the absolute value)
.endm

@ unpack(S1) -> R1 = S1_X, R2 = S1_Y
.macro unpack S1, R1, R2
        movw \R1, #0xFFFF               @ place 0xFFFF in the lower bits of R2
        and \R2, \R1, \S1               @ compute R1 & S1 to clear the upper half and place the result in R2 [R2 = Y]

        mov \R1, #0                     @ reset R1
        mov \R1, \S1, lsr #16           @ R1 = S1 >> 16 [R1 = X]
.endm

@@ @brief uint32_t manhattan_distance_asm(const uint32_t a, const uint32_t b)
@@ Computes the Manhattan distance between a and b
@@ @param a (r0)
@@ @param b (r1)
@@ @return distance in r0
.global manhattan_distance_asm
manhattan_distance_asm:
	mov   r12, sp
        stmfd sp!, {r4-r12, lr}

        @@@@@@@@@@@ A completer @@@@@@@@@@

        unpack  r0, r2, r3              @ r2 = X_A, r3 = Y_A
        unpack  r1, r4, r5              @ r4 = X_B, r5 = Y_B

        absdiff r2, r2, r4              @ r2 = |X_A - X_B|
        absdiff r3, r3, r5              @ r3 = |Y_A - Y_B|
        
        mov     r0, #0
        add     r0, r2, r3             @ r0 = |X_A - X_B| + |Y_A - Y_B|

	@@@@@@@@@@@ ----------- @@@@@@@@@@

        ldmfd sp!, {r4-r12, lr}
        mov   sp, r12
        mov   pc, lr

@@ @brief uint32_t ssd_semi_distance_asm(const uint32_t a, const uint32_t b)
@@ Computes the Sum of Squared Differences semi distance between a and b
@@ @param a (r0)
@@ @param b (r1)
@@ @return distance in r0
.global ssd_semi_distance_asm
ssd_semi_distance_asm:
	mov   r12, sp
        stmfd sp!, {r4-r12, lr}

        @@@@@@@@@@@ A completer @@@@@@@@@@

        unpack  r0, r2, r3              @ r2 = X_A, r3 = Y_A
        unpack  r1, r4, r5              @ r4 = X_B, r5 = Y_B
        absdiff r2, r2, r4              @ r2 = |X_A - X_B|
        absdiff r3, r3, r5              @ r3 = |Y_A - Y_B|
        mul     r2, r2, r2              @ r2 = |X_A - X_B|^2
        mul     r3, r3, r3              @ r3 = |Y_A - Y_B|^2
        add     r0, r2, r3              @ r0 = |X_A - X_B|^2 + |Y_A - Y_B|^2

	@@@@@@@@@@@ ----------- @@@@@@@@@@

        ldmfd sp!, {r4-r12, lr}
        mov   sp, r12
        mov   pc, lr

