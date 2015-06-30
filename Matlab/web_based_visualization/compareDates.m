function isLarger = compareDates(startDate,endDate)
if endDate(1) < startDate(1)
    isLarger = false;
elseif endDate(1) > startDate(1)
    isLarger = true;
else
    if endDate(2) < startDate(2)
        isLarger = false;
    elseif endDate(2) > startDate(2)
        isLarger = true;
    else
        if endDate(3) < startDate(3)
            isLarger = false;
        elseif endDate(3) > startDate(3)
            isLarger = true;
        else
            if endDate(4) < startDate(4)
                isLarger = false;
            elseif endDate(4) > startDate(4)
                isLarger = true;
            elseif endDate(5) < startDate(5)
                isLarger = false;
            else
                isLarger = true;
            end
        end
    end
end