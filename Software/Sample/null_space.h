/*
 * rref.h
 *
 *  Created on: Jul 21, 2018
 *      Author: Mahshid
 */
#include "matrix.h"

#ifndef SRC_NULLSPACE_H_
#define SRC_NULLSPACE_H_

struct Matrix null_space(struct Matrix m);
void print_mat(float **matrix, int n, int m);
void print_mat_t(float **matrix, int n, int m);

#endif /* SRC_RREF_H_ */
