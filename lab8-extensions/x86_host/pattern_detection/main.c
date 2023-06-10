/*
 * File      : image_processing.c
 * Author    : Rick Wertenbroek
 * E-mail    : rick.wertenbroek@heig-vd.ch
 * Institute : REDS - HES-SO HEIG-VD
 * Year      : 2017
 *
 * Coding Style : Linux Kernel - but with 4 space tabs
 * https://www.kernel.org/doc/Documentation/CodingStyle
 *
 * ~ 80 Characters width
 */

#include <getopt.h>
#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <time.h>
#include "image_processing.h"

/* Single-file public domain librairies for C/C++
   https://github.com/nothings/stb */
#define STB_IMAGE_IMPLEMENTATION
#include "lib/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "lib/stb_image_write.h"

#define MAX(x, y) (((x) > (y)) ? (x) : (y))
#define MIN(x, y) (((x) < (y)) ? (x) : (y))

typedef struct
{
    int width;
    int height;
    int comp; /* Number of components per pixel, eg RGB => 3 */

    uint8_t *data;
} image_container;

/*************************
 * Function declarations *
 *************************/
void print_usage();
image_container *allocate_container(size_t width,
                                    size_t height,
                                    size_t comp);
image_container *load_image(const char *src_img_path);
image_container *grayscale_conversion(image_container *img);

void save_image(const char *dest_img_path, const image_container *img);
void free_container(image_container *img);

extern int asm_matrix_distance_simd(image_container *img,
									image_container *kernel,
									int x, int y);

int get_terminal_width() {
    struct winsize size;
    ioctl(0, TIOCGWINSZ, &size);
    return size.ws_col;
}

void display_loading(int percent, int t_width) {
    int i;
    int max_char = t_width / 2;
    int loaded = (int)(max_char * (percent / 100.0));

    printf("[");
    for (i = 0; i < loaded; i++) {
        printf("=");
    }
    for (i = loaded; i < max_char; i++) {
        printf(" ");
    }
    printf("] %d%%\r", percent);
    fflush(stdout);
}

void apply_filter(image_container *img, image_container *kernel, int *max_x, int *max_y) {

    /* Only works for grayscale images */
    if (img->comp != COMPONENT_GRAYSCALE) {
        return NULL;
    }

    int32_t x, y, kx, ky;
    int32_t sum = 0;
    int32_t l_sum = INT32_MAX;
    double p = 0;
    int t_width = get_terminal_width();

    for(y = 0; y < img->height - kernel->height; y++) {
        for(x = 0; x < img->width - kernel->width; x++) {
            
            sum = 0;

            for(ky = 0; ky < kernel->height; ky++) {
                for(kx = 0; kx < kernel->width; kx++) {

                    sum += pow(kernel->data[ky * kernel->width + kx] - img->data[(y + ky) * img->width + (x + kx)], 2);
                }
            }

            
            if(sum < l_sum){
                // printf("NEW BETTER MATCH %d, %d = %d\n", x, y, sum);
                *max_x = x;
                *max_y = y;
                l_sum = sum;
            }

            p = ((double)(y*(img->width - kernel->width)+x) / (double)((img->width - kernel->width)*(img->height - kernel->height))) * 100;
            display_loading((int)p, t_width);
        }
    }
    printf("\n");

}


void apply_filter_asm_simd(image_container *img, image_container *kernel, int *max_x, int *max_y) {

    /* Only works for grayscale images */
    if (img->comp != COMPONENT_GRAYSCALE) {
        return NULL;
    }

    int32_t x, y, kx, ky;
    int32_t sum = 0;
    int32_t l_sum = INT32_MAX;
    double p = 0;
    int t_width = get_terminal_width();

    for(y = 0; y < img->height - kernel->height; y++) {
        for(x = 0; x < img->width - kernel->width; x++) {
            
        	if(x == 1176 && y == 280) {
        		p = 0;
        	}
            
            sum = 0;
            
            sum = asm_matrix_distance_simd(img, kernel, x, y);

            if(sum < l_sum){
                // printf("NEW BETTER MATCH %d, %d = %d\n", x, y, sum);
                *max_x = x;
                *max_y = y;
                l_sum = sum;
            }

            p = ((double)(y*(img->width - kernel->width)+x) / (double)((img->width - kernel->width)*(img->height - kernel->height))) * 100;
            display_loading((int)p, t_width);

        }
    }
    printf("\n");
}


void draw_result(image_container *img, uint32_t pos_x, uint32_t pos_y, uint32_t kernel_size) {
    
    uint32_t end_x = pos_x + kernel_size;
    uint32_t end_y = pos_y + kernel_size;
    uint32_t thickness = 5;

    if(end_x >= img->width || end_y >= img->height) {
        printf("Pattern out of image\n");
        return;
    }

    if(kernel_size < thickness) {
        printf("Used small kernel\n");
        thickness = 1;
    }

    for (int i = 0; i < thickness; i++) {
        
        for(int x = pos_x; x < end_x+1; x++) {
        
            // bottom side
            img->data[((end_y + i)*(img->width) + x)*3] = 255;
            img->data[((end_y + i)*(img->width) + x)*3+1] = 0;
            img->data[((end_y + i)*(img->width) + x)*3+2] = 0;

            // top side
            img->data[((pos_y - i)*(img->width) + x)*3] = 255;
            img->data[((pos_y - i)*(img->width) + x)*3+1] = 0;
            img->data[((pos_y - i)*(img->width) + x)*3+2] = 0;

        }

        for(int y = pos_y; y < end_y+1; y++) {
        
            // left side
            img->data[(y*(img->width) + end_x-i)*3] = 255;
            img->data[(y*(img->width) + end_x-i)*3+1] = 0;
            img->data[(y*(img->width) + end_x-i)*3+2] = 0;
            
            // right side
            img->data[(y*(img->width) + pos_x+i)*3] = 255;
            img->data[(y*(img->width) + pos_x+i)*3+1] = 0;
            img->data[(y*(img->width) + pos_x+i)*3+2] = 0;
        }
    }
}

/********
 * MAIN *
 ********/
int main(int argc, char **argv)
{
    image_container *img, *img_grayscale;
    image_container *kernel, *kernel_grayscale;
    char cmd[CMD_SIZE];
    bool compare = false;
    char *image_path = IMAGE_FILE;
    char *kernel_path = KERNEL_FILE;
    int option;
    uint32_t max_x, max_y;
    clock_t start, end;
    double exec_time;

    /* Option handling */
    while ((option = getopt(argc, argv, "i:k:c")) != -1)
    {
        switch (option)
        {
        case 'i':
            image_path = optarg;
            break;
        case 'k':
            kernel_path = optarg;
            break;
        case 'c':
            compare = true;
            break;
        default:
            print_usage();
            exit(EXIT_FAILURE);
        }
    }

    /* Load image */
    img = load_image(image_path);

    /* Check if grayscale */
    if (img->comp != COMPONENT_GRAYSCALE)
    {
        img_grayscale = grayscale_conversion(img);
    }
    else
    {
        img_grayscale = img;
    }

    /* Load kernel */
    kernel = load_image(kernel_path);

    /* Check if grayscale */
    if (kernel->comp != COMPONENT_GRAYSCALE)
    {
        kernel_grayscale = grayscale_conversion(kernel);
    }
    else
    {
        kernel_grayscale = kernel;
    }

    save_image("img_gray.png", img_grayscale);
    save_image("kernel_gray.png", kernel_grayscale);

    if(compare) {

        /* Do the C filtering */
        printf("\n******************     Filter C code     ******************\n");
        start = clock();
        apply_filter(img_grayscale, kernel_grayscale, &max_x, &max_y);
        end = clock();
        exec_time = (double)(end-start) / CLOCKS_PER_SEC;
        printf("FOUND: (%d, %d), execution time: %.2fs\n",max_x, max_y, exec_time);
    }

    max_x = 0;
    max_y = 0;

    /* Do the ASM SIMD filtering */
    printf("\n******************  Filter ASM SIMD code ******************\n");
    start = clock();
    apply_filter_asm_simd(img_grayscale, kernel_grayscale, &max_x, &max_y);
    end = clock();
    exec_time = (double)(end-start) / CLOCKS_PER_SEC;
    printf("FOUND: (%d, %d), execution time: %.2fs\n\n",max_x, max_y, exec_time);


    draw_result(img, max_x, max_y, kernel_grayscale->width);

    save_image(RESULT_FILE, img);
    sprintf(cmd, "display %s &", RESULT_FILE);
    system(cmd);

    /* Free the containers */
    free_container(img);
    if (img->comp != COMPONENT_GRAYSCALE)
    {
        free_container(img_grayscale);
    }

    free_container(kernel);
    if (kernel->comp != COMPONENT_GRAYSCALE)
    {
        free_container(kernel_grayscale);
    }
    
    /* Exit */
    return EXIT_SUCCESS;
}

/************************
 * Function definitions *
 ************************/

/* Prints the usage message */
void print_usage()
{
    printf("Usage : image_processing [-f] filename [-s]\n");
    printf("-i specify the image file to be processed\n");
    printf("-k specify the pattern to find\n");
    printf("-c compare between C, ASM, SIMD\n");
}

/* Allocates an image container and space for the image data */
image_container *allocate_container(size_t width, size_t height, size_t comp)
{
    if (comp == 0 || comp > COMPONENT_RGBA)
        return NULL;

    image_container *img;

    /* Allocate the struct */
    img = malloc(sizeof(image_container));
    if (!img)
    {
        fprintf(stderr, "[%s] allocation error\n", __func__);
        perror(__func__);
        exit(EXIT_FAILURE);
    }

    img->width = width;
    img->height = height;
    img->comp = comp;

    /* Allocate space for image */
    img->data = calloc(img->width * img->height * img->comp, sizeof(uint8_t));
    if (!(img->data))
    {
        fprintf(stderr, "[%s] image allocation error\n", __func__);
        perror(__func__);
        exit(EXIT_FAILURE);
    }

    return img;
}

/* Function that takes a path to an image file and loads
   the image in memory. */
image_container *load_image(const char *src_img_path)
{
    FILE *fimg;
    image_container *img;

    /* Open the image file */
    fimg = fopen(src_img_path, "rb"); /* Read Binary */
    if (!fimg)
    {
        fprintf(stderr, "[%s] fopen error (%s)\n", __func__, src_img_path);
        exit(EXIT_FAILURE);
    }

    /* Allocate the struct */
    img = malloc(sizeof(image_container));
    if (!img)
    {
        fprintf(stderr, "[%s] struct allocation error\n", __func__);
        exit(EXIT_FAILURE);
    }

    /* Load the image in the struct */
    img->data = stbi_load(src_img_path, &(img->width), &(img->height),
                          &(img->comp), 0);
    if (!(img->data))
    {
        fprintf(stderr, "[%s] stb load image failed\n", __func__);
        exit(EXIT_FAILURE);
    }

    fprintf(stdout, "[%s] image %s loaded (%d components, %dx%d)\n", __func__,
            src_img_path, img->comp, img->width, img->height);
    return img;
}

/* Creates a grayscale version of the image */
image_container *grayscale_conversion(image_container *img)
{
    if (img->comp != COMPONENT_RGB && img->comp != COMPONENT_RGBA)
    {
        fprintf(stderr, "[%s] only accepts color images with RGB components\n",
                __func__);
        perror(__func__);
        exit(EXIT_FAILURE);
    }

    image_container *grayscale = allocate_container(img->width,
                                                    img->height,
                                                    COMPONENT_GRAYSCALE);

    size_t index = 0;
    int i, j;

    for (i = 0; i < img->height; ++i)
    {
        for (j = 0; j < img->width; ++j)
        {

            grayscale->data[i * img->width + j] =
                LUMINOSITY_R * img->data[index + R_OFFSET] +
                LUMINOSITY_G * img->data[index + G_OFFSET] +
                LUMINOSITY_B * img->data[index + B_OFFSET];

            index += img->comp;
        }
    }

    return grayscale;
}

/* 8bit Comparison function from pointers */
int compare_uint8_t(const void *a, const void *b)
{
    /* This is just like an x86 cmp */
    return (*(uint8_t *)a - *(uint8_t *)b);
}


/* Save the processed image to disk */
void save_image(const char *dest_img_path, const image_container *img)
{
    if (!stbi_write_png(dest_img_path,
                        img->width,
                        img->height,
                        img->comp,
                        img->data,
                        PNG_STRIDE_IN_BYTES))
    {
        fprintf(stderr, "[%s] save image failed\n", __func__);
        exit(EXIT_FAILURE);
    }

    fprintf(stdout, "[%s] PNG file %s saved (%dx%d)\n", __func__, dest_img_path,
            img->width, img->height);
}

/* Release the memory used by img */
void free_container(image_container *img)
{
    if (img)
    {
        if (img->data)
        {
            stbi_image_free(img->data);
        }
        free(img);
    }
}
