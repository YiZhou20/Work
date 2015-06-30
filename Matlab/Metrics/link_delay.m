function d_l = link_delay(t_l, link_length, v_l)

% delay in hours calculated from travel time
% v_l: freeflow speed in mph
% constants
Convert2Miles = 0.000621371192;

d_l = t_l - link_length * Convert2Miles / v_l;