        # Authors : ANNEN Rayane
        # File    : asm_filter.S
        # Date    :
        # AT&T Syntax

#include "image_processing.h"

.globl asm_filter
.type asm_filter, @function

.equiv PIXEL_MAX, 255                   # Maximum value of a pixel
.extern edge_detection_3x3              # Kernel to use

.macro get_pixel, X, Y, WIDTH, SRC, DEST, SCRATCH
        movl    \SRC, \DEST             # Copy pointer to the source image in DEST
        addl    (\X), \DEST             # DEST + x
        movl    (\Y), \SCRATCH          # SCRATCH = y
        imull   (\WIDTH), \SCRATCH      # SCRATCH = SCRATCH * WIDTH (y * width)
        addl    \SCRATCH, \DEST         # DEST = DEST + SCRATCH, DEST = *(src + y * width + x)    
.endm

.text
        # Function arguments :
        # ebp + 8  : address of source image data (pointer to unsigned 8 bits)
        # ebp + 12 : address of destination image data (already allocated)
        # ebp + 16 : width of the image (signed 32 bits)
        # ebp + 20 : height of the image (signed 32 bits)
        # ebp + 24 : x position of pixel (signed 32 bits)
        # ebp + 28 : y position of pixel (signed 32 bits)

asm_filter:
        pushl %ebp                      # Save old stack frame
        movl  %esp, %ebp                # Set new stack base
        pushl %esi                      # Save registers
        pushl %edi                      # Save registers
        pushl %ebx                      # Save registers

        # Copy of the arguments for easier access
        movl 8(%ebp),   %esi            # esi is for source
        movl 12(%ebp),  %edi            # edi is for destination

        movl 16(%ebp),  %eax
        movl %eax,      (width)         # width holds the width parameter
        movl 20(%ebp),  %eax
        movl %eax,      (height)        # height holds the height parameter
        movl 24(%ebp),  %eax
        movl %eax,      (x)             # x holds the x position
        movl 28(%ebp),  %eax
        movl %eax,      (y)             # y holds the y position

check_if_on_border:
        # TODO : Check if the current pixel is on the border of the image
        # when on border jump to copy_pixel else continue

        movl    (x), %eax               # eax holds the x position
        movl    (width), %ebx           # ebx holds the width of the image
        decl    %ebx

        cmpl    %eax, %ebx              # compare x and the width
        je      copy_pixel              # skip this pixel if on the border
        
        cmpl    $0, %eax                # compare x and 0
        je      copy_pixel

        # same with y
        movl    (y), %eax
        movl    (height), %ebx            
        decl    %ebx

        cmpl    %eax, %ebx
        je      copy_pixel

        cmpl    $0, %eax
        je      copy_pixel

conv_filter:

        # TODO : Implement the convolution filter

        # Copy pixel from esi to eax
        get_pixel x, y, width, %esi, %eax, %ebx
        
        subl    (width), %eax
        decl    %eax                    # eax holds the upper leftmost pixel of the source image

        movl    $edge_detection_3x3, %edx
        addl    $8, %edx                # edx holds the end of the kernel array

        movl    $0, (it)                # iterator
        movl    $0, (res)               # accumulator

        xorl    %ebx, %ebx              # reset ebx
        xorl    %ecx, %ecx              # reset ecx

        loop:
                movzbl  (%eax), %ebx    # ebx holds the current pixel (uint8_t)
                movsbl  (%edx), %ecx    # ecx holds the current kernel cell (int8_t)
                imull   %ecx, %ebx      # compute current_pixel * current_kernel_cell
                addl    %ebx, (res)     # add result in the accumulator res 

                cmpl    $2, (it)        
                jne     1f
                subl    $3, %eax        # get back to the start of the line
                addl    (width), %eax   # get to the next line
                
                1:
                cmpl    $5, (it)
                jne     2f
                subl    $3, %eax         # go back to the start of the line
                addl    (width), %eax    # go to the next line
                
                2:
                decl    %edx            # next kernel cell
                incl    %eax            # next pixel
                incl    (it)            # increment iterator

                cmpl    $9, (it)
                jne     loop

        # - if acc < 0 : acc = -acc

        cmpl    $0, (res)
        jge     1f
        negl    (res)
        
        # - if acc > 255 : acc = 255

        1:
        cmpl    $PIXEL_MAX, (res)
        jle     2f
        movl    $PIXEL_MAX, (res)

        2:
        # Copy pixel from edi to eax
        get_pixel x, y, width, %edi, %eax, %ebx

        movl  (res), %ebx               # copy result to a scratch register
        movl  %ebx, (%eax)              # copy the result to the destination

exit:
        popl %ebx                       # Restore registers
        popl %edi       	        # Restore registers
	popl %esi                       # Restore registers
	leave                           # Restore stack frame
	ret                             # Return to caller

copy_pixel:
        # TODO : Copy pixel from source to destination image

        # Copy pixel from esi to eax
        get_pixel x, y, width, %esi, %eax, %ebx
        
        xorl     %ebx, %ebx              # reset the ebx register

        # Copy pixel from edi to ebx
        get_pixel x, y, width, %edi, %ebx, %ecx

        xorl     %ecx, %ecx              # reset the ecx register

        movl    (%eax), %ecx            # Copy the pixel from the source into a temporary register
        movl    %ecx, (%ebx)            # Copy from the scratch register to the memory

        jmp     exit                    # exit

.bss
        # Block Started by Symbol Section
        # space is 4 bytes because the values are 32 bit

width:                                  # image width
        .space 4
height:                                 # image height
        .space 4
x:                                      # x position of pixel
        .space 4
y:                                      # y position of pixel
        .space 4
res:                                    # result of convolution
        .space 4
it:                                     # iterator used in the algorithm
        .space 4