import sympy

from functools import reduce
# from colperm import colperm


def pre_process(stoichio_matrix, reversibles):
    stoichio_matrix = sympy.Matrix(stoichio_matrix)
    M, Q = stoichio_matrix.shape

    rev = reduce((lambda y, x: y + 1 if x == 1 else y), reversibles, 0)
    print('Reversibles #: {}\n'.format(rev))
    q_split = Q + rev

    # R labels
    r_labels = {}
    for i in range(Q):
        r_labels['R%d' % i] = rev + i

    sympy.pprint(stoichio_matrix)
    print()

    ri = 0
    for idx, r in enumerate(reversibles):
        if r == 1:
            stoichio_matrix = \
                    stoichio_matrix.col_insert(0,
                                               -stoichio_matrix.col(idx + ri))
            ri += 1
            rev -= 1
            r_labels['R%dc' % idx] = rev

    print("Labels: {0}".format(r_labels))

    # we assume that following code put I on top of returned matrix
    print("{:-^50}\n".format("original"))
    sympy.pprint(stoichio_matrix)
    print()

    print("{:-^50}\n".format("kernel"))
    r_matrix = sympy.Matrix()
    for nb in stoichio_matrix.nullspace():
        r_matrix = r_matrix.col_insert(0, nb)
    # r_matrix = sympy.Matrix(nullspace(stoichio_matrix)).T.rref()[0].T

    r_matrix = r_matrix.T.rref()[0].T
    sympy.pprint(r_matrix)
    print()

    # print("{:-^50}\n".format("permutated"))
    # labels change in this phase
    # colperm(r_matrix)

    # Identity matrix spliting
    i_size = q_split - M
    print(i_size)
    sympy.pprint(r_matrix[0:i_size, :])
    sympy.pprint(r_matrix[i_size:, :])
