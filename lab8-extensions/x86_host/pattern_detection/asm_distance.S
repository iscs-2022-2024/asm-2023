.global asm_matrix_distance_simd
.type asm_matrix_distance_simd, @function

.text

# Functions parameters : image_container* img, image_container* kernel, int x, int y
asm_matrix_distance_simd:
#   @@@@@@@@@@@ A completer @@@@@@@@@@
    push    %ebp
    mov     %esp, %ebp
    subl    $4, %esp                # localvar: sum
    
    push    %ebx
    push    %esi
    push    %edi

    
    movl    8(%ebp), %eax           # img address
    movl    (%eax), %ecx            # img->width
    movl    %ecx, (image_width)
    movl    4(%eax), %ecx           # img->height
    movl    %ecx, (image_height)

    movl    12(%ebp), %eax          # kernel address
    movl    (%eax), %ecx            # kernel->width
    movl    %ecx, (kernel_width)    
    movl    4(%eax), %ecx           # kernel->height
    movl    %ecx, (kernel_height)   

    movl    16(%ebp), %eax          # x
    movl    %eax, (x)

    movl    20(%ebp), %eax          # y
    movl    %eax, (y)

    movl    $0, (ky)
    movl    $0, -4(%ebp)            # initialize sum to 0

    pxor    %xmm0, %xmm0            # reset xmm0
    pxor    %xmm1, %xmm1            # reset xmm1

    movl    8(%ebp), %eax           # img address
    movl    12(%eax), %esi          # esi = img->data

    movl    12(%ebp), %eax          # kernel address
    movl    12(%eax), %edi          # edi = kernel->data
        
    loop_y:
        movl        $0, (kx)            # init kx to 0
    loop_x:

        movl        (ky), %ebx          # ebx = ky
        addl        (y), %ebx           # ebx = ky + y   
        imull       (image_width), %ebx # ebx = (ky + y) * image_width
        addl        (kx), %ebx          # ebx = (ky + y) * image_width + kx
        addl        (x), %ebx           # ebx = (ky + y) * image_width + kx + x

        pmovzxbd    (%esi, %ebx), %xmm0 # extend to 32-bit integers 4 pixels

        # ebx = ky * kernel->width + kx

        movl        (ky), %ebx          
        imull       (kernel_width), %ebx
        addl        (kx), %ebx        

        pmovzxbd    (%edi, %ebx), %xmm1 # extend to 32-bit integers 4 pixels

        psubd       %xmm1, %xmm0        # compute vectorized difference between pixels
        pmulld      %xmm0, %xmm0        # compute vectorized square between pixels

        phaddd      %xmm0, %xmm0        # horizontally add components
        phaddd      %xmm0, %xmm0        # Accumulate components

        movd        %xmm0, %eax        
        addl        %eax, -4(%ebp)

        addl        $4, (kx)
        movl        (kx), %eax
        cmpl        (kernel_width), %eax
        jl loop_x

    incl        (ky)
    movl        (ky), %eax
    cmpl        (kernel_height), %eax
    jl loop_y

    movl    -4(%ebp), %eax
    pop     %ebx
    pop     %esi
    pop     %edi
    leave   
    ret
#   @@@@@@@@@@@ ----------- @@@@@@@@@@




.data

kernel_width:
    .space 4

kernel_height:
    .space 4

image_width:
    .space 4

image_height:
    .space 4
kx:
    .space 4
ky:
    .space 4
x: 
    .space 4
y: 
    .space 4
