% на выходе массив булевных значений лежит ли конкретный элемент массива внури круга радиусом r c центром в (xc, yc)
function II = getCircle(X,Y, xc, yc, r)
    R = arrayfun(@xy2raidus, X, Y, xc, yc);
    II = R <= r;
endfunction