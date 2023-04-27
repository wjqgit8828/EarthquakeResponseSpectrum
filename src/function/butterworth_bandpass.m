function hd = butterworth_bandpass()
% Returns a Butterworth bandpass filter object with a specific set of
% parameters

% Sampling frequency
fs = 100; % Hz

% Filter specifications
fstop1 = 0.05; % First stopband frequency
fpass1 = 0.1; % First passband frequency
fpass2 = 20; % Second passband frequency
fstop2 = 40; % Second stopband frequency
astop1 = 12; % First stopband attenuation (dB)
apass = 0.5; % Passband ripple (dB)
astop2 = 12; % Second stopband attenuation (dB)
match = 'stopband'; % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
design = fdesign.bandpass(fstop1, fpass1, fpass2, fstop2, astop1, apass, astop2, fs);
hd = design.butter('MatchExactly', match);
end
