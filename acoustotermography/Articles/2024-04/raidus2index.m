%% преобразование радиуса в индекс элемента рассчетного распределения 
function i = raidus2index (r)
    i = ceil(r*10)+1;
endfunction