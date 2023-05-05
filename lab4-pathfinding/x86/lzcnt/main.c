#include <common.h>
#include <exports.h>

#define BIT32 0x80000000

uint32_t leading_zero_count_c(const uint32_t value) {
    int i = 0;
    while (((value << ++i) & BIT32) == 0 && i <= 32);
    return i;
}

uint32_t leading_zero_count(const uint32_t value) {
    uint32_t result = 0;

    // A vous de jouer !
    __asm__ ("lzcnt %1, %0" 
        : "=r" (result) 
        : "r" (value));

    return result;
}

int main(int argc, char *argv[]) {
    uint32_t input = 0x00000087;
    uint32_t expected_result = 24;

    uint32_t leading_zero_count_c_result = leading_zero_count_c(input);
    uint32_t leading_zero_count_result = leading_zero_count(input);

    if (leading_zero_count_c_result != expected_result) {
        printf("[C] [KO] Expected result is %d but %d was returned\n", expected_result, leading_zero_count_c_result);
    } else {
      printf("[C] [OK] Result %d is Correct !\n", leading_zero_count_c_result);
    }

    if (leading_zero_count_result != expected_result) {
        printf("[ASM] [KO] Expected result is %d but %d was returned\n", expected_result, leading_zero_count_result);
    } else {
      printf("[ASM] [OK] Result %d is Correct !\n", leading_zero_count_result);
    }

    printf("Built-in result is %d\n", __builtin_ia32_lzcnt_u32(input));

    printf("Hit any key to exit ... ");
    while (!tstc());

    /* consume input */
    (void) getc();

    printf("\n\n");
    return 0;
}
