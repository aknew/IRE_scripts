clear all

load AkTem% экспериментальные данные
load Temper% рассчетные данные

global u% вынужденная мера - делаем рассчетные значения глобальными чтобы использовать их в функции получения tFromIndex

tt = 54; % вервые 54 точки это мусор
Ta = Ta(tt:end, :);

r = 5; % 1/2 разницы между соседними центрами в одном ряду
dr = sqrt(10^2 - 5^2); % поправка на то что датчики стоят компактнее чем через диаметр, формула - 3 датчика стоят максимально компактно, значит, их центры образуют расносторонний треугольник,а значит разница между рядами это его высота/биссектриса/медиана

x = [-r, r, -2 * r, 0, 2 * r, -r, r];
y = [-dr, -dr, 0, 0, 0, dr, dr];

% первая решетка
% номера датчиков
chanels = [16 4 13 2 10 1 9];
% расчетное положение центра (числа из статьи, минус с допуском что 0,0 в статье это центр решетки)
xc = x(4) + 1;
yc = y(4) + 3.5;
filename = 'thermomap.gif';

% % вторая решетка
% % номера датчиков
% chanels = [7 6 5 8 15 12 14];
% % расчетное положение центра (числа из статьи, минус с допуском что 0,0 в статье это центр решетки)
% xc = x(4) + 3;
% yc = y(4) + 0.0;
% filename = 'thermomap2.gif';

Taa = Ta(:, chanels);

% определяем пределы температуры на графиках
limR = [min(min(u)) max(max(u))];
limExp = [min(min(Taa)) max(max(Taa))];
lim = [min(limR(1), limExp(1)) max(limR(2), limExp(2))];

[X Y] = meshgrid(-20:0.1:20, -20:0.1:20);
R = arrayfun(@xy2raidus, X, Y, xc, yc);
I = arrayfun(@raidus2index, R);

detectorsAsCircle = false; % как рисуем экспериментальные данные, true - в виде кругов размером с датчик и со значением аукстояркостной температуры на датчике, false - в виде поля где температура в центре датчика равна его показаниям, а остальное получено интерполированием
rDet = 4; % радиус детектора

figure;
rect = [1 1 900 300];
% frame = 20; % нарастание
% frame = 55; % что-то в районе максимума
% frame = 100; % спад
n = 1;
DelayTime = 0.4;
meanWindow = 10;
fn = size(Taa)(1);
frameNums = [1:meanWindow:fn];
frameNums = [1, frameNums];
% frameNums = [55];
WM='overwrite';

% зануляем углы
x_cor = [min(min(X)) max(max(X)) min(min(X)) max(max(X))];
y_cor = [min(min(Y)) min(min(Y)) max(max(Y)) max(max(Y))];
t_cor = [0 0 0 0];
firstFrame = true;

for frameNum = frameNums

    if frameNum + meanWindow - 1 > fn
        break
    end

    printf("process %d from %d\n", frameNum, fn);
    %% эксперимент
    t = sum(Taa(frameNum:frameNum + meanWindow - 1, :)) / meanWindow;
    T1 = NaN(size(X));

    if detectorsAsCircle

        for i = 1:length(x)
            II = getCircle(X, Y, x(i), y(i), rDet);
            T1(II) = t(i);
        end

    else
        T1 = griddata([x x_cor], [y y_cor], [t t_cor], X, Y, "v4");
    end

    subplot(1, 3, 1)
    colormap jet
    surf(X, Y, T1)
    shading flat
    caxis(lim)
    title("Experimental data")
    xlabel ("mm");
    ylabel ("mm");
    colorbar
    grid off
    view(2)
    axis square
    drawnow

    %% рассчет
    % Tr = zeros(size(I));
    % for i = frameNum:frameNum+meanWindow-1
    %     Tr = Tr + arrayfun(@tFromIndex, I, i);
    % end
    % Tr = Tr / 10;
    Tr = arrayfun(@tFromIndex, I, ceil(frameNum + meanWindow / 2));
    subplot(1, 3, 2)
    colormap jet
    surf(X, Y, Tr)
    shading flat
    caxis(lim)
    title("Calculated data")
    xlabel ("mm");
    ylabel ("mm");
    colorbar
    grid off
    view(2)
    axis square
    drawnow

    %% ошибка
    subplot(1, 3, 3)
    colormap jet
    r = arrayfun(@xy2raidus, x, y, xc, yc);
    i_err = raidus2index(r);
    t_err = t - tFromIndex(i_err, frameNum);
    Terr = NaN(size(X));

    if detectorsAsCircle

        for i = 1:length(x)
            II = getCircle(X, Y, x(i), y(i), rDet);
            Terr(II) = t_err(i);
        end

    else
        Terr = griddata([x x_cor], [y y_cor], [t_err t_cor], X, Y, "v4");
    end

    % t_int = zeros(size(x));
    % for i = 1:length(x)
    %     II = getCircle(X,Y,x(i),y(i),rDet);
    %     t_int(i) = mean(mean(Tr(II)));
    % end
    % Terr = griddata(x,y,t_int,X,Y, "v4");
    % title("Pseudoexperiment")

    surf(X, Y, Terr)
    shading flat
    caxis(lim)
    title("Error")
    xlabel ("mm");
    ylabel ("mm");
    colorbar
    grid off
    view(2)
    axis square
    drawnow

    set(gcf, 'Color', 'w', 'Position', rect);

    if firstFrame
        % пытаюсь обойти артифакты отрисовки самым простым способом - дропнуть первый кадр с артефактами
        firstFrame = false;
        continue
    end

    % getframe неадекватно работает на маке с ретиной, путается в пискелях и поинтах, чтобы оно нормально взяло данные пришлось вломиться в него и вручную умножить размеры на 2 (см. i2 - конец массива пикселей)
    [img map] = rgb2ind(frame2im(getframe(gcf)));
    imwrite(img, map, filename, 'gif', 'WriteMode', WM, 'DelayTime', DelayTime);
    WM='append';
end
