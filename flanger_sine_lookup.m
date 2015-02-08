% flanger
clear all;
% Creates a single FIR delay with the delay time oscillating from
% Either 0-3 ms or 0-15 ms at 0.1 - 5 Hz
[input,fs] = audioread('pianoriff_s.mp3');
input = input(:,1);
len = length(input);
out = zeros(len,1);

% parameters to vary the effect %
max_time_delay=0.007; % 7ms max delay in seconds
rate=0.2; %rate of flange in Hz

% convert delay in ms to max delay in samples
max_samp_delay= floor(max_time_delay*fs);
delayBuff = zeros(max_samp_delay,1);
amp=0.7;
readIdx = 1;
sin_read = 1;
fracWTOReadIndex = 1.0;

sin_ref = 0.97*sin(2*pi*(1:1024)/1024);
sin_increment = 1024.0*rate/fs;

for i = 1:len,
    
    % store in delay buffer
    delayBuff(readIdx) = input(i);

    % read from wavetable
    integ = fix(fracWTOReadIndex);
    fFrac = abs(fracWTOReadIndex - integ);
    
    
    if (floor(fracWTOReadIndex) <= 0)
        sinPrev = 1024;
    else
        sinPrev = floor(fracWTOReadIndex);
    end
    
    if (ceil(fracWTOReadIndex) >= 1024)
        sinNext = 1;
    else
        sinNext = ceil(fracWTOReadIndex);
    end
    
    sin_val = linear_interp(sin_ref(sinPrev), sin_ref(sinNext), fFrac);

    fracWTOReadIndex = fracWTOReadIndex + sin_increment;
    
    if (fracWTOReadIndex > 1024.0)
        fracWTOReadIndex = fracWTOReadIndex - 1023.0;
    end
    
    cur_sin=abs(sin_val); %abs of current sin val 0-1
        
    % compute fractional delay, find surrounding values, interpolate
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
