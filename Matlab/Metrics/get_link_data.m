function [velocity, density] = get_link_data(links, velocities, densities, times, lid, ts)

velocity = velocities(links == lid & times == ts);
density = densities(links == lid & times == ts);

if isempty(velocity)
    velocity = 0;
end
if isempty(density)
    density = 0;
end
