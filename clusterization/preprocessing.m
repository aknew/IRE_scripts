% package loading shouldn't be needed in MatLab
pkg load statistics

input  = load("samples.csv");
% size(input)
t = input(:,1);
data = input(:,3);

coef = 1.5;

% remove random outliers
df = [data(2:end) - data(1:end-1); 0];
s = std(df);
f = false;
for i = 2:length(df)
    f = [f; abs(df(i-1)) > s*coef && abs(df(i)) > s*coef];
end
f = !f;

wrong = data(!f);
tw = t(!f);
plot(t,data,'b.-',tw,wrong,'ro')

t = t(f);
data = data(f);

% finding trend
threshold = 0.01;
iter = 0;

do
    ++iter;
    printf("iteration %i \n", iter)
    % clustering values
    [idx, centers] = kmeans (data, 3);

    mx = max(centers);
    mn = min(centers);

    % finding which class is just trendind - we know from your experiment scheme that it should be in the middle
    % alternative way - it should be the bigest class
    trendingClass = -1;
    measurementClass = -1;
    for i = 1:length(centers)
        if centers(i) == mx
            measurementClass = i;
        elseif centers(i) != mn
            trendingClass = i;
        end
    end

    trend = data(idx==trendingClass);
    t_tr = t(idx == trendingClass);
    p = polyfit(t_tr, trend, 1);
    trend = polyval(p,t);

    trendForce = abs(max(trend)-min(trend))
    data = data - trend;

until(trendForce < threshold)


% plot(t(idx==1),data(idx==1),'r.')
% hold on
% plot(t(idx==2),data(idx==2),'b.')
% plot(t(idx==3),data(idx==3),'g.')

% finding intervals of classes and fixing one-point intervals
intervals = [];
st = 1;
currentClass = idx(1);
for i = 2:length(idx)
    if idx(i) == currentClass
        continue
    elseif i+1<length(idx) && idx(i+1) == currentClass
        idx(i) = currentClass;
    else
        intervals = [intervals; [currentClass st i-1]];
        currentClass = idx(i);
        st = i;
    end
end
intervals = [intervals; [currentClass st length(idx)]];

results = [];
for i = 1:length(intervals)
    if intervals(i,1) == measurementClass
        dt = data(intervals(i,2):intervals(i,3));
        results = [results; [mean(dt) std(dt) t(intervals(i,2)) t(intervals(i,3)) intervals(i,3)-intervals(i,2)+1]];
    end
end

save resultCh2.csv results