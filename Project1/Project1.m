clc;
clear all;
close all;

% Read the image file
r=imread('Bird feeding 3 low contrast.tif');
figure;
imshow(r); 

% Intensity transform
r=double(r);
s=((255/2)/atan(127/32))*atan((r-128)./32)+(255/2);
s=uint8(s);
figure;
imshow(s);

% Show the transformation function
t=linspace(0,255,256);
f=((255/2)/atan(127/32))*atan((t-128)./32)+(255/2);
f=uint8(f);
figure;
plot(t,f);
grid on;

% Show the histograms
n=[0:1:255];
figure;
histogram(r,n);

figure;
histogram(s,n);

