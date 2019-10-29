% package loading shouldn't be needed in MatLab
% pkg load statistics

input  = load("samples.csv");
% size(input)
t = input(:,1);
data = input(:,2);

coef = 1;

% remove random outliers
df = data(2:end) - data(1:end-1);
s = std(df);
f = abs(df) < s*coef;
t = t(f);
data = data(f);

% find trending
threshold = 0.01;
iter = 0;
do
    ++iter;
    printf("iteration %i \n", iter)
    % clustering values
    [idx, centers] = kmeans (data, 3);

    mx = max(centers);
    mn = min(centers);

    trendingClass = -1;
    for i = 1:length(centers)
        if centers(i) != mn && centers(i) != mx
            trendingClass = i;
            break
        end
    end

    trend = data(idx==trendingClass);
    t_tr = t(idx == trendingClass);
    p = polyfit(t_tr, trend, 1);
    trend = polyval(p,t);


    % plot(t(idx==1),data(idx==1),'r.')
    % hold on
    % plot(t(idx==2),data(idx==2),'b.')
    % plot(t(idx==3),data(idx==3),'g.')
    % plot(t, trend, 'k')
    trendForce = abs(max(trend)-min(trend))
    data = data - trend;
until ( trendForce < threshold)


ranges = [];
n = 1;
currentClass = idx(1);
for i = 2:length(idx)
    if idx(i) == currentClass
        ++n;
    else
        ranges = [ranges [currentClass; n]];
        currentClass = idx(i);
        n = 1;
    end
end
ranges = [ranges [currentClass; n]];