function vht_l = link_vht(density, link_length, dt)

% vehicle hour travelled
% dt: in seconds

vht_l = density * link_length * dt / 3600;