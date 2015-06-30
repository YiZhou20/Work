function t_l = link_travel_time(links, velocities, times, lid, ts, dt, report_dt, link_length, velocity, end_ts)

% travel time of a link in hours
% dt: time step in seconds
% report_dt: reporting interval in seconds

x = velocity * dt;
k = 0;
t_l = NaN;
start_ts = ts;

while x <= link_length
    ts = start_ts + round((k+1)*dt/report_dt)* report_dt * 1000;
    if ts > end_ts || isempty(velocities(links == lid & times == ts))
        
        warning('time step exceeds end time of available data, trip not completed');
%        x_remaining = link_length - x;
        
%        % if stops at 0 velocity
%        if velocity == 0
%            error('last available velocity is 0, cannot calculate travel time');
%        end
        
%        t_remaining = x_remaining/velocity;
%        t_l = (k*dt + t_remaining) / 3600;
        t_l = Inf;
        break;
    end
    velocity = velocities(links == lid & times == ts);
    x = x + velocity * dt;
    k = k+1;
end

if isnan(t_l)
    t_l = k * dt;
end

