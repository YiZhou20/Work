function delay_l = link_total_delay(vht_l, vmt_l, v_l)

% total delay in vehicle hours
% v_l: freeflow speed in mph

delay_l = vht_l - vmt_l/v_l;