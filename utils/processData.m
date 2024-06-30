function processData(t, chanels, L, ch1, ch2, fileName)

% ======================================================================
%> @brief Обработка данных 
%> @param inputFilename имя файла, возвращает кортеж из вектора времени и каналов (матрица где в строках каналы, в столбцах - значения каналов)
%> @param chanels исходные данные
%> @param L ???
%> @param ch1 - первый канал для обработки
%> @param ch1 - второй канал для обработки
%> @param fileName - ядро названия
% ======================================================================

M1 = chanels(:, ch1);
M2 = chanels(:, ch2);
meanM1=mean(M1);
meanM2=mean(M2);

% % если нужно сохранять изначальные данные - расскоментить этот кусок кода
% figure(1)
% plot(t,M1,t,M2)
% title(["Experimental data, channels " int2str(ch1) " and "  int2str(ch2)]);
% f = [fileName "_original_" int2str(ch1) "x"  int2str(ch2) ".png"];
% [img map] = rgb2ind(frame2im(getframe(gcf)));
% imwrite(img, map, f, 'png', 'WriteMode', 'overwrite');

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
title(["Processed data, channels " int2str(ch1) " and " int2str(ch2)]);
f = [fileName "_processed_" int2str(ch1) "x"  int2str(ch2) ".png"];
[img map] = rgb2ind(frame2im(getframe(gcf)));
imwrite(img, map, f, 'png', 'WriteMode', 'overwrite');