R1 = [
    1	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	1	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	1	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	1	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	1	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	1	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	1	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	1	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	1	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	1	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	1	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	1	0
    0	0	0	0	0	0	0	0	0	0	0	0	0	1
    ];
R2 = [
    1     1     1     1     1    -1     0     1     0     1     0     0     0     0
     1    -1     1     0     1    -1     0     1     0     0     0     1     0     0
     0     1    -1     0    -1     1     0    -1     0     0     0     0     0     0
     1     2     0     0    -1     1     0     1     1     0     0     0     1     0
     1     0     1     1     1    -1     0     1     0     0     1     0     0     0
     1     0     1     0     1    -1     0     1     0     0     0     0     0     1
    ];

q = 15;
qsplit = 20;
m = 6;
numr = qsplit - m;%4

for p = qsplit - m + 1 : qsplit
    new_numr = numr;
    jneg = find(R2(1,:) < 0);
    jpos = find(R2(1,:) > 0);
    for k = 1:length(jneg)
        for l = 1:length(jpos)
            newr = or(R1(:,jneg(k)),R1(:,jpos(l)));
            % Minimum Number Of Zeros
            if((length(newr)-nnz(newr) + 1) < (qsplit - m - 1))
                continue;
            end
            
            % Adjacency Test
            adj = 1;
            r = 0;
            % disp(size(newr));
            while(adj && r < numr)
                r = r + 1;
                testr = or(newr, R1(:,r));
                if(jpos(l) ~=r && jneg(k) ~= r && all(testr == newr))
                    adj = 0;
                end
            end
            if(adj==1)
                new_numr = new_numr + 1;
                R1(:,new_numr) = newr;
                R2(:,new_numr) = R2(1,jpos(l)) * R2(:,jneg(k)) - R2(1,jneg(k)) * R2(:,jpos(l));
            end
        end
    end
    R1(:,jneg) = [];
    R2(:,jneg) = [];
    numr = new_numr - length(jneg);
    R1(p,:) = logical(R2(1,:));
    R2(1,:) = [];
    %disp(jneg);
    %disp(jpos);
end
disp(R1);
disp(R2);
