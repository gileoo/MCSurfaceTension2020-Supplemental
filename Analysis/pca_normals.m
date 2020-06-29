clear all; close all; clc;
nsamples = 64;
nn = 4;
n_avg = 100;
r = 1.; % CAVE: normalize

error = 0;
time = 0;
for comp=1:n_avg
    phi = rand(nsamples, 1)*pi;
    
    x = r.*cos(phi);
    y = r.*sin(phi);
    
    plot(x, y, 'x')
    
    c_error = 0;
    for p=1:nsamples
        point = [x(p), y(p)];
        idx = [p, knnsearch([x, y], point, 'K', nn)];
        tic
        coeff = pca([x(idx), y(idx)]);
        time = time + toc;
        normal_est = abs(coeff(end, :)).*sign(point);
        c_error = c_error + acos(dot([x(p), y(p)], normal_est))/pi*180;
    end
    error = error + c_error/nsamples;
end
error = error/n_avg;
time = time/n_avg;