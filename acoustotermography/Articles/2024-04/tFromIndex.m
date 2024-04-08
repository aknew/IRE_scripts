%% преобразование радиуса в индекс элемента рассчетного распределения
%% u прокинул через global т.к. иначе проблемы с запуском этой функции через arrayfun
function t = tFromIndex (i, frame)
    global u
    sz = size(u);
    i = min(i,sz(2));
    t = u(frame, i);
endfunction