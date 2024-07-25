clc; clear all; close all;
%% Read Image
img=imread('Car On Mountain Road.tif');
img=im2double(img);
%% LoG
d=0.005*700; n=6*d;
LoG=zeros(n,n);
for x=1:n
    for y=1:n
        LoG(x,y)=(((x-11)^2+(y-11)^2-2*(d^2))/(d^4))*exp(-((x-11)^2+(y-11)^2)/(2*(d^2)));
    end
end
%% Zero-padding
img_pad=zeros(720,1120);
img_pad(11:710,11:1110)=img;
%% Convolution
for x=1:700
    for y=1:1100
        img_LoG(x,y)=sum(sum(img_pad(x:x+20,y:y+20).*LoG));
    end
end
figure; imshow(img_LoG,[]); title('LoG');
%% Zero-Crossing I: Opposite signs (Threshold 0)
img_zc=zeros(700-2,1100-2);
count=0;
for x=1:700-2
    for y=1:1100-2
        if img_LoG(x,y)*img_LoG(x+2,y+2)<0
            count=count+1;
        end
        if img_LoG(x+1,y)*img_LoG(x+1,y+2)<0
            count=count+1;
        end
        if img_LoG(x+2,y)*img_LoG(x,y+2)<0
            count=count+1;
        end
        if img_LoG(x+2,y+1)*img_LoG(x,y+1)<0
            count=count+1;
        end
        if count>=1
            img_zc(x,y)=1;
        else
            img_zc(x,y)=0;
        end
        count=0;
    end
end
figure; imshow(img_zc); title('Zero-Crossing with threshold 0');
%% Zero-Crossing II: Absolute Difference >= Threshold
img_zc_4=zeros(700-2,1100-2);
M=max(max(img_LoG));
T=M*0.04; % Threshold =4%
for x=1:700-2
    for y=1:1100-2
        if abs(img_LoG(x,y)-img_LoG(x+2,y+2))<T
            img_zc_4(x+1,y+1)=0;
        elseif abs(img_LoG(x+1,y)-img_LoG(x+1,y+2))<T
            img_zc_4(x+1,y+1)=0;
        elseif abs(img_LoG(x+2,y)-img_LoG(x,y+2))<T
            img_zc_4(x+1,y+1)=0;
        elseif abs(img_LoG(x+2,y+1)-img_LoG(x,y+1))<T
            img_zc_4(x+1,y+1)=0;
        else
            if img_zc(x,y)==1
                img_zc_4(x,y)=1;
            end
        end
    end
end
figure; imshow(img_zc_4); title('Zero-Crossing with threshold 4%');
%% Hough Parameter Space
[H,T,R] = hough(img_zc_4,'RhoResolution',1,'Theta',-90:1:89);
figure; imshow(imadjust(rescale(H)),'XData',T,'YData',R,'InitialMagnification','fit');
title('Hough transform of Car On Mountain Road.tif');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
%% Line
P  = houghpeaks(H,1000,'threshold',ceil(0.000001*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
%plot(x,y,'s','color','white');
lines = houghlines(img_zc_4,T,R,P,'FillGap',5,'MinLength',6);
figure, imshow(img_zc_4), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','r');
end
figure, imshow(img), hold on
for i = 1:length(lines)
xy = [lines(i).point1; lines(i).point2];
plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','r');
end