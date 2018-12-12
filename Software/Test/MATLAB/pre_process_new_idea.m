% sample1 after reduce
a = [
    0	0	0	1	-1	-2	0	0	0	1	-1	0	-1	-1	0
    1	0	0	0	-1	-1	0	-1	-1	-1	1	0	-1	0	0
    0	0	-1	0	1	0	0	0	0	0	0	0	0	0	-1
    -1	1	0	0	0	1	0	0	0	0	0	0	0	0	0
    0	-1	0	0	0	0	1	0	1	0	0	0	0	0	0
    0	0	1	0	0	1	-1	0	0	0	0	0	0	0	0
    ];
irrev = [0	0	0	0	1	1	0	1	1	1	1	1	1	1	1];

q = 15;
m = 6;
rev = length(irrev) - nnz(irrev);
% reconfigure
% pointer = 1;
% for i = 1: size(a,2)
%     if(irrev(i) == 0)
%         a = [a(:, 1:pointer-1) -a(:, pointer) a(:, pointer:size(a,2))];
%         pointer = pointer + 1;
%     end
%     pointer = pointer + 1;
% end

% nullspace
a_null = null(a);
disp(a * a_null);

tr = a_null';
tr_rref = rref(tr);
colp = colperm(tr_rref);
init_form = tr_rref(:,colp);
init = init_form';
% disp(init);
final = [init(1:q-m, :); zeros(rev,q-m); init(q-m+1:q,:)];

second_part = [zeros(q-m, rev);eye(rev);zeros(m, rev)];
final = [final , second_part];

% disp(final);

