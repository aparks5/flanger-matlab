% flanger
clear all;
% Creates a single FIR delay with the delay time oscillating from
% Either 0-3 ms or 0-15 ms at 0.1 - 5 Hz
[input,fs] = audioread('pianoriff_s.mp3');
input = input(:,1);
len = length(input);
out = zeros(len,1);

% parameters to vary the effect %
max_time_delay=0.005; % 7ms max delay in seconds
rate=0.3; %rate of flange in Hz

% convert delay in ms to max delay in samples
max_samp_delay= floor(max_time_delay*fs);
delayBuff = zeros(max_samp_delay,1);
amp=0.7;
readIdx = 1;

fetchPrev = 1;

% delaybase = .010;
% new_d_base = delaybase*fs;
% d_base = LIN_INTERP(0,1,0, new_d_base,frac);
%
% dp = (float)(delay_pos - d_base) - (delay_depth * law);
% % 	// Get the integer part
% dp_idx = f_round(dp - 0.5f);
% % 	// Get the fractional part
% dp_frac = dp - dp_idx;

% for each sample
for i = 1:len,
    delayBuff(readIdx) = input(i);
    sin_ref = 0.97*sin(2*pi*i*(rate/fs));
    sin_next = 0.97*sin(2*pi*(i+1)*(rate/fs));
    cur_sin=abs(sin_ref); %abs of current sin val 0-1
    cur_delay=ceil(cur_sin*max_samp_delay);
    
    cur_frac=cur_sin*max_samp_delay;
    
    if (readIdx + cur_frac >= (max_samp_delay))
        fetchIdx = cur_frac - (max_samp_delay - readIdx) + 1;
    else
        fetchIdx = readIdx + cur_frac;
    end
    
    if (floor(fetchIdx) <= 0)
        fetchPrev = max_samp_delay;
    else
        fetchPrev = floor(fetchIdx);
    end
    
    if (ceil(fetchIdx) >= max_samp_delay)
        fetchNext = 1;
    else
        fetchNext = ceil(fetchIdx);
    end
    
    integ = fix(cur_frac);
    frac = abs(cur_frac - integ);
    interp = linear_interp(delayBuff(fetchPrev), delayBuff(fetchNext),frac);
    out(i) = (amp*input(i)) + (amp*interp);
    
    if (readIdx+1 >= max_samp_delay)
        readIdx = 1;
    else
        readIdx = readIdx + 1;
    end
    
    
end
% write output

soundsc(out,fs);

