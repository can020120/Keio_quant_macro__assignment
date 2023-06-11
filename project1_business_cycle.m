
clc
clear all
close all


f = fred
startdate = '01/01/1995';
enddate = '01/01/2022';

%%
GRC= fetch(f,'CLVMNACSCAB1GQEL',startdate,enddate) 

JPN= fetch(f,'JPNRGDPEXP',startdate,enddate)      %Real Gross Domestic Product for Japan(JPNRGDPEXP)
gr = log(GRC.Data(:,2));
jp = log(JPN.Data(:,2));
q = GRC.Data(:,1);
T = size(gr,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

grGDP = A\gr;
jpPCE = A\jp;

% detrended GDP
grtilde = gr-grGDP;
jptilde = jp-jpPCE;

% plot detrended GDP
dates = 1995:1/4:2022.1/4; zerovec = zeros(size(gr));
figure
title('Detrended log(real GDP) 1995Q1-2022Q4'); hold on
plot(q, grtilde,'b', q, jptilde,'r')
datetick('x', 'yyyy-qq')
legend({'JAPAN','GREECE'},'Location','southwest')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
ysd_gr = std(grtilde)*100;
ysd_jp = std(jptilde)*100;
corryc = corrcoef(grtilde(1:T),jptilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(ysd_gr),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Greece: ', num2str(ysd_jp),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP for Japan and detrended log real GDP for Greece: ', num2str(corryc),'.']);



