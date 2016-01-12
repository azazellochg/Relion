% loadRELIONdata.m
% last updated Oct 20, 2014
% Bingxin Shen

% To cite
% B. Chen, B. Shen, and J. Frank
% Particle migration analysis in iterative classification of cryo-EM single-particle data
% J. Struct. Biology, 2014
% modified by Gabor Papai, 2016

clear all;
close all;
clc;

%=============interface with user=====================
display('=====loading data======')
display('......Please choose any RELION output star file as template to load data...... ')
[filename,filepath,fileind] = uigetfile('./*it000_model.star');
Lhd=[];
for ll=1:length(filename)-3
  if filename(ll:ll+3)=='_it0' 
    Lhd=[Lhd, ll-1];
  elseif filename(ll:ll+2)=='_ct'
    Lhd=[Lhd, ll-1];
  end
end
filehead=filename(1:min(Lhd));

outputfile= strcat(filepath,'all_data.mat');

fid = fopen(outputfile);
if fid ~= -1
   display('MAT file record found.')
    display(['data is loading from [', outputfile,']'])
    load(outputfile);
    K=max(allClass(:,2));
    display(['total class number = ', num2str(K)])
    display(['starting iteration = ', num2str(stITER)])
    display(['maximum iteration  = ', num2str(ITER)])
    [Pnum,i]=size(allClass);
    display([num2str(Pnum),' particles'])
    display(['   '])
    
   a=[];
    if isempty(a)
        a = input(['Do you want to RELOAD all the data? (y|n):  '], 's');
    end
  if a=='n'      
      return
  end
else

  outputfile= strcat(filepath,'all_data.mat');
  fid2 = fopen(outputfile);
  if fid2 ~= -1
   display('MAT file record found.')
    display(['data is loading from [', outputfile,']'])
    load(outputfile);
    K=max(allClass(:,2));
    display(['total class number = ', num2str(K)])
    display(['starting iteration = ', num2str(stITER)])
    display(['maximum iteration  = ', num2str(ITER)])
    [Pnum,i]=size(allClass);
    display([num2str(Pnum),' particles'])
    display(['   '])
    
   a=[];
    if isempty(a)
        a = input(['Do you want to RELOAD all the data? (y|n):  '], 's');
    end
  if a=='n'      
      return
  end
  end

end   


%============loading relion outputs=============
ct=[];
display('Please load the files')
a=[];
stITER=1;
if isempty(a)
    a = input(['from iteration: '], 's');
end
stITER=str2num(a);
a=[];
if isempty(a)
    a = input(['to iteration: '], 's');
end
ITER=str2num(a);
display(' ')

display(['......data is loading......'])


%=======loading=========
resolution=[];
allResolution=[];

allClass=[];     % matrix containing class assignment from all iterations
         % using allClass(p,iter) to access the info of p-th particle at iteration iter
allLogLikeli=[]; % matrix containing _rlnMaxValueProbDistribution from all iterations
         % using allLogLikeli(p,iter) to access the info of p-th particle at iteration iter
allMaxProb=[];   % matrix containing _rlnMaxValueProbDistribution from all iterations
         % using allMaxProb(p,iter) to access the info of p-th particle at iteration iter


for iter=stITER:ITER

  filemodel=[filepath,'/',filehead,ct,'_it',num2str(iter,'%03i'),'_model.star'];

  [fid1, errmsg1] = fopen(filemodel);
  fid=fid1;
  if fid == -1
    if iter>1
      cttmp=['_ct',num2str(iter-1)]; % look for the ct file if filemodel does not exist
      filemodelct=[filepath,'/',filehead,cttmp,'_it',num2str(iter,'%03i'),'_model.star'];
      [fid1, errmsg1ct] = fopen(filemodelct);
      fidct=fid1;
      if fidct == -1 % if ct file does not exist either, return with error
          cttmp=['_ct',num2str(iter-2)]; % look for the ct file if filemodel does not exist
            filemodelct2=[filepath,'/',filehead,cttmp,'_it',num2str(iter,'%03i'),'_model.star'];
            [fid1, errmsg1ct2] = fopen(filemodelct2);
        if fid1==-1
            disp(errmsg1)
            display(['relion file ',filemodel,' not found.'])
            disp(errmsg1ct)
            display(['relion file ',filemodelct,' not found.'])
            disp(errmsg1ct2)
            display(['relion file ',filemodelct2,' not found.'])
            return
        else
        ct=cttmp;
        end
      else % if ct file exists, update ct string
        ct=cttmp;
      end
    end
  end   

  Cmodel = textscan(fid1,'%s%s%f%f%f%f%f%f%f%f',1200);
  resolution(iter)=str2num(Cmodel{2}{5});  
  ind_blk_st=[];
   K=str2num(Cmodel{2}{11});
  for k=1:K
    blocknm=['data_model_class_',num2str(k)];
    ind_blk_st=[ind_blk_st, find(strcmp(blocknm,Cmodel{1}))];
  end
  ind_mat_st=find(strcmp('0',Cmodel{1}));
  mat_length=ind_blk_st(2)-ind_mat_st(1);
  hd_length =ind_mat_st(1)-ind_blk_st(1)-2;
  hd_blk=[];
  for h=1:hd_length
    hd_blk{h}=Cmodel{1}{ind_blk_st(1)+1+h};
  end
  SpectralIndex=[0:mat_length-1];  
  Isnr=find(strcmp('_rlnSsnrMap',hd_blk));
  Ires=find(strcmp('_rlnAngstromResolution',hd_blk));
    if length(Ires)==0
      Ires=find(strcmp('_rlnResolution',hd_blk));
    end
  Itau=find(strcmp('_rlnReferenceTau2',hd_blk));
  Ifsc=find(strcmp('_rlnGoldStandardFsc',hd_blk));

  for k=1:K
    if Ires>2
      tmpReso=Cmodel{Ires}(ind_mat_st(k):ind_mat_st(k)+mat_length-1);
    else
      tmpReso1=Cmodel{Ires}(ind_mat_st(k):ind_mat_st(k)+mat_length-1);
      LL=length(tmpReso1); tmpReso=[];
      for ll=1:LL
        tmpReso(ll,1)=str2num(tmpReso1{ll});
      end
    end
    tmpTau2=Cmodel{Itau}(ind_mat_st(k):ind_mat_st(k)+mat_length-1);
    tmpSsnr=Cmodel{Isnr}(ind_mat_st(k):ind_mat_st(k)+mat_length-1);
    tmpind=find(tmpSsnr>=1);
    
    if Ires>2
      if length(tmpind)>1
      tmpind=tmpind(length(tmpind));
      allResolution(k,iter)=tmpReso(tmpind);
      else
      allResolution(k,iter)=tmpReso(1);
      end
    else
      if length(tmpind)>1
      tmpind=tmpind(length(tmpind));
      allResolution(k,iter)=1/tmpReso(tmpind);
      else
      allResolution(k,iter)=1/tmpReso(1);
      end
    end
  end


 filedata=[filepath,'/',filehead,ct,'_it',num2str(iter,'%03i'),'_data.star'];
  [fid2, errmsg2] = fopen(filedata);
  if fid2 == -1
    disp(errmsg2)
    display(['relion file ',filedata,' not found.'])
    return
  end   


  NumCols=40;
  Cdatahd = textscan(fid2,'%s%s',NumCols);
  tmpNum=0;
  for ll=1:NumCols
    if Cdatahd{1}{ll}(1)=='_'
      tmpNum=tmpNum+1;
    end
  end
  NumCols=tmpNum;
  Iimg=find(strcmp('_rlnImageName',Cdatahd{1}))-2;
  Imic=find(strcmp('_rlnMicrographName',Cdatahd{1}))-2;
  Igru=find(strcmp('_rlnGroupName',Cdatahd{1}))-2;
  Icls=find(strcmp('_rlnClassNumber',Cdatahd{1}))-2;
  Ilog=find(strcmp('_rlnLogLikeliContribution',Cdatahd{1}))-2;
  Ipro=find(strcmp('_rlnMaxValueProbDistribution',Cdatahd{1}))-2;

  [fid2, errmsg2] = fopen(filedata);
  Cdatahd = textscan(fid2,'%s%s',NumCols+2);

  FormatString=repmat('%f',1,NumCols); 
  FormatString([Iimg*2,Imic*2,Igru*2])='s';
  Cdata = textscan(fid2,FormatString);

  allClass(:,iter)=Cdata{Icls};
  allLogLikeli(:,iter)=Cdata{Ilog};
  allMaxProb(:,iter)=Cdata{Ipro};

end

[Pnum,i]=size(allClass);

save(outputfile);

display(['data saved as [', outputfile,']'])
display(['total class number = ', num2str(K)])
display(['starting iteration = ', num2str(stITER)])
display(['maximum iteration  = ', num2str(ITER)])
display([num2str(Pnum),' particles'])
display(['======data loading ended======  '])
