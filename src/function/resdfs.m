function [max_dre, max_vre, max_are] = resdfs(ddy, h, w, dt)
% RESDFS computes the maximum displacement, velocity, and acceleration responses
% using Duhamel's integral method.
% INPUTS:
%   ddy: input acceleration time history
%   h: damping ratio
%   w: undamped natural angular frequency
%   dt: time step of the input acceleration history

ndt = 10;
tao = dt / ndt;
nh = length(h);
na = length(ddy);

xd = zeros(2, 1);
xv = zeros(2, 1);

max_are = zeros(nh, 1);
max_vre = zeros(nh, 1);
max_dre = zeros(nh, 1);

yy = sqrt(1 - h .^ 2);
wd = w * yy;
w2 = w .^ 2;
w3 = w .^ 3;

f1 = 2 * h ./ (w3 * tao);
f2 = 1 ./ w2;
f3 = h * w;
f4 = 1 ./ wd;
f5 = f3 * f4;
f6 = 2 .* f3;

e = exp(-f3 * tao);
s = sin(wd * tao);
c = cos(wd * tao);
g1 = e .* s;
g2 = e .* c;
h1 = wd .* g2 - f3 .* g1;
h2 = wd .* g1 + f3 .* g2;

for m = 1:(na - 1)
    for n = 1:ndt
        at = ddy(m) + (ddy(m + 1) - ddy(m)) / ndt * (n - 1);
        bt = ddy(m) + (ddy(m + 1) - ddy(m)) / ndt * n;
        dddy = bt - at;

        z1 = f2 * dddy;
        z2 = f2 * at;
        z3 = f1 * dddy;
        z4 = z1 / tao;

        a = xd(1) + z2 - z3;
        b = f4 * xv(1) + f5 * a + f4 * z4;

        xd(2) = b * g1 + a * g2 + z3 - z2 - z1;
        xv(2) = b * h1 - a * h2 - z4;

        xd(1) = xd(2);
        xv(1) = xv(2);
        xa = -f6 * xv(1) - w2 * xd(1);

        if (abs(xd(1)) > max_dre)
            max_dre = abs(xd(1));
        end
        if (abs(xv(1)) > max_vre)
            max_vre = abs(xv(1));
        end
        if (abs(xa) > max_are)
            max_are = abs(xa);
        end
    end
end
end
