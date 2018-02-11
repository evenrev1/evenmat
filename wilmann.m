function [z,R,U,muU,sigmaU]=wilmann(x,y)
% WILMANN       Wilcoxon-Mann-Whitney rank-sum test
%
% [z,R,U,muU,sigmaU] = wilmann(x,y)
%
% x,y   = vectors of two batches of data
% 
% z     = standarized departure (standard gaussian)
% R     = two element vector of the batches' sums of ranks
% U     = two element vector of the Mann-Whitney U statistcis
% muU,
% sigmaU= the Gaussian null-distribution parameters
%
% Use the table of Left-Tail Cumulative Probabilities for the Standard
% Gaussian Distribution (Wilks, Table B.1) to find the p-value associated
% with the observations.
%
% REFERENCES: Wilks p.138-142 (section 5.3.1)
%
% See also RANG ZTEST

n=[length(x) length(y)];                % batchsizes
if any(n<=10)
  warning('The Gaussian null distribution-approximatin');
  warning('requires more than 10 samples in each batch!');
end

i1=1:n(1);  i2=n(1)+(1:n(2));           % batch-identifiers 
comb=[x(:);y(:)];                       % tile batches 

[rank,sort,index]=rang(comb);           % sort, find rank and indextable

R(1)=sum(rank(i1));                     % batch1's sum of ranks 
R(2)=sum(rank(i2));                     % batch2's sum of ranks

U=ustat(R,n);                           % Mann-Whitney U-statistics

[muU,sigmaU]=unullgauss(n);             % null-distribution parameters

z=(min(U)-muU)/sigmaU;                  % standardised departure from the
                                        % null distribution

if nargout==0
  fig wilmann 4;clf;
  
  h1=plot(rank(i1),comb(i1),'r+',rank(i2),comb(i2),'b.');
  grid;
  title('Wilcoxon-Mann-Whitney rank-sum test');
  xlabel('Rank');
  ylabel('Datavalue');
  legend('x','y',0);
  a=axis;
  h=text(a(1)+0.025*(a(2)-a(1)),a(4)-0.060*(a(4)-a(3)),...
         strcat('R_1 =',num2str(R(1),'%4.2f'),'   R_2 =',...
                num2str(R(2),'%4.2f')));
  set(h,'FontSize',10)
  h=text(a(1)+0.025*(a(2)-a(1)),a(4)-0.120*(a(4)-a(3)),...
         strcat('U_1 =',num2str(U(1),'%4.2f'),'   U_2 =',...
                num2str(U(2),'%4.2f')));
  set(h,'FontSize',10)
  h=text(a(1)+0.025*(a(2)-a(1)),a(4)-0.180*(a(4)-a(3)),...
         strcat('\mu_U =',num2str(muU,'%4.2f'),...
                '   \sigma_U =',num2str(sigmaU,'%4.2f')));
  set(h,'FontSize',10)
  h=text(a(1)+0.025*(a(2)-a(1)),a(4)-0.240*(a(4)-a(3)),...
         strcat('z =',num2str(z,'%4.2f')));
  set(h,'FontSize',10)
end
                                        
%--------------------------------------------------------------
function [muU,sigmaU]=unullgauss(n)     
% Gaussian distribution parameters for Mann-Whitney U statistics
muU     = n(1)*n(2)/2;
sigmaU  = sqrt(muU*(n(1)+n(2)+1)/6);
%--------------------------------------------------------------
function U=ustat(R,n)
% Mann-Whitney U-statistics
U=R-n.*(n+1)/2;
