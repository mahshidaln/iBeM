#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "matrix.h"

void row_sawp(struct Matrix m, int first, int second)
{
    float temp;
    for (int i = 0; i < m.col; i++)
    {
        temp = m.mat[first][i];
        m.mat[first][i] = m.mat[second][i];
        m.mat[second][i] = temp;
    }
}

void row_sub(struct Matrix m, int to_zero, int pivot, int zero_col)
{

    float temp;
    float coef = m.mat[to_zero][zero_col];
    for (int i = 0; i < m.col; i++)
    {
        m.mat[to_zero][i] -= coef * m.mat[pivot][i];
    }
}

void row_devide(struct Matrix m, int row, float num)
{
    if (num == 0)
        return;

    for (int i = 0; i < m.col; i++){
        m.mat[row][i] = m.mat[row][i] / num;
    }
}

void rref(struct Matrix m)
{
    int col_pointer = 0;
    int row_pointer = 0;
    while (row_pointer < m.row)
    {
    	if(col_pointer == m.col)
			break;
        if (m.mat[row_pointer][col_pointer] == 0)
        {
            int is_pivot = 0;
            for (int j = row_pointer + 1; j < m.row; j++)
            {
                if (m.mat[j][col_pointer] != 0)
                {
                    row_sawp(m, row_pointer, j);
                    is_pivot = 1;
                    break;
                }
            }
            if (is_pivot == 0)
            {
                col_pointer++;
                continue;
            }
        }
        // print_mat(m.mat, m.row, m.col);
        row_devide(m, row_pointer, m.mat[row_pointer][col_pointer]);
        // print_mat(m.mat, m.row, m.col);

        for (int i = 0; i < m.row; i++)
        {
            if (i == row_pointer)
                continue;
            row_sub(m, i, row_pointer, col_pointer);
            // print_mat(m.mat, m.row, m.col);
        }
        row_pointer++;
        // print_mat(m.mat, m.row, m.col);
    }
}
