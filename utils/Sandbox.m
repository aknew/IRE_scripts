f = 100; % частота дискретизации
t = 0:1/f:150;
fs = [5 10 15 23 37]; % частоты присутствуюшие в сигнале

% сигнал
chanel = 0.5*sin(2*pi*fs(1)*t) + 1.5*sin(2*pi*fs(2)*t) + 5*sin(2*pi*fs(3)*t) + 2.5*sin(2*pi*fs(4)*t) + 0.75*sin(2*pi*fs(5)*t); 

subplot(221)
plot(t, chanel)
title("Сигнал as is")
axis([0, 1, -10, 10])

% спектр сигнала
spec = abs(fft(chanel));
spec = 2*spec(1:ceil((length(chanel)+1)/2));
freq = 0:f/length(t):f/2;
spec = spec/(2*length(freq));

subplot(222)
plot(freq, spec)
title("Спектр сигнала")


% фильтрованный сигнал
filtered = bandpass(chanel,[10 20], f);
subplot(223)
plot(t, filtered)
title("Сигнал as is")
axis([0, 1, -10, 10])

% спектр фильтрованного сигнала
spec1 = abs(fft(filtered));
spec1 = 2*spec1(1:ceil((length(filtered)+1)/2));
spec1 = spec1/(2*length(freq));

subplot(224)
plot(freq, spec1)
title("Спектр фильтрованного сигнала")