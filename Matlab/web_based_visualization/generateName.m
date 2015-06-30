function nameStr = generateName(startTime)
n1 = num2str(startTime(4));
n2 = num2str(startTime(5));
if length(n1) == 1
    n1 = ['0',n1];
end
if length(n2) == 1
    n2 = ['0',n2];
end
nameStr = [n1,n2];