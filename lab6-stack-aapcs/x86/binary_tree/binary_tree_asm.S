# Author : ANNEN Rayane

.global traverse_tree_asm

.extern printf

# Macro that will print what is at the end of string_ptr (char *)
# with an extra space at the end (through the format string used).
.macro PUT_S string_ptr
    pushal
    push \string_ptr
    push $format_string
    call printf
    add  $0x8, %esp
    popal
.endm

## @brief void traverse_tree_asm(Node *root);
## Traverses a binary search tree in natural order and prints data if available
##
## @param Node *root the root of the tree to traverse and prints
traverse_tree_asm:
        # Intro
        pushl %ebp                      # Save old stack frame
        movl  %esp, %ebp                # Set new stack base
        pushal                          # Save all registers
        movl  8(%ebp), %eax             # copy the argument in eax
	####### Student code below


        # eax = root
        # eax + 4 = root.data
        # eax + 8 = root.left
        # eax + c = root.right

        # ebx = stack size 

        movl    $0, %ebx

        # Iterative preorder traversal
        # p <- root
        # while p != NULL or stack is not empty:
        #       while p != null:
        #               stack_push(p)
        #               p = p.left
        #       p = stack_pop()
        #       p <- p.right
        # reference: https://faculty.cs.niu.edu/~mcmahon/CS241/Notes/Data_Structures/binary_tree_traversals.html

        # while root != null OR size != 0
        while:
                cmpl    $0, %eax                # go all the way to the left
                jne     traverse_left           

                cmpl    $0, %ebx                # stack empty ?
                je      end
        traverse_left:
                cmpl    $0, %eax                # if there's nothing left then try to traverse to the right
                je      traverse_right

                pushl   %eax                    # push the current node (visit)
                incl    %ebx                    # increase stack size

                movl    0x8(%eax), %ecx         # move to the left
                movl    %ecx, %eax
                jmp     traverse_left
        traverse_right:
                popl    %eax                    # backtrack one level and print the node
                decl    %ebx                    # decrease stack size

                movl    0x4(%eax), %ecx         # print the node
                PUT_S   %ecx   

                movl    0xc(%eax), %ecx         # move to the right
                movl    %ecx, %eax

                jmp     while
        end:
	######## End of student code
        # Outro
        popal                           # Restore all register
        leave                           # Restore stack frame
        ret                             # Return to caller

.data
format_string:
    .string "%s "
