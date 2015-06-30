function endDate = advance_time(startDate, timePeriod)
% Time Periods are in minutes, 0 < timePeriod <= 60
% Default: 15
if nargin == 1
    timePeriod = 15;
end
y = startDate(1);
m = startDate(2);
d = startDate(3);
hr = startDate(4);
min = startDate(5);
s = startDate(6);

nmin = min + timePeriod;
if nmin < 60
    endDate = [y m d hr nmin s];
else
    nmin = nmin - 60;
    nhr = hr + 1;
    if nhr < 24
        endDate = [y m d nhr nmin s];
    else
        nd = d + 1;
        nm = m;
        switch m
            case {1,3,5,7,8,10,12}
                if nd > 31
                    nd = 01;
                    nm = m + 1;
                end
            case 2
                % doesn't have the case of a leap year yet
                if nd > 28
                    nd = 01;
                    nm = m + 1;
                end
            otherwise
                if nd > 30
                    nd = 01;
                    nm = m + 1;
                end
        end
        if nm <= 12
            endDate = [y nm nd 00 nmin s];
        else
            ny = y + 1;
            endDate = [ny 01 nd 00 nmin s];
        end
    end
end