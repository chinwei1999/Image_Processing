clc; clear all; close all;

img=imread('Bird 3 blurred.tif');
img=im2double(img);
figure; imshow(img); title('Original Image');

% Extract RGB
r=img(:,:,1); figure; imshow(r); title('R Component Image');
g=img(:,:,2); figure; imshow(g); title('G Component Image');
b=img(:,:,3); figure; imshow(b); title('B Component Image');

% Extract HSI
theta=acos((0.5*((r-g)+(r-b)))./sqrt((r-g).^2+(r-b).*(g-b)+0.0001)); % 0.0001 is for avoiding NaN
h=theta;
h(b>g|b==g)=2*pi-h(b>g|b==g);
h=h/(2*pi); figure; imshow(h); title('H Component Image');
s=1-3.*(min(min(r,g),b))./(r+g+b); figure; imshow(s); title('S Component Image');
i=(r+g+b)/3; figure; imshow(i); title('I Component Image');

% Zero-Padding
img_pad=zeros(802,1202,3);
img_pad(2:801,2:1201,:)=img;

hsi_pad=zeros(802,1202,3);
hsi_pad(2:801,2:1201,1)=h;
hsi_pad(2:801,2:1201,2)=s;
hsi_pad(2:801,2:1201,3)=i;

% RGB-Based Sharpened Image
img_rgb=zeros(800,1200,3);
mask=[-1 -1 -1;-1 8 -1;-1 -1 -1];
for x=1:800
    for y=1:1200
        for c=1:3
            img_rgb(x,y,c)=sum(sum(img_pad(x:x+2,y:y+2,c).*mask(:,:)));
        end
    end
end
figure; imshow(img+img_rgb); title('RGB-Based Sharpened Image');

% HSI_Based Sharpened Image
img_hsi=zeros(800,1200,3);
img_hsi_rgb=zeros(800,1200,3);
for x=1:800
    for y=1:1200
        for c=1:3
            img_hsi(x,y,c)=sum(sum(hsi_pad(x:x+2,y:y+2,c).*mask(:,:)));
        end
        if ((img_hsi(x,y,1)>0 | img_hsi(x,y,1)==0 ) & img_hsi(x,y,1)<1/3) | img_hsi(x,y,1)==1
            img_hsi_rgb(x,y,3)=img_hsi(x,y,3)*(1-img_hsi(x,y,2));
            img_hsi_rgb(x,y,1)=img_hsi(x,y,3)*(1+(img_hsi(x,y,2)*cos(img_hsi(x,y,1))/cos(pi/3-img_hsi(x,y,1))));
            img_hsi_rgb(x,y,2)=3*img_hsi(x,y,3)-(img_hsi_rgb(x,y,1)+img_hsi_rgb(x,y,3));
        elseif (img_hsi(x,y,1)>1/3 | img_hsi(x,y,1)==1/3) & img_hsi(x,y,1)<2/3
            H=img_hsi(x,y,1)-(2/3)*pi;
            img_hsi_rgb(x,y,1)=img_hsi(x,y,3)*(1-img_hsi(x,y,2));
            img_hsi_rgb(x,y,2)=img_hsi(x,y,3)*(1+(img_hsi(x,y,2)*cos(H)/cos(pi/3-H)));
            img_hsi_rgb(x,y,3)=3*img_hsi(x,y,3)-(img_hsi_rgb(x,y,1)+img_hsi_rgb(x,y,2));
        else
            H=img_hsi(x,y,1)-(4/3)*pi;
            img_hsi_rgb(x,y,2)=img_hsi(x,y,3)*(1-img_hsi(x,y,2));
            img_hsi_rgb(x,y,3)=img_hsi(x,y,3)*(1+(img_hsi(x,y,2)*cos(H)/cos(pi/3-H)));
            img_hsi_rgb(x,y,1)=3*img_hsi(x,y,3)-(img_hsi_rgb(x,y,2)+img_hsi_rgb(x,y,3));
        end
    end
end
figure; imshow(img+img_hsi_rgb); title('HSI-Based Sharpened Image');

% Difference Image
img_dif=zeros(800,1200);
img_dif=img_rgb(:,:,1)-img_hsi_rgb(:,:,1)+img_rgb(:,:,2)-img_hsi_rgb(:,:,2)+img_rgb(:,:,3)-img_hsi_rgb(:,:,3);
img_dif=mat2gray(img_dif);
figure; imshow(img_dif); title('Difference Image in Gray-Level Image');
figure; imshow(img_rgb-img_hsi_rgb); title('Difference image in RGB');
