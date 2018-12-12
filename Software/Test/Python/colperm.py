def colperm(a):
    _, coln = a.shape

    zero_count = {}

    for i in range(coln):
        z = 0
        col = a.col(i)

        for j in col:
            if j == 0:
                z += 1

        zero_count[i] = z

    return [x[0] for x in
            sorted(zero_count.items(), key=lambda x: x[1], reverse=True)]
