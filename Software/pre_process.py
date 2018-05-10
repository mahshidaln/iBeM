import sympy

from functools import reduce
# from colperm import colperm


def pre_process(stoichio_matrix, reversibles):
    stoichio_matrix = sympy.Matrix(stoichio_matrix)
    M, Q = stoichio_matrix.shape

    if stoichio_matrix.rank() != M:
        print("invalid rank %d != %d" % (stoichio_matrix.rank(), M))
        return

    print("{:-^50}\n".format("original"))
    sympy.pprint(stoichio_matrix)
    print()

    print("{:-^50}\n".format("kernel"))
    r_matrix = sympy.Matrix()
    for nb in stoichio_matrix.nullspace():
        r_matrix = r_matrix.col_insert(0, nb)

    r_matrix = r_matrix.T.rref()[0].T
    sympy.pprint(r_matrix)
    print()


    rev = reduce((lambda y, x: y + 1 if x == 1 else y), reversibles, 0)
    print('Reversibles #: {}\n'.format(rev))
    q_split = Q + rev

    # insert rev cols
    for i in range(rev):
        r_matrix = r_matrix.col_insert(r_matrix.shape[1], sympy.zeros(Q, 1))
        r_matrix = r_matrix.row_insert(Q - M + i, sympy.zeros(1, r_matrix.shape[1]))
        r_matrix[Q - M + i, r_matrix.shape[1] - 1] = 1
    sympy.pprint(r_matrix)
    print()

    r_labels = {} # R labels
    idx = 0 # row index
    f_idx = 0 # forward reaction
    b_idx = 0 # backward reaction
    r_idx = 0 # reversible reaction counter

    for _ in range(Q - M):
        r_labels['R%d' % (f_idx + 1)] = idx
        idx += 1
        f_idx += 1

    for b_idx, r in enumerate(reversibles):
        if r == 1:
            r_labels['R%dc' % (b_idx + 1)] = idx
            idx += 1
            if b_idx >= Q - M:
                r_matrix[rev + b_idx, Q - M + r_idx] = 1
            r_idx += 1

    for _ in range(M):
        r_labels['R%d' % (f_idx + 1)] = idx
        idx += 1
        f_idx += 1

    print("Labels: {0}".format(r_labels))

    print("{:-^50}\n".format("result"))
    sympy.pprint(r_matrix)
    print()

    # Identity matrix spliting
    i_size = q_split - M
    sympy.pprint(r_matrix[0:i_size, :])
    sympy.pprint(r_matrix[i_size:, :])
