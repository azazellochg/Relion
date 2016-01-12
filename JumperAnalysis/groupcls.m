% groupcls.m
% last updated Oct 20, 2014
% Bingxin Shen

% To cite
% B. Chen, B. Shen, and J. Frank
% Particle migration analysis in iterative classification of cryo-EM single-particle data
% J. Struct. Biology, 2014

function all_dist_grps=groupcls(norder,A)

K=length(norder);
trshd=0.35; % between 1/4 to 1/2, based on experience

all_dist_grps=[];
ind_grp=0;
crt_dist_grps=(norder(K));

n=K;
while n>1
    b = ( A(n,n)+A(n-1,n-1)-A(n,n-1)-A(n-1,n) ) / ( A(n,n)+A(n-1,n-1)+A(n,n-1)+A(n-1,n) );
    if b<trshd
        crt_dist_grps=[crt_dist_grps, norder(n-1)];
        A(n-1,n-1)= A(n,n)+A(n-1,n-1)+A(n,n-1)+A(n-1,n);
        A(n-1,1:n-2)=A(n-1,1:n-2)+A(n,1:n-2);
        A(1:n-2,n-1)=A(1:n-2,n-1)+A(1:n-2,n-1);
    else
        ind_grp = ind_grp + 1;
        all_dist_grps{ind_grp} = crt_dist_grps;
        crt_dist_grps = [norder(n-1)];
    end
        n=n-1;
end

ind_grp = ind_grp + 1;
all_dist_grps{ind_grp} = crt_dist_grps;
display('classes are grouped as:')
for i=1:ind_grp
  display(['group ',num2str(i),' = class ',num2str(all_dist_grps{i})]);
end
