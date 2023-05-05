@ ASM
@ Author : Rayane Annen

@@ @brief uint32_t discrete_distance_asm(const uint32_t a, const uint32_t b)
@@ Computes the discrete distance between a and b
@@ @param a (r0)
@@ @param b (r1)
@@ @return distance in r0
.global discrete_distance_asm
discrete_distance_asm:
	mov   r12, sp
        stmfd sp!, {r4-r12, lr}

        @@@@@@@@@@@ A completer @@@@@@@@@@

        @
        @ d = 0 if a == b, 1 otherwise
        @

        cmp     r0,     r1              @ compare r0 and r1
        moveq   r0,     #0              @ return 0 if a == b
        movne   r0,     #1              @ return 1 otherwise

	@@@@@@@@@@@ ----------- @@@@@@@@@@

        ldmfd sp!, {r4-r12, lr}
        mov   sp, r12
        mov   pc, lr

@@ @brief uint32_t hamming_distance_asm(const uint32_t a, const uint32_t b)
@@ Computes the Hamming distance between a and b
@@ @param a (r0)
@@ @param b (r1)
@@ @return distance in r0
.global hamming_distance_asm
hamming_distance_asm:
	mov   r12, sp
        stmfd sp!, {r4-r12, lr}

        @@@@@@@@@@@ A completer @@@@@@@@@@

        mov     r4, #0                  @ r4 = 0
        mov     r2, r0, lsr #16         @ r2 = r0 >> 16 [x_a]
        mov     r3, r1, lsr #16         @ r3 = r1 >> 16 [x_b]

        cmp     r3, r2                  @ compare r3 [x_b] and r2 [x_a]
        addne   r4, r4, #1              @ increment r4 if x_a and x_b are not equal

        mov     r2, r0, lsl #16         @ r2 = r0 << 16 [y_a]
        mov     r3, r1, lsl #16         @ r3 = r1 << 16 [y_b]

        cmp     r3, r2                  @ compare r3 [y_b] and r2 [y_b]
        addne   r4, r4, #1              @ increment r4 if y_a and y_b are not equal

        mov     r0, r4                  @ return distance in r0

	@@@@@@@@@@@ ----------- @@@@@@@@@@

        ldmfd sp!, {r4-r12, lr}
        mov   sp, r12
        mov   pc, lr

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

        @
        @ d = |x_a - x_b| + |y_a - y_b|
        @

        mov     r4, #0                  @ r4 = 0, will be used to store the result of the operations
        movw    r5, #0xFFFF             @ r5 = 0xFFFF, will be used to clear the upper half of the registers

        mov     r2, r0, lsr #16         @ r2 = r0 >> 16 [x_a]
        mov     r3, r1, lsr #16         @ r3 = r1 >> 16 [x_b]

        sub     r2, r2, r3              @ r2 = r2 - r3 (x_a - x_b)
        cmp     r2, #0                  @ compare r2 with 0
        rsblt   r2, r2, #0              @ compute 0 - r2 if r2 < 0 (take the absolute value)

        mov     r4, r2                  @ store the result in r4

        mov     r2, r0                  @ r2 = r0
        and     r2, r2, r5              @ clear the upper half of r2
        mov     r3, r1                  @ r3 = r1
        and     r3, r3, r5              @ clear the upper half of r3

        sub     r2, r2, r3              @ r2 = r2 - r3 (y_a - y_b)
        cmp     r2, #0                  @ compare r2 with 0
        rsblt   r2, r2, #0              @ take the absolute value

        add     r0, r2, r4              @ r0 = r2 (|y_a - y_b|) + r4 (|x_a - x_b|)

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

        @
        @ d = (x_a - x_b)^2 + (y_a - y_b)^2
        @

        mov     r4, #0                  @ r4 = 0, will be used to store the result of the operations
        movw    r5, #0xFFFF             @ r5 = 0xFFFF, will be used to clear the upper half of the registers

        mov     r2, r0, lsr #16         @ r2 = r0 >> 16 [x_a]
        mov     r3, r1, lsr #16         @ r3 = r1 >> 16 [x_b]

        sub     r2, r2, r3              @ r2 = r2 - r3 (x_a - x_b)
        mul     r2, r2, r2              @ r2 = r2 * r2

        mov     r4, r2                  @ store the result in r4

        mov     r2, r0                  @ r2 = r0
        and     r2, r2, r5              @ clear the upper half of r2
        mov     r3, r1                  @ r3 = r1
        and     r3, r3, r5              @ clear the upper half of r3

        sub     r2, r2, r3              @ r2 = r2 - r3 (y_a - y_b)
        mul     r2, r2, r2              @ r2 = r2 * r2

        add     r0, r2, r4              @ r0 = r2 (y_a - y_b)^2 + r4 (x_a - x_b)^2

	@@@@@@@@@@@ ----------- @@@@@@@@@@

        ldmfd sp!, {r4-r12, lr}
        mov   sp, r12
        mov   pc, lr




@@ @brief uint32_t get_directions_asm(const char* map, const uint32_t position)
@@ Returns possible directions given a position on a map
@@ @param pointer on map (r0)
@@ @param position (r1)
@@ @return possible directions
.equiv MAP_SIZE_X, 8
.equiv MAP_SIZE_Y, 10
.equiv WALL_ASCII, 0x57                 @ ASCII: 'W'
.equiv WEST_MASK,  0b0001
.equiv EAST_MASK,  0b0010
.equiv SOUTH_MASK, 0b0100
.equiv NORTH_MASK, 0b1000
.global get_directions_asm
get_directions_asm:
	mov   r12, sp
        stmfd sp!, {r4-r12, lr}

        @@@@@@@@@@@ A completer @@@@@@@@@@

        mov     r4, #0xF                @ will be used to hold the result
        mov     r6, #MAP_SIZE_Y         @ will be used to compute and hold the index of the current position on the map
        
        movw    r5, #0xFFFF             @ r5 = 0xFFFF, will be used to clear the upper half of the registers
        mov     r2, r1, lsr #16         @ r2 = r1 >> 16 [x]
        mov     r3, r1                  @ r3 = r1
        and     r3, r3, r5              @ clear the upper half of r3 [y]

        mla     r6, r6, r2, r3          @ r6 = r6 * r3 + r2 (x * MAP_SIZE_Y + y)
        add     r0, r0, r6              @ r0 = r0 + r6 (current position on the map at (x,y))
        mov     r7, r0                  @ r7 = r0, will be used later to keep temporary values

@ r2 : x position
@ r3 : y position
@ r0 : current position at x, y [map]
@ r7 : temporary position at x, y (used for calculations) [map]

@ Test at y + 1 (EAST): map + 1
check_east:
        cmp     r3, #MAP_SIZE_Y - 1     @ compare y with MAP_SIZE_Y - 1
        beq     check_west              @ branch to the next test if y is equal to MAP_SIZE_Y, the bit will be cleared in the check_bound section anyway
        addne   r7, r7, #1              @ move 1 to the EAST of the map
        ldrneb  r8, [r7]                @ load the character held at this address in r8
        cmpne   r8, #WALL_ASCII         @ compare the character with the WALL character
        eoreq   r4, #EAST_MASK          @ clear the EAST bit if r8 holds a WALL character.
        mov     r7, r0                  @ reset r7 to r0.
@ Test at y - 1 (WEST): map - 1
check_west:
        cmp     r3, #0                  @ compare y with 0
        beq     check_south             @ branch to the next test if y is equal to 0
        subne   r7, r7, #1              @ move 1 to the WEST of the map
        ldrneb  r8, [r7]                @ load the character held at this address in r8
        cmpne   r8, #WALL_ASCII         @ compare the character with the WALL character
        eoreq   r4, #WEST_MASK          @ clear the WEST bit if r8 holds a WALL character.
        mov     r7, r0                  @ reset r7 to r0.
@ Test at x + 1 (SOUTH): map + MAP_SIZE_Y
check_south:
        cmp     r2, #MAP_SIZE_X - 1     @ compare x with MAP_SIZE_X - 1
        beq     check_north             @ branch to the next test if y is equal to MAP_SIZE_X
        addne   r7, r7, #MAP_SIZE_Y     @ move 1 to the SOUTH of the map
        ldrneb  r8, [r7]                @ load the character held at this address in r8
        cmpne   r8, #WALL_ASCII         @ compare the character with the WALL character
        eoreq   r4, #SOUTH_MASK         @ clear the SOUTH bit if r8 holds a WALL character.
        mov     r7, r0                  @ reset r7 to r0.
@ Test at x - 1 (NORTH): map - MAP_SIZE_Y
check_north:
        cmp     r2, #0                  @ compare x with 0
        beq     check_bounds            @ branch to the next test if x is equal to 0
        subne   r7, r7, #MAP_SIZE_Y     @ move 1 to the NORTH of the map 
        ldrneb  r8, [r7]                @ load the character held at this address in r8
        cmpne   r8, #WALL_ASCII         @ compare the character with the WALL character
        eoreq   r4, #NORTH_MASK         @ clear the NORTH bit if r8 holds a WALL character.
        mov     r7, r0                  @ reset r7 to r0.
check_bounds:
        cmp     r2, #0                  @ compare r2 [x] with 0
        eoreq   r4, #NORTH_MASK         @ clear the NORTH bit if x is equal to 0

        cmp     r2, #MAP_SIZE_X - 1     @ compare r2 [x] with MAP_SIZE_X - 1
        eoreq   r4, #SOUTH_MASK         @ clear the SOUTH bit if x is equal to MAP_SIZE_X

        cmp     r3, #0                  @ compare r3 [y] with 0
        eoreq   r4, #WEST_MASK          @ clear the WEST bit if x is equal to 0

        cmp     r3, #MAP_SIZE_Y - 1     @ compare r3 [y] with MAP_SIZE_Y
        eoreq   r4, #EAST_MASK          @ clear the EAST bit if x is equal to MAP_SIZE_Y

        mov     r0, r4                  @ move the possible directions to r0

	@@@@@@@@@@@ ----------- @@@@@@@@@@

        ldmfd sp!, {r4-r12, lr}
        mov   sp, r12
        mov   pc, lr