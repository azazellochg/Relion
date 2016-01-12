% convergence.m
% last updated Oct 20, 2014
% Bingxin Shen

% To cite
% B. Chen, B. Shen, and J. Frank
% Particle migration analysis in iterative classification of cryo-EM single-particle data
% J. Struct. Biology, 2014


display(['......MaxProb, Loglikeli, Resolution vs iteration......'])
display(['......figures are plotting.....'])

Prob=[];
Likeli=[];
MedProb=[];
for k=1:K
    mean_Prob=[];
    med_Prob=[];
    mean_Likeli=[];
    for iter=stITER:ITER
        indClass=find(allClass(:,iter)==k);
        mean_Prob=[mean_Prob, mean(allMaxProb(indClass,iter))];
	med=median(allMaxProb(indClass,iter));
	med_Prob=[med_Prob, med(1)];
        mean_Likeli=[mean_Likeli, sum(allLogLikeli(indClass,iter))];
    end
    Prob=[Prob; mean_Prob]; 
    MedProb=[MedProb; med_Prob];
    Likeli=[Likeli; mean_Likeli];
end

allclassCnt=[];
for cls=1:K
    classCnt=[];
    for iter=stITER:ITER
        ind_temp = find(allClass(:,iter)==cls);
        classCnt = [classCnt, length(ind_temp)];
    end
    allclassCnt = [allclassCnt; classCnt];
end


    close(findobj('type','figure','name','performance'))
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4) scrsz(3)*0.7 scrsz(4)*0.5],'name','performance');
    for k=1:K
        M{k}=['class ',num2str(k)];
    end
    
    % Pmax: certainty of class assignment for each class
    set(0,'DefaultAxesColorOrder',[0 0 1; 0 0.9 0; 0.9 0 0; 0 0 0; 0 0.9 0.9; 0.9 0 0.9; ...
	    0.8 0.8 0; 0 0.7 0.5; 0.5 0 0.7; 0.5 0.5 0.5],...
	  'DefaultAxesLineStyleOrder','->|-->|-.>')
    subplot(2,2,1); hold on;
    plot(stITER:ITER,Prob','LineWidth',2,'MarkerSize',6);
    grid on;
    xlabel('iteration','FontSize',16);
    ylabel('mean of MaxProb','FontSize',16);
    legend(M,'fontsize',16,'Location', 'NortheastOutside')
  
    
    
    % likelihood: agreement of model for each class
    set(0,'DefaultAxesColorOrder',[0 0 1; 0 0.9 0; 0.9 0 0; 0 0 0; 0 0.9 0.9; 0.9 0 0.9; ...
	    0.8 0.8 0; 0 0.7 0.5; 0.5 0 0.7; 0.5 0.5 0.5],...
	  'DefaultAxesLineStyleOrder','-o|--o|-.o')
    subplot(2,2,3); hold on;
    plot(stITER:ITER,Likeli','-o','LineWidth',2,'MarkerSize',6);
    grid on;
    xlabel('iteration','FontSize',16);
    ylabel('Likelihood','FontSize',16);
    legend(M,'fontsize',16,'Location', 'NortheastOutside')
    

    set(0,'DefaultAxesColorOrder',[0 0 1; 0 0.9 0; 0.9 0 0; 0 0 0; 0 0.9 0.9; 0.9 0 0.9; ...
	    0.8 0.8 0; 0 0.7 0.5; 0.5 0 0.7; 0.5 0.5 0.5],...
	  'DefaultAxesLineStyleOrder','-o|--o|-.o')
    subplot(2,2,2); hold on;  
    grid on;
    xlabel('iteration','FontSize',16);
    ylabel('number of particles','FontSize',16);
    plot(stITER:ITER, allclassCnt','LineWidth',2,'MarkerSize',6);
    legend(M,'fontsize',16,'Location', 'NortheastOutside')



    set(0,'DefaultAxesColorOrder',[0 0 1; 0 0.9 0; 0.9 0 0; 0 0 0; 0 0.9 0.9; 0.9 0 0.9; ...
	    0.8 0.8 0; 0 0.7 0.5; 0.5 0 0.7; 0.5 0.5 0.5],...
	  'DefaultAxesLineStyleOrder','-*|--*|-.*')
    subplot(2,2,4); hold on;
    plot(stITER:ITER,allResolution(:,stITER:ITER),'LineWidth',2,'MarkerSize',6);
    grid on;
    xlabel('iteration','FontSize',16');
    ylabel('resolution (A)','FontSize',16);
    legend(M,'fontsize',16,'Location', 'NortheastOutside')
    



%==========
res=1./allResolution;

[r,c]=size(Prob);
incProb=Prob(:,2:c)./Prob(:,1:c-1)-1;
incLikeli=Likeli(:,2:c)./Likeli(:,1:c-1)-1;
incRes=res(:,2:c)./res(:,1:c-1)-1;

display(' ')
display('Please enter a percentage to quantify the convergence. ')
a=[];
if isempty(a)
    a = input(['(default values 10) '], 's');
end
if isempty(a)
    a='10';
end
aa=str2num(a)/100;
display(' ')

close(findobj('type','figure','name','fluc'))

figure('Position',[1 scrsz(4) scrsz(3)*0.7 scrsz(4)*0.5],'name','fluc');
    set(0,'DefaultAxesColorOrder',[0 0 1; 0 0.9 0; 0.9 0 0; 0 0 0; 0 0.9 0.9; 0.9 0 0.9; ...
	    0.8 0.8 0; 0 0.7 0.5; 0.5 0 0.7; 0.5 0.5 0.5],...
	  'DefaultAxesLineStyleOrder','-|--|-')
subplot(2,1,1)
plot(stITER+1:ITER,incProb'*100, 'LineWidth',2);
hold on;
plot([stITER+1  ITER],[aa aa]*100,'--', 'LineWidth',1)
plot([stITER+1  ITER],[-aa -aa]*100,'--', 'LineWidth',1)
plot([stITER+1  ITER],[0 0],'--', 'LineWidth',1)
ylabel('percentage (%)','FontSize',16)
xlabel('iteration','FontSize',16)
legend(M,'fontsize',16,'Location', 'NortheastOutside')

subplot(2,1,2)
plot(stITER+1:ITER,incProb'*100, 'LineWidth',2);
hold on;
plot([stITER+1  ITER],[aa aa]*100,'--', 'LineWidth',1)
plot([stITER+1  ITER],[-aa -aa]*100,'--', 'LineWidth',1)
plot([stITER+1  ITER],[0 0],'--', 'LineWidth',1)
ylabel('percentage (%)','FontSize',16)
ylim([-aa aa]*150)
xlabel('iteration','FontSize',16)
legend(M,'fontsize',16,'Location', 'NortheastOutside')

%====
display(' ')
display('Please enter the number of iterations to quantify the convergence. ')
b=[];
if isempty(b)
    b = input(['(suggested values 5) '], 's');
end
if isempty(b)
   b='5';
end
bb=str2num(b);


%==============

[cvgITER,cvgiter]=convergence_check(incProb, incProb, aa, bb,stITER, ITER, K);

display(' ')
if ITER-cvgITER<(bb-1) 
    display(['The general performance of iteration ',num2str(stITER), ' to ',num2str(ITER), ' did not converge within ', a,'% fluctuation with ', b, ' consetitive iterations.'])
else
    display(['The general performance converged roughly within ', a,'% fluctuation with ', b, ' consecutive iterations from iteration ', num2str(cvgITER),'.'])
end
for k=1:K
  if ITER-cvgiter(k)<(bb-1) 
      display(['Class ',num2str(k), ' did not converge.'])
  else
      display(['Class ',num2str(k), ' converged from iteration ', num2str(cvgiter(k)),'.'])
  end
end



display(' ')
display('.........Do you want to close the figures just generated? .........')
a=[];
if isempty(a)
    a = input(['(y|n): '], 's');
end
if a=='y'
    close(findobj('type','figure','name','performance'))
    close(findobj('type','figure','name','fluc'))
    close(findobj('type','figure','name','convergence_check'))
end
