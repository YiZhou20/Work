function vmt_l = link_vmt(density, velocity, link_length, dt)

% vehicle mile travelled
% constants
Convert2Miles = 0.000621371192;

vmt_l = density * link_length * velocity * dt * Convert2Miles;