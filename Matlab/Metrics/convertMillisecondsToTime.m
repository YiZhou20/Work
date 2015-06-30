function date = convertMillisecondsToTime(millis)

% extracts a vector of length six [yyyy mm dd hr mi ss] from milliseconds

seconds = millis / 1000;

daysSinceStart = floor(seconds/86400);
seconds = rem(seconds, 86400);

year = 1970;
days_in_year = 364;
while daysSinceStart > days_in_year
    daysSinceStart = daysSinceStart - days_in_year;
    year = year + 1;
    if mod(year,4) == 0
        days_in_year = 366;
    else
        days_in_year = 365;
    end
end
date(1) = year;

month_days = [31 28 31 30 31 30 31 31 30 31 30 31];
k = 1;
while daysSinceStart > month_days(k)
    daysSinceStart = daysSinceStart - month_days(k);
    k = k+1;
end
date(2) = k;
date(3) = daysSinceStart;

date(4) = floor(seconds/3600);
seconds = rem(seconds, 3600);

date(5) = floor(seconds/60);
date(6) = rem(seconds, 60);