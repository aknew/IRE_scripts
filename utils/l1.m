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
fileName = "b2";
[t, ch] = readRigolBin([fileName ".bin"]);

chNumber = size(ch)(2);
for i = 1:chNumber
    for j = i: chNumber
        fprintf("Processing channels %d %d\n", i, j)
        processData(t, ch, 200, i, j, fileName);
    end
end