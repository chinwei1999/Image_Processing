clc; clear all; close all;
%% Read the image
img=imread('fruit on tree.tif');
img=im2double(img);
figure; imshow(img); title('Original Image');
%% Find out Between-Class Variance Curve & Conduct Otsu Tresholding  
[T,BCV]=Thredsholding_Otsu(img(:,:,1));
figure; plot(BCV); title('Between-Class Variance Curve');
img_otsu=zeros(733,1200,3);
for x=1:733
    for y=1:1200
        if img(x,y,1)>=T/255
            img_otsu(x,y,:)=img(x,y,:);
        else
            img_otsu(x,y,:)=0.5;
        end
    end
end
figure; imshow(img_otsu); title('Otsu Tresholding');
%% K-means
img=imread('fruit on tree.tif');
img_L1 = imsegkmeans(img,2,'Threshold',1); % Threshold = 1
mask1 = img_L1==2;
cluster1 = img .* uint8(mask1);
for x=1:733
    for y=1:1200
        if mask1(x,y)==0
            cluster1(x,y,:)=127;
        end
    end
end
figure; imshow(cluster1); title('K-Means Cluster with T=1');
img_L2 = imsegkmeans(img,2,'Threshold',5); % Threshold = 5
mask2 = img_L2==2;
cluster2 = img .* uint8(mask2);
for x=1:733
    for y=1:1200
        if mask2(x,y)==0
            cluster2(x,y,:)=127;
        end
    end
end
figure; imshow(cluster2); title('K-Means Cluster with T=5');
img_L3 = imsegkmeans(img,2,'Threshold',10); % Threshold = 10
mask3 = img_L3==2;
cluster3 = img .* uint8(mask3);
for x=1:733
    for y=1:1200
        if mask3(x,y)==0
            cluster3(x,y,:)=127;
        end
    end
end
figure; imshow(cluster3); title('K-Means Cluster with T=10');
%% Otsu_Thresholding Function
function  [threshold_otsu,var] = Thredsholding_Otsu(Image)
nbins = 256;
counts = imhist(Image,nbins);
p = counts / sum(counts);
for t = 1 : nbins
   q_L = sum(p(1 : t));
   q_H = sum(p(t + 1 : end));
   miu_L = sum(p(1 : t) .* (1 : t)') / q_L;
   miu_H = sum(p(t + 1 : end) .* (t + 1 : nbins)') / q_H;
   sigma_b(t) = q_L * q_H * (miu_L - miu_H)^2;
end
[~,threshold_otsu] = max(sigma_b(:));
var=sigma_b;
end
