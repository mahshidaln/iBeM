#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "null_space.h"
#include "rref.h"

struct Matrix reconfigure(struct Matrix m, int *irrev)
{
    struct Matrix res;
    int rev_count = 0;
    for (int i = 0; i < m.col; i++)
        if (irrev[i] == 0)
            rev_count++;

    float **res_poiner = malloc(m.row * sizeof(float *));

    int final_matrix_col_pointer = 0;
    for (int i = 0; i < m.row; i++)
        res_poiner[i] = malloc((m.col + rev_count) * sizeof(float));

    for (int i = 0; i < m.col; i++)
    {
        if (irrev[i] == 0)
        {
            for (int j = 0; j < m.row; j++)
            {
                if (m.mat[j][i] != 0)
                    res_poiner[j][final_matrix_col_pointer] = -m.mat[j][i];
                else
                    res_poiner[j][final_matrix_col_pointer] = 0;
            }

            final_matrix_col_pointer++;
            for (int j = 0; j < m.row; j++)
                res_poiner[j][final_matrix_col_pointer] = m.mat[j][i];
            final_matrix_col_pointer++;
        }
        else
        {
            for (int j = 0; j < m.row; j++)
                res_poiner[j][final_matrix_col_pointer] = m.mat[j][i];
            final_matrix_col_pointer++;
        }
    }
    res.col = m.col + rev_count;
    res.row = m.row;
    res.mat = res_poiner;
    return res;
}

struct Matrix transpose(struct Matrix m)
{
    struct Matrix tr;
    float **tr_pointer = malloc(m.col * sizeof(float *));
    for (int i = 0; i < m.col; i++)
        tr_pointer[i] = malloc(m.row * sizeof(float));

    for (int i = 0; i < m.row; i++)
        for (int j = 0; j < m.col; j++)
            tr_pointer[j][i] = m.mat[i][j];

    tr.mat = tr_pointer;
    tr.col = m.row;
    tr.row = m.col;
    return tr;
}

int is_eye_row(struct Matrix m, int row, int eye)
{
    int res = 1;
    if (m.mat[row][eye] != 1)
        res = 0;

    for (int i = 0; i < m.col; i++)
        if (i != eye && m.mat[row][i] != 0)
            res = 0;
    return res;
}

int *row_perm(struct Matrix m)
{
    int *res = malloc(sizeof(int) * m.row);

    for (int i = 0; i < m.row; i++)
        res[i] = i;

    for (int i = 0; i < m.col; i++)
    {
        if (!is_eye_row(m, i, i))
            for (int j = 0; j < m.row; j++)
            {
                if (is_eye_row(m, j, i))
                {
                    int temp_index = res[i];
                    res[i] = res[j];
                    res[j] = temp_index;
                    float *temp = m.mat[j];
                    m.mat[j] = m.mat[i];
                    m.mat[i] = temp;
                }
            }
    }
    return res;
}

struct Matrix initialize(struct Matrix m)
{
    struct Matrix tr = transpose(m);
    rref(tr);
    struct Matrix tr_rref_tr = transpose(tr);
    int *perm = row_perm(tr_rref_tr);

    for (int i = 0; i < m.row; i++)
        printf("%d ", perm[i]+1);
    printf("\n");

    return tr_rref_tr;
}

int *to_binary(struct Matrix m){
    int *res = malloc((m.row - m.col) * m.col * sizeof(int));

    for(int i = m.col; i < m.row; i++)
        for(int j = 0; j < m.col; j++)
        {
            if (m.mat[i][j] == 1){
                res[(i - m.col) * (m.col) + j] = 1<< 15;
            }
            else if (m.mat[i][j] == 0){
                res[(i - m.col) * (m.col) + j] = 0;
            }
            else if (m.mat[i][j] == .5){
                res[(i - m.col) * (m.col) + j] = 1 << 14;
            }
            else if (m.mat[i][j] == -.5){
                res[(i - m.col) * (m.col) + j] = 67092480;
            }
            //printf("%.1f     ", m.mat[i][j]);
            //printf("%d, %d\n", (i - m.col) * (m.col) + j,res[(i - m.col) * (m.col) + j]);
        }
    return res;
}

struct Matrix pre_process_sample0()
{

     float r1[] = {1,0,-1,-1,-1};
     float r2[] = {0,1,0,-1,1};
     float *m_p[] = {r1, r2};

     int irrev[] = {1, 1, 1, 1, 0};

     struct Matrix m;
     m.row = 2;
     m.col = 5;
     m.mat = m_p;

    struct Matrix m_rec = reconfigure(m, irrev);
    // print_mat(m_rec.mat, m_rec.row, m_rec.col);
    struct Matrix m_null = null_space(m_rec);
    // print_mat(m_null.mat, m_null.row, m_null.col);

    struct Matrix m_init = initialize(m_null);
    return m_init;

}
