a = [1	1	-1	0	0	0	-1	0	0	0	0	0	0	0
1	0	0	0	0	0	0	0	0	0	0	0	0	0
0	1	0	0	0	0	0	0	0	0	0	0	0	0
0	0	1	0	0	0	0	0	0	0	0	0	0	0
0	0	0	1	0	-1	0	0	0	0	0	0	0	1
0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	0	0	1	-1	-2	0	0	0	0	-2	-1	-1
0	0	0	0	1	0	0	0	0	0	0	0	0	0
0	0	0	0	0	1	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0
0	-1	1	0	0	0	0	1	0	0	0	0	0	1
0	0	0	0	0	0	0	1	0	0	0	0	0	0
0	0	0	0	0	0	0	0	1	0	0	0	0	0
0	0	0	0	0	-1	-1	0	0	0	0	0	0	1
0	1	-1	0	0	1	0	0	1	1	0	-1	0	-1
0	0	0	0	0	0	0	0	0	1	0	0	0	0
0	0	0	0	0	0	0	0	0	0	1	0	0	0
0	0	0	0	0	0	0	0	0	0	0	1	0	0
0	0	0	0	0	0	0	0	0	0	0	0	1	0
0	0	0	0	0	0	0	0	0	0	0	0	0	1];

a = [0	0	0	0	0	0	-1	1	-1	-2	0	0	0	0	1	-1	0	-1	-1	0
-1	1	0	0	0	0	0	0	-1	-1	0	0	-1	-1	-1	1	0	-1	0	0
0	0	0	0	1	-1	0	0	1	0	0	0	0	0	0	0	0	0	0	-1
1	-1	-1	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
0	0	1	-1	0	0	0	0	0	0	-1	1	0	1	0	0	0	0	0	0
0	0	0	0	-1	1	0	0	0	1	1	-1	0	0	0	0	0	0	0	0];
a = null(a);


 tr = a';
 tr_rref = rref(tr);
 colp = colperm(tr_rref);
 init_form = tr_rref(:,colp);
 final = init_form';
 disp(final);
 