#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "rref.h"

void initMat(float **matrix, int n, int m);
void rowSwap(float **A, int swap, int with, int n, int m);
void setMatrix(float **A, int n, int m);
void onesPivot(float **A, int row, int col, int m);
void multAdd(float **A, int row, int row2, int col, int m);
void print_mat(float **matrix, int n, int m);

void print_mat(float **matrix, int n, int m)
{
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
            printf("%.1f    ", matrix[i][j]);
        printf("\n");
    }
    printf("-------------------------------\n");
}
void print_mat_t(float **matrix, int n, int m)
{
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
            printf("%.1f    ", matrix[j][i]);
        printf("\n");
    }
    printf("-------------------------------\n");
}

int check_pvoit(struct Matrix m, int col, int prev_pivot)
{
    int flag = 0;
    if (m.row <= prev_pivot)
        return 0;
    for (int i = 0; i < m.row; i++)
    {
        if (m.mat[i][col] == 1 && flag == 0)
            flag = 1;
        else if (m.mat[i][col] == 1 && flag == 1)
            return 0;
        else if (m.mat[i][col] != 0)
            return 0;
    }
    return flag;
}

int non_zero_rows(struct Matrix m)
{
    int res = 0;
    for (int i = 0; i < m.row; i++)
    {
        int flag = 0;
        for (int j = 0; j < m.col; j++)
            if (m.mat[i][j] != 0)
                flag = 1;
        res += flag;
    }
    return res;
}

float *eye_row(int size, int row)
{
    float *res = malloc(size * sizeof(float));
    for (int i = 0; i < size; i++)
    {
        if (i == row)
            res[i] = 1;
        else
            res[i] = 0;
    }
    return res;
}

float *rref_row_from_free_cols(struct Matrix m, int row, int *free_cols, int free_cols_count)
{
    float *res = malloc(free_cols_count * sizeof(float));
    for (int i = 0; i < free_cols_count; i++)
    {
        if (m.mat[row][free_cols[i]] != 0)
            res[i] = -m.mat[row][free_cols[i]];
        else
            res[i] = 0;
    }
    return res;
}

struct Matrix null_space(struct Matrix m)
{

    //printf("initial matrix:\n\n");
    //print_mat(m.mat, m.row, m.col);
    rref(m);
    struct Matrix res = m;
    // print_mat(res.mat,res.row,res.col);

    //printf("rref matrix:\n\n");
    //print_mat(res.mat, res.row, res.col);

    int *free_cols = (int *)malloc(m.col * sizeof(int));
    //int nz_rows = non_zero_rows(res);
    int free_cols_count = 0;
    int pivot_count = 0;
    for (int i = 0; i < res.col; i++)
    {
        if (check_pvoit(res, i, pivot_count) != 1)
        {
            free_cols[free_cols_count] = i;
            free_cols_count++;
        }
        else
            pivot_count++;
    }

    /*
    printf("Free Cols\n");
    for (int i = 0; i < free_cols_count; i++)
    {
        printf("%d ", free_cols[i]);
    }
    printf("\n-------------------------------\n");
    printf("Free Cols Count:\t%d\n", free_cols_count);
    printf("\n-------------------------------\n");
    printf("Pivot Cols Count:\t%d\n", pivot_count);
    printf("\n-------------------------------\n");
    printf("None Zero Rows Count:\t%d\n", nz_rows);
    printf("-------------------------------\n");
    */

    float **null_space_pointer = malloc(res.col * sizeof(float *));

    int free_cols_pointer = 0;
    int eye_pointer = 0;
    int rref_pointer = 0;
    for (int i = 0; i < res.col; i++)
        if (free_cols[free_cols_pointer] == i)
        {
            null_space_pointer[i] = eye_row(free_cols_count, eye_pointer);
            eye_pointer++;
            free_cols_pointer++;
        }
        else
        {
            null_space_pointer[i] = rref_row_from_free_cols(res, rref_pointer, free_cols, free_cols_count);
            rref_pointer++;
        }

    struct Matrix null_space;
    null_space.col = free_cols_count;
    null_space.row = res.col;
    null_space.mat = null_space_pointer;
    // print_mat(null_space_pointer,res.col,free_cols_count);
    free(free_cols);
    return null_space;
}
