%% преобразование координат в расстояние от центра
%% x,y - координаты точки для которой ищется расстояние
%% xc, yc - координаты центра
function r = xy2raidus (x, y, xc, yc)
    dx = x - xc;
    dy = y - yc;
    r = sqrt(dx^2 + dy^2);
endfunction