function res = ERES(h, T, dt, ddy)
% Computes the earthquake response spectrum (ERS) for a given input time
% history and set of natural periods using the Duhamel integral method
% INPUTS:
%   h: array of damping ratios
%   T: array of natural periods in seconds
%   dt: time step of input acceleration history
%   ddy: input acceleration history
% OUTPUT:
%   res: array of ERS values for each damping ratio and natural period

% Determine the maximum acceleration of the input record
eq_max = max(abs(ddy));

% Initialize arrays for the response spectrum
nh = length(h);
nt = length(T);
res = zeros(nt, nh, 3);

% Compute the ERS for each combination of damping ratio and natural period
for j = 1:nh
    for i = 1:nt
        if T(i) == 0
            % Special case for T = 0
            acc_max = eq_max;
            vel_max = 0.0;
            dis_max = 0.0;
        else
            w = 2 * pi / T(i); % angular frequency
            [max_dre, max_vre, max_are] = resdfs(ddy, h(j), w, dt); % compute response at current period
            acc_max = max_are; % maximum acceleration response
            vel_max = max_vre; % maximum velocity response
            dis_max = max_dre; % maximum displacement response
        end

        % Store the results for this period and damping ratio
        res(i,j,1) = acc_max;
        res(i,j,2) = vel_max;
        res(i,j,3) = dis_max;
    end
end

end
