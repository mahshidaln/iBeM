#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "null_space.h"

struct Matrix bc(struct Matrix m, int rev_count)
{
  struct Matrix result;

  float **res_pointer = malloc((m.row - rev_count) * sizeof(float *));
  for (int i = 0; i < m.row - (2 * rev_count); i++)
  {
    res_pointer[i] = m.mat[i];
  }

  int res_row_pointer = m.row - (2 * rev_count);

  for (int i = (m.row - (2 * rev_count)); i < m.row; i += 2)
  {
    res_pointer[res_row_pointer] = malloc(m.col * sizeof(float));
    for (int j = 0; j < m.col; j++)
      res_pointer[res_row_pointer][j] = ((int)(m.mat[i][j] + m.mat[i + 1][j])) % 2;
    res_row_pointer++;
    free(m.mat[i]);
    free(m.mat[i+1]);
  }
  result.row = m.row - rev_count;
  result.col = m.col;
  result.mat = res_pointer;
  free(m.mat);
  return result;
}

struct Matrix remove2Cycles(struct Matrix m, int rev_count)
{
  struct Matrix result;
  int *to_remove = malloc(rev_count * sizeof(int));
  int to_remove_pointer = 0;
  for (int i = (m.row - 2 * rev_count); i < m.row; i+=2)
    for (int j = 0; j < m.col; j++)
    {
      int flag = 0;
      if (m.mat[i][j] != 1 || m.mat[i + 1][j] != 1)
        flag = 1;
      else
        for (int k = 0; k < m.row; k++)
          if (k != i && k != i + 1 && m.mat[k][j] != 0)
            flag = 1;
      if (flag == 0)
      {
        to_remove[to_remove_pointer] = j;
        to_remove_pointer++;
      }
    }

  float **res_pointer = malloc(m.row * sizeof(float *));
  for (int i = 0; i < m.row; i++)
    res_pointer[i] = malloc((m.col - rev_count) * sizeof(float));
  int skiped_count = 0;
  for (int i = 0; i < m.col; i++)
  {
    int flag = 0;
    for (int j = 0; j < rev_count; j++)
      if (to_remove[j] == i)
        flag = 1;
    if (flag == 0)
      for (int j = 0; j < m.row; j++)
        res_pointer[j][i - skiped_count] = m.mat[j][i];
    else
      skiped_count++;
  }
  result.col = m.col - rev_count;
  result.row = m.row;
  result.mat = res_pointer;
  free(to_remove);
  return result;
}

struct Matrix *bin2real(struct Matrix em, struct Matrix n)
{

  struct Matrix *null_spaces = malloc(em.col * sizeof(struct Matrix));

  // Initializing Equations Matrices
  for (int i = 0; i < em.col; i++)
  {
    // Allocating N(C,R)
    float **eq_mat = malloc(n.row * sizeof(float *));
    int eq_size = 0;

    // Finding non_zero cells number
    int non_zero_count = 0, non_zero_index = 0;
    for (int j = 0; j < em.row; j++)
      if (em.mat[j][i] == 1)
        non_zero_count++;
    eq_size = non_zero_count;

    for (int k = 0; k < n.row; k++)
      eq_mat[k] = malloc(non_zero_count * sizeof(float));

    // Allocating Equations Matrices
    for (int j = 0; j < em.row; j++){
      if (em.mat[j][i] == 1)
      {
        for (int k = 0; k < n.row; k++)
          eq_mat[k][non_zero_index] = n.mat[k][j];
        non_zero_index++;
      }
    }
    struct Matrix equation;
	equation.row = n.row;
	equation.col = eq_size;
	equation.mat = eq_mat;

	null_spaces[i] = null_space(equation);
	for (int k = 0; k < n.row; k++)
		free(eq_mat[k]);
	free(eq_mat);
  }
  return null_spaces;
}

struct Matrix finalize(struct Matrix *real_ems, struct Matrix em)
{
  struct Matrix res;
  res.row = em.col;
  res.col = em.row;
  res.mat = malloc(res.row * sizeof(float *));

  for(int i = 0; i < res.row; i++)
  {
      res.mat[i] = malloc(res.col * sizeof(float));
      int efm_pointer = 0;
      for(int j = 0; j < res.col; j++)
      {
        if(em.mat[j][i] != 0){
            res.mat[i][j] = real_ems[i].mat[efm_pointer][0];
            efm_pointer++;
        }
        else{
        	res.mat[i][j] = 0;
        }
        //printf("%.1f    ", res.mat[i][j]);
      }
      //printf("\n");
      for(int k = 0; k < real_ems[i].row; k++)
    	  free(real_ems[i].mat[k]);
      free(real_ems[i].mat);

  }

  return res;

}


void row_perm_post(struct Matrix m, int *perm)
{

  for (int i = 0; i < m.row; i++)
  {
    if (perm[i] != i)
    {
      int to_change;
      for (int j = i; j < m.row; j++)
        if (perm[j] == i)
          to_change = j;

      int temp_index = perm[i];
      perm[i] = perm[to_change];
      perm[to_change] = temp_index;
      float *temp = m.mat[to_change];
      m.mat[to_change] = m.mat[i];
      m.mat[i] = temp;
    }
  }
}

struct Matrix post_process_sample1(struct Matrix m){

  float r21[] = {-1, -2, 0, 0, 1, -1, 0, -1, -1, 0, 0, 0, 0, 1, 0};
  float r22[] = {-1, -1, -1, -1, -1, 1, 0, -1, 0, 0, 1, 0, 0, 0, 0};
  float r23[] = {1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 0};
  float r24[] = {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1, 0, 0, 0};
  float r25[] = {0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 1};
  float r26[] = {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, -1};
  float *n1[] = {r21, r22, r23, r24, r25, r26};
  struct Matrix n;
  n.row = 6;
  n.col = 15;
  n.mat = n1;

  int rev_count = 5;
  int perm[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 11, 15, 9, 17, 13, 19};

  row_perm_post(m, perm);
  // print_mat(em.mat, em.row, em.col);
  struct Matrix em_r2c = remove2Cycles(m, rev_count);
  // print_mat(em_r2c.mat, em_r2c.row, em_r2c.col);
  struct Matrix em_bc = bc(em_r2c, rev_count);
  // print_mat(em_bc.mat, em_bc.row, em_bc.col);
  struct Matrix *spaces = bin2real(em_bc, n);

  struct Matrix final = finalize(spaces, em_bc);

  //print_mat(final.mat, final.row, final.col);

  return final;   
}


struct Matrix post_process_sample0(struct Matrix m){

  float r7[] = {1, 0, -1, -1, -1};
  float r8[] = {0, 1, 0, -1, 1};
  float *n1[] = {r7, r8};
  struct Matrix n;
  n.row = 2;
  n.col = 5;
  n.mat = n1;

  int rev_count = 1;
  int perm[] = {0, 1, 2, 4, 3, 5};

  row_perm_post(m, perm);
  // print_mat(em.mat, em.row, em.col);
  struct Matrix em_r2c = remove2Cycles(m, rev_count);
  // print_mat(em_r2c.mat, em_r2c.row, em_r2c.col);
  struct Matrix em_bc = bc(em_r2c, rev_count);
  // print_mat(em_bc.mat, em_bc.row, em_bc.col);
  struct Matrix *spaces = bin2real(em_bc, n);

  struct Matrix final = finalize(spaces, em_bc);

  //print_mat(final.mat, final.row, final.col);

  return final;   
}

int main2()
{


  // First Sample
float r1[] = {1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,1};
float r2[] = {0 ,1 ,1 ,0 ,1 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,1};
float r3[] = {0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0};
float r4[] = {0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0};
float r5[] = {0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0};
float r6[] = {0 ,1 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,1 ,0 ,1 ,1 ,0};
float r7[] = {0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
float r8[] = {0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0};
float r9[] = {0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
float r10[] = {0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
float r11[] = {0 ,1 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
float r12[] = {0 ,1 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,1 ,0 ,1 ,0 ,0 ,0};
float r13[] = {0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
float r14[] = {0 ,1 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,1 ,0 ,0 ,0 ,0 ,0};
float r15[] = {1 ,0 ,1 ,1 ,1 ,0 ,0 ,1 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,1};
float r16[] = {1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
float r17[] = {0 ,1 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,0 ,1 ,0 ,0 ,1};
float r18[] = {1 ,1 ,1 ,0 ,1 ,1 ,0 ,1 ,1 ,0 ,0 ,0 ,1 ,0 ,1 ,1 ,1 ,1 ,0 ,1 ,1};
float r19[] = {1 ,0 ,1 ,1 ,1 ,0 ,0 ,1 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1};
float r20[] = {1 ,0 ,1 ,0 ,1 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,1};

  float *em_p[] = {r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20};
  struct Matrix em;
  em.row = 20;
  em.col = 21;
  em.mat = em_p;

  float r21[] = {-1, -2, 0, 0, 1, -1, 0, -1, -1, 0, 0, 0, 0, 1, 0};
  float r22[] = {-1, -1, -1, -1, -1, 1, 0, -1, 0, 0, 1, 0, 0, 0, 0};
  float r23[] = {1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, 0};
  float r24[] = {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1, 0, 0, 0};
  float r25[] = {0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 1};
  float r26[] = {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, -1};
  float *n1[] = {r21, r22, r23, r24, r25, r26};
  struct Matrix n;
  n.row = 6;
  n.col = 15;
  n.mat = n1;

  int rev_count = 5;
  int perm[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 18, 11, 15, 9, 17, 13, 19};

  row_perm_post(em, perm);
  // print_mat(em.mat, em.row, em.col);
  struct Matrix em_r2c = remove2Cycles(em, rev_count);
  // print_mat(em_r2c.mat, em_r2c.row, em_r2c.col);
  struct Matrix em_bc = bc(em_r2c, rev_count);
  // print_mat(em_bc.mat, em_bc.row, em_bc.col);
  struct Matrix *spaces = bin2real(em_bc, n);

  struct Matrix final = finalize(spaces, em_bc);

  print_mat_t(final.mat, final.row, final.col);

  return 0;
}
