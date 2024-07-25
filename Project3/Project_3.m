close all; clear; clc;

% Read the image, data type: uint8
img_degraded = imread('Bird 2 degraded.tif');
% change img_degraded type to double and normalize to [0, 1]
imgd = double(img_degraded)/255;
% Get Fourier transform of input image
X = fft2(imgd);
% Shift zero-frequency component to center of spectrum
X = fftshift(X);

% Show the degraded image
figure;
imshow(img_degraded);
title('Original degraded image');

% Show the log Fourier magnitude spectra of the degraded image and normalize
figure;
imagesc(log(abs(X)+1)./log(max(abs(X(:))+1)));
colorbar;
colormap gray;
title('Fourier magnitude spectrum of the degraded image');

% Degradation function design
k=0.001;
H = zeros(600,600);
for u = 1:600
    for v = 1:600
        H(u,v)=exp(1)^(-k*(((u-300)^2+(v-300)^2)^(5/6)));
    end
end

% Show the log of degradation function and normalize
figure;
imagesc(log(abs(H)+1)./log(max(abs(H(:))+1)));
colorbar;
colormap gray;
title('Fourier magnitude of the degraded model H(u,v)');

% Inverse Filter
H_i = zeros(600,600);
for u = 1:600
    for v = 1:600
        H_i(u,v)=exp(1)^(k*(((u-300)^2+(v-300)^2)^(5/6)));
    end
end
% Radius of 50
H1=zeros(600,600);
for i=1:600
    for j=1:600
        d=norm([i j]-[300 300]);
        if d<50 | d==50     
            H1(i,j)=H_i(i,j);
        end
    end
end

% Radius of 80
H2=zeros(600,600);
for i=1:600
    for j=1:600
        d=norm([i j]-[300 300]);
        if d<80 | d==80     
            H2(i,j)=H_i(i,j);
        end
    end
end

% Radius of 120
H3=zeros(600,600);
for i=1:600
    for j=1:600
        d=norm([i j]-[300 300]);
        if d<120 | d==120     
            H3(i,j)=H_i(i,j);
        end
    end
end

% Use designed degradation function to do inverse filtering
F1 = X .* H1;
F2 = X .* H2;
F3 = X .* H3;

% Show the restoration image
output1 = uint8(255*mat2gray(abs(ifft2(ifftshift(F1)))));
figure;
imshow(output1);
title('Restored image of radius of 50');

output2 = uint8(255*mat2gray(abs(ifft2(ifftshift(F2)))));
figure;
imshow(output2);
title('Restored image of radius of 80');

output3 = uint8(255*mat2gray(abs(ifft2(ifftshift(F3)))));
figure;
imshow(output3);
title('Restored image of radius of 120');
