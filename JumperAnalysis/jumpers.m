% jumpers.m
% last updated Oct 20, 2014
% Bingxin Shen

% To cite
% B. Chen, B. Shen, and J. Frank
% Particle migration analysis in iterative classification of cryo-EM single-particle data
% J. Struct. Biology, 2014

display('..........Particle experiences are checking...........')
display('Please enter the iteration numbers that you want to check these particle experience. ')
if cvgITER<ITER
display(['Suggest to check from iteration ',num2str(cvgITER),' to iteration ',num2str(ITER)])
end
a=[];
if isempty(a)
    a = input(['From iteration: '], 's');
end
aa=str2num(a);
cc=aa;
a=[];
if isempty(a)
    a = input(['to iteration: '], 's');
end
bb=str2num(a);
if aa>bb | aa<stITER | bb>ITER
    display('Invalid inputs. ')
    aa=min(max(stITER,aa),ITER);
    bb=min(max(stITER,bb),ITER);
    if aa>bb
        tmp=aa;
        aa=bb;
        bb=tmp;
    end
    display(['Corrected as from iteration ',num2str(aa),' to ',num2str(bb)])
end

iter=cc;   % group particles according to the class assignment in iteration iter
stI=aa; % check the particle experience from iteration stITER
edI=bb; %                               to iteration edITER

% ======================================
mtmp=1;
alln=[];
for k=1:K
    ind_tmp=[];
    
    ind_tmp=[ind_tmp; find(allClass(:,iter)==k)]; 
    temp=reshape(allClass(ind_tmp,stI:edI),1,[]);
    [n,xout] = hist(temp,1:K);
    alln=[alln; n];
    mtmp=max([n,mtmp]);

end


%============
allnnorm=[];
for k=1:K
  allnnorm=[allnnorm; alln(k,:)/sum(alln(k,:))];
end

figure('Position',[1 scrsz(4) scrsz(3)*0.7 scrsz(4)],'name','jettran');
subplot(2,2,1);
 for k=1:K
    Mx{k}=num2str(k);
    My{K-k+1}=num2str(k);
  end
ntemp=zeros(K+1,K+1);
ntemp(1:K,1:K)=allnnorm;
h = pcolor(0:K, K:-1:0',ntemp); 
set(h, 'EdgeColor', 'none');
colormap(copper);
hold on
colorbar;
 set(gca,'XTick',(1:K)-0.5);
 set(gca,'XTickLabel',Mx,'FontSize',16);
 set(gca,'YTick',(1:K)-0.5);
 set(gca,'YTickLabel',My,'FontSize',16);
    title(['percentage experience from iter', stI,' to iter',edI] ,'FontSize',16);

tmpn=diag(allnnorm);
[B,norder]=sort(tmpn,'descend');
newnnorm=[];
for i=1:K
  for j=1:K
    newnnorm(i,j)=allnnorm(norder(i),norder(j));
  end
end
alltmp=(newnnorm+newnnorm')/2;
alltmp(find(alltmp<0.07))=0;
r = symamd(alltmp);
norder=norder(r);
newnnorm=[];
for i=1:K
  for j=1:K
    newnnorm(i,j)=allnnorm(norder(i),norder(j));
  end
end
subplot(2,2,2);
 for k=1:K
    Mx{k}=num2str(norder(k));
    My{K-k+1}=num2str(norder(k));
  end
ntemp=zeros(K+1,K+1);
ntemp(1:K,1:K)=newnnorm;
h = pcolor(0:K, K:-1:0',ntemp); 
set(h, 'EdgeColor', 'none');
colormap(copper);
hold on
colorbar;
 set(gca,'XTick',(1:K)-0.5);
 set(gca,'XTickLabel',Mx,'FontSize',16);
 set(gca,'YTick',(1:K)-0.5);
 set(gca,'YTickLabel',My,'FontSize',16);
%============


subplot(2,2,3);
 for k=1:K
    Mx{k}=num2str(k);My{K-k+1}=num2str(k);
  end
ntemp=zeros(K+1,K+1);
ntemp(1:K,1:K)=alln/((bb-aa));
h = pcolor(0:K, K:-1:0',ntemp); 
set(h, 'EdgeColor', 'none');
colormap(copper);
hold on
colorbar;
 set(gca,'XTick',(1:K)-0.5);
 set(gca,'XTickLabel',Mx,'FontSize',16);
 set(gca,'YTick',(1:K)-0.5);
 set(gca,'YTickLabel',My,'FontSize',16);
    title(['average experience from iter', stI,' to iter',edI] ,'FontSize',16);

newnn=[];
for i=1:K
  for j=1:K
    newnn(i,j)=alln(norder(i),norder(j))/(bb-aa);
  end
end
subplot(2,2,4);
 for k=1:K
    Mx{k}=num2str(norder(k));My{K-k+1}=num2str(norder(k));
  end
ntemp=zeros(K+1,K+1);
ntemp(1:K,1:K)=newnn;
h = pcolor(0:K, K:-1:0',ntemp); 
set(h, 'EdgeColor', 'none');
colormap(copper);
hold on
colorbar;
 set(gca,'XTick',(1:K)-0.5);
 set(gca,'XTickLabel',Mx,'FontSize',16);
 set(gca,'YTick',(1:K)-0.5);
 set(gca,'YTickLabel',My,'FontSize',16);



%============
close(findobj('type','figure','name','experience'))
   scrsz = get(0,'ScreenSize');
   figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)*0.5],'name','experience');
   subplot(1,2,1);
   h=bar(alln/(bb-aa));
    colorset=[0.1 0.1 1; 0.1 0.9 0.1; 0.9 0.1 0.1; 0.3 0.3 0.3; 0 0.9 0.9; 0.9 0 0.9; ...
	    0.8 0.8 0; 0 0.7 0.5; 0.5 0 0.7; 0.8 0.8 0.8];
    for k=1:K
    tmpc=mod(k,10);
    if tmpc==0
      tmpc=10;
    end
    set(h(k),'facecolor',colorset(tmpc,:)) 
    end
   ylabel('number of particles','FontSize',16);
   rfIter=num2str(iter,'%02d');
   stIter=num2str(stI,'%02d');
   nxIter=num2str(edI,'%02d');
   M1=[];
   for k=1:K
        M1{k}=['class',num2str(k),'_it',rfIter];
   end
   M2=[];
   for k=1:K
        M2{k}=['class',num2str(k)];
   end
    title(['experience from iter', stIter,' to iter',nxIter] ,'FontSize',16);
   set(gca,'XTick',1:K);
   set(gca,'XTickLabel',M1,'FontSize',16);
   legend(M2,'FontSize',16,'Location', 'NortheastOutside')

    subplot(1,2,2);
    groups=groupcls(norder,newnn);
    allnorm=alln/(bb-aa);
    allnorm(K+1,K+1)=0;
    allgroup1=[];
    [r,R]=size(groups);
    allnorm;
    for i=1:K
      for j=1:R
	  allgroup1(i,j)=sum(allnorm(i,groups{j}));
      end
    end
    allgroup1(K+1,1)=0;
    for i=1:R
      for j=1:R
	  allgroup(i,j)=sum(allgroup1(groups{i},j));
      end
    end
    h=bar(allgroup);
    colorset=[0.1 0.1 1; 0.1 0.9 0.1; 0.9 0.1 0.1; 0.3 0.3 0.3; 0 0.9 0.9; 0.9 0 0.9; ...
	    0.8 0.8 0; 0 0.7 0.5; 0.5 0 0.7; 0.8 0.8 0.8];
    for k=1:R
    tmpc=mod(k,10);
    if tmpc==0
      tmpc=10;
    end
    set(h(k),'facecolor',colorset(tmpc,:)) 
    end
   ylabel('number of particles','FontSize',16);
   rfIter=num2str(iter,'%02d');
   stIter=num2str(stI,'%02d');
   nxIter=num2str(edI,'%02d');
   M1=[];
   for k=1:R
        M1{k}=['group',num2str(k)];
   end
    M2=[];
   for k=1:R
        M2{k}=['group',num2str(k)];
   end
   set(gca,'XTick',1:R);
   set(gca,'XTickLabel',M1,'FontSize',16);
   legend(M2,'FontSize',16,'Location', 'NortheastOutside')
%============

display(' ')
display('.........Do you want to close the experience figure just generated? .........')
a=[];
if isempty(a)
    a = input(['(y|n): '], 's');
end
if a=='y'
    close(findobj('type','figure','name','experience'))
 close(findobj('type','figure','name','jettran'))
end
