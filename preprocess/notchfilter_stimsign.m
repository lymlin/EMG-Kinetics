function output = notchfilter_stimsign(freq,W)

Fs = getFs;  % Sampling Frequency

Fpass1 = freq-10;         % First Passband Frequency
Fstop1 = freq-5;         % First Stopband Frequency
Fstop2 = freq+5;         % Second Stopband Frequency
Fpass2 = freq+10;         % Second Passband Frequency
Apass1 = 10;         % First Passband Ripple (dB)
Astop  = 100;          % Stopband Attenuation (dB)
Apass2 = 10;           % Second Passband Ripple (dB)
match  = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop, ...
                      Apass2, Fs);
Hd = design(h, 'butter', 'MatchExactly', match);
output = filter(Hd,W);
% [EOF]
end