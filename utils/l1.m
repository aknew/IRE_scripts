% dt = 1/60000000;
% size = 240000000/4;
% t = (0:size-1)*dt;
% T=0.1;
% M1=0;
% for i=1:10;
%     M1(1+(i-1)*100:50+(i-1)*100)=1;
%     M1(51+(i-1)*100:100+(i-1)*100)=-1;
% end;
% tau=2;
% M2=0;
% M2(1:tau)=-1;
% for ii=1:9;
%     M2(tau+1+(ii-1)*100:tau+50+(ii-1)*100)=1;
%     M2(tau+51+(ii-1)*100:tau+100+(ii-1)*100)=-1;
% end;
% M2(tau+901:tau+950)=1;
% M2(1000-tau+1:1000)=-1;

%% имя файла с данными
fileName = "b2.bin";
[t, ch] = readRigolBin(fileName);

%% разбивка на старые каналы, если их меньше 4 соотвествующие строки нужно закомментить
a1 = ch(:,1);
a2 = ch(:,2);
a3 = ch(:,3);
a4 = ch(:,4);

% начало фильтрации
fs = 1/(t(2)-t(1)); % частота дискретизации
f = [1e6 1.5e6];

a1 = bandpass(a1, f, fs);
a2 = bandpass(a2, f, fs);
a3 = bandpass(a3, f, fs);
a4 = bandpass(a4, f, fs);
% конец фильтрации

M1=a4; %sin(2*pi*t/T);
M2=a4; %sin(2*pi*t/T+pi);
meanM1=mean(M1);
meanM2=mean(M2);
% figure(1)
% plot(t,M1,t,M2)
L=200;
R=zeros(2*L+1,1);
R(L+1)=mean(M1.*M2);
for k=1:L
    T1=M1(k+1:end);
    T2=M2(1:end-k);
    x=mean(T1.*T2);
    R(L+k+1)=x;
end;
for k=1:L
    T1=M1(1:end-k);
    T2=M2(k+1:end);
    x=mean(T1.*T2);
    R(L+1-k)=x;
end;
r=(R-meanM1*meanM2);
figure(2)
plot(r)