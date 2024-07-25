clc; clear all; close all;

% Read the image
a=imread('Bird 2.tif');

% DFT of Log-Scale
F=abs(fftshift(fft2(a)));
F_Log=log(1+F);
figure; imagesc(F_Log);
colormap('gray'); colorbar;

% Zero-padding
pad=zeros(512,512);
a_p=[a pad; pad pad];
a_p_f=fftshift(fft2(im2double(a_p)));

% Inside the Radius of 30
f1=zeros(1024,1024);
for i=1:1024
    for j=1:1024
        d=norm([i j]-[512 512]);
        if d<60 | d==60     % Since padding, 60=30*2
            f1(i,j)=1;
        end
    end
end
in_30=a_p_f.*f1;
in_30=abs(ifft2(in_30));
figure; imagesc(in_30);
colormap('gray'); colorbar;

% Outside the Radius of 30
f2=zeros(1024,1024);
for i=1:1024
    for j=1:1024
        d=norm([i j]-[512 512]);
        if d>60
            f2(i,j)=1;
        end
    end
end
out_30=a_p_f.*f2;
out_30=abs(ifft2(out_30));
figure; imagesc(out_30);
colormap('gray'); colorbar;

% Top 25 frequencies (u,v)
top25=[];
F_L=F(1:end,1:256);
A=[];
for i=1:512
    for j=1:256
        A=[A F_L(i,j)];
    end
end
[R,C]=sort(A,'descend');
for kk=1:25
    row = ceil(C(kk) / 256);
    if mod(C(kk),256) == 0
        col = 256;
    else
        col = mod(C(kk),256);
    end
    top25{kk,1} = [row, col];
end