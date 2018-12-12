% sample1 after reduce
a = [
    -1	-2	0	0	1	-1	0	-1	-1	0	0	0	0	1	0
	-1	-1	-1	-1	-1	1	0	-1	0	0	1	0	0	0	0
	1	0	0	0	0	0	0	0	0	-1	0	0	-1	0	0
	0	1	0	0	0	0	0	0	0	0	-1	1	0	0	0
	0	0	0	1	0	0	0	0	0	0	0	-1	0	0	1
	0	1	0	0	0	0	0	0	0	0	0	0	1	0	-1
    ];
irrev = [1	1	1	1	1	1	1	1	1	1	0	0	0	0	0];

% reconfigure
pointer = 1;
for i = 1: size(a,2)
    if(irrev(i) == 0)
        a = [a(:, 1:pointer-1) -a(:, pointer) a(:, pointer:size(a,2))];
        pointer = pointer + 1;
    end
    pointer = pointer + 1;
end

% nullspace
a_null = null(a);

tr = a_null';
tr_rref = rref(tr);
colp = colperm(tr_rref);
init_form = tr_rref(:,colp);
final = init_form';
disp(final);

