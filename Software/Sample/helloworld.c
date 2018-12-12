/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */
//#include "unistd.h"
#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"

#include "matrix.h"
#include "post_process.h"
#include "pre_process.h"

#define base 0x43C00000

char *int2bin(int n)
{
    // determine the number of bits needed ("sizeof" returns bytes)
    int nbits = sizeof(n) * 8;
    char *s = malloc(nbits + 1); // +1 for '\0' terminator
    s[nbits] = '\0';
    // forcing evaluation as an unsigned value prevents complications
    // with negative numbers at the left-most bit
    unsigned int u = *(unsigned int *)&n;
    int i;
    unsigned int mask = 1 << (nbits - 1); // fill in values right-to-left
    for (i = 0; i < nbits; i++, mask >>= 1)
        s[i] = ((u & mask) != 0) + '0';
    return s;
}

int main()
{
    init_platform();

	printf("pre process started.\n");
	struct Matrix pre = pre_process_sample0();
	printf("pre process completed:\n");
	print_mat(pre.mat, pre.row, pre.col);
	printf("sending to hardware...\n");
	int *binary = to_binary(pre);
	for(int i = 0; i < (pre.row - pre.col) * pre.col; i++){
		printf("%d,%d    ", i,binary[i]);
		Xil_Out32(base + ((40 + i) * 4 ) , binary[i]);
	}
	printf("\n");
    Xil_Out32(base + 20 * 4 , 1);

    int sw_call = 0;
    struct Matrix mp;
    mp.row = 6;
    mp.col = 6;

    float **mp_p = malloc(mp.row * sizeof(float *));
    for (int i = 0; i < mp.row; i++)
        mp_p[i] = malloc(mp.col * sizeof(float));

    mp.mat = mp_p;

    // Wait for Hardware
    printf("waiting for hardware computations...\n");
    while (1)
    {
        sw_call = Xil_In32(base);
        if (sw_call == 1)
            break;
    }
    printf("hardware computations done.\n");
    int em;
    char *em_binary;
    for (int i = 0; i < mp.col; i++)
    {
        em = Xil_In32(base + ((i + 3) * 4));
        em_binary = int2bin(em);
        int cell;
        for (int j = 26; j < 32; j++)
        {
            cell = em_binary[j] - 48;
             mp_p[j - 26][i] = cell;
        }
    }
    struct Matrix result = post_process_sample0(mp);
    printf("post process completed.\n");
    printf("EFMS %d x %d:\n",result.row, result.col);

    print_mat_t(result.mat, result.row, result.col);
    cleanup_platform();
    return 0;
}
