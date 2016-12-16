function [frame_delays,frame_levels] = find_delays(num_of_frames,delays_per_level)
%function to calculate frame delays and frame levels for multi tau
% usage: [frame_delays,frame_levels] = find_delays(num_of_frames,delays_per_level)
%

if (delays_per_level * 2 >= num_of_frames)
    frame_delays = [1:num_of_frames]';
    frame_levels = zeros(num_of_frames,1);
    return;
end

frame_delays = [1:delays_per_level*2]';
frame_levels = zeros(delays_per_level *2,1);
step=2;
num_of_steps=0;
level=1;

while (max(frame_delays)+step < num_of_frames)
    frame_delays = [frame_delays;max(frame_delays)+step];
    frame_levels = [frame_levels;level];
    num_of_steps = num_of_steps + 1;
    if (num_of_steps >= delays_per_level)
        num_of_steps = 0;
        level = level + 1;
        step = 2^level;
    end
end
frame_delays = transpose(frame_delays);
frame_levels = transpose(frame_levels);
end
