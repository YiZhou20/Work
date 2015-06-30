function updated = advance_time_sec(current, period)
% Time Periods are in seconds
% Default: 30
if nargin == 1
    period = 30;
end
y = current(1);
m = current(2);
d = current(3);
hr = current(4);
min = current(5);
s = current(6);

ns = s + period;
if ns < 60
    updated = [y m d hr min ns];
else
    ns = ns - 60;
    nmin = min + 1;
    if nmin < 60
        updated = [y m d hr nmin ns];
    else
        nmin = nmin - 60;
        nhr = hr + 1;
        if nhr < 24
            updated = [y m d nhr nmin ns];
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
                updated = [y nm nd 00 nmin ns];
            else
                ny = y + 1;
                updated = [ny 01 nd 00 nmin ns];
            end
        end
    end
end

end