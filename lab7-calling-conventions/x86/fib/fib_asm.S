#     ___   _____ __  ______   ____ ___  ___ 
#    /   | / ___//  |/  /__ \ / __ \__ \|__ \
#   / /| | \__ \/ /|_/ /__/ // / / /_/ /__/ /
#  / ___ |___/ / /  / // __// /_/ / __// __/ 
# /_/  |_/____/_/  /_//____/\____/____/____/ 
#
# Author : Rayane ANNEN

.text

## @brief uint32_t fib_asm(uint32_t n)
## Computes the nth Fibonacci number recursively
## Fib(0) = 0, Fib(1) = 1, Fib(n) = Fib(n-1) + Fib(n-2) for n > 1
## @param n the nth number we want as a result
## @return the nth Fibonacci number 0, 1, 1, 2, 3, 5, 8 etc...
.global silly_fib_asm
.type fib_asm, @function
silly_fib_asm:
#   @@@@@@@@@@@ A completer @@@@@@@@@@
    # prologue
    push    %ebp
    mov     %esp, %ebp

    mov     8(%ebp), %eax    # n
    cmp     $2, %eax        
    
    jl      1f             # if n < 2, return n
    push    %ebx            # save ebx
    dec     %eax            # n-1
    push    %eax            # push n-1
    
    call    silly_fib_asm   # fib(n-1)
    mov     %eax, %ebx      # save fib(n-1) in ebx
    decl    (%esp)          # n-2
    
    call    silly_fib_asm   # fib(n-2)
    add     %ebx, %eax      # fib(n-1) + fib(n-2)
    add     $4, %esp        # pop n-2
    pop     %ebx            # restore ebx
    
    1:
    # epilogue
    leave
    ret

#   @@@@@@@@@@@ ----------- @@@@@@@@@@

## @brief uint32_t fib_asm(uint32_t n, uint32_t a = 0, uint32_t b = 1)
## Computes the nth Fibonacci number recursively
## Fib(0) = 0, Fib(1) = 1, Fib(n) = Fib(n-1) + Fib(n-2) for n > 1
## @param n the nth number we want as a result
## @param a,b used for recursion
## @return the nth Fibonacci number 0, 1, 1, 2, 3, 5, 8 etc...
.global fib_asm
.type fib_asm, @function
fib_asm:
#   @@@@@@@@@@@ A completer @@@@@@@@@@
    push    %ebp
    mov     %esp, %ebp

    sub     $12, %esp       # reserve space for a, b and n

    mov     8(%ebp), %eax    # n
    mov     12(%ebp), %edx   # a
    mov     16(%ebp), %ecx   # b

    cmp     $0, %eax        
    je      10f           # if n == 0, return a

    cmp     $1, %eax
    je      11f           # if n == 1, return b
    
    dec     %eax            # n-1
    add     %edx, %ecx      # b + a
    mov     16(%ebp), %edx  # a = b  

    push    %ecx            # push b + a
    push    %edx            # push b to replace a 
    push    %eax            # push n-1
    
    call    fib_asm         # fib(n-1, b, b+a)
    add     $12, %esp       # pop n-1, b, b+a

    1:
    leave 
    ret

    10:
    mov     %edx, %eax
    jmp     1b

    11:
    mov     %ecx, %eax
    jmp     1b

#   @@@@@@@@@@@ ----------- @@@@@@@@@@

## @brief uint32_t fib_asm(uint32_t n, uint32_t a = 0, uint32_t b = 1)
## Computes the nth Fibonacci number recursively
## Fib(0) = 0, Fib(1) = 1, Fib(n) = Fib(n-1) + Fib(n-2) for n > 1
## @param n the nth number we want as a result
## @param a,b used for recursion
## @return the nth Fibonacci number 0, 1, 1, 2, 3, 5, 8 etc...
.global fib_asm_tail
.type fib_asm_tail, @function
fib_asm_tail:
#   @@@@@@@@@@@ A completer @@@@@@@@@@
    push    %ebp
    mov     %esp, %ebp

    sub     $12, %esp       # reserve space for a, b and n

    push    %ebx            # save ebx

    mov    8(%ebp), %eax    # n
    mov    12(%ebp), %edx   # a
    mov    16(%ebp), %ecx   # b

    cmp     $0, %eax        
    je      1f              # if n == 0, return 0

    while:
    dec     %eax            # n-1

    cmp     $0, %eax        
    je      10f             # if n == 0, return b

    mov     %ecx, %ebx      # save b
    add     %edx, %ecx      # b = b + a
    mov     %ebx, %edx      # a = b
    jmp     while    

    1:
    add     $12, %esp       # pop n-1, b, b+a
    pop     %ebx            # restore ebx
    leave 
    ret

    10:
    mov     %ecx, %eax
    jmp     1b

#   @@@@@@@@@@@ ----------- @@@@@@@@@@
