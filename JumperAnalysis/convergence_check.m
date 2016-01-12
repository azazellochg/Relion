% convergence_check.m
% last updated Oct 20, 2014
% Bingxin Shen

% To cite
% B. Chen, B. Shen, and J. Frank
% Particle migration analysis in iterative classification of cryo-EM single-particle data
% J. Struct. Biology, 2014

function [cvgITER, cvgiter]=convergence_check(vec1, vec2, aa, bb,stITER, ITER, K)

%==============
IND1=[];
IND2=[];
for k=1:K
    tmp1=find(vec1(k,:)<=aa)+stITER;
    tmp2=find(vec2(k,:)<=aa)+stITER;

    len1=length(tmp1);
    len2=length(tmp2);

    if tmp1(end)==ITER
	indNC1=find((ITER-len1+1:ITER)-tmp1);
	if length(indNC1)==0 
	    ind1=2+stITER;
	elseif indNC1(end)+1>len1
	    ind1=ITER;
	else
	    ind1=tmp1(indNC1(end)+1);
	end
    else
	ind1=ITER;
    end
    IND1=[IND1,ind1];

    if tmp2(end)==ITER
	indNC2=find((ITER-len2+1:ITER)-tmp2);
	if length(indNC2)==0
	    ind2=2+stITER;
	elseif indNC2(end)+1>len2
	    ind2=ITER;
	else
	    ind2=tmp2(indNC2(end)+1);
	end
    else
	ind2=ITER;
    end
    IND2=[IND2,ind2];
end


cvgITER=max(max(IND1,IND2));
cvgiter=max(IND1,IND2);
