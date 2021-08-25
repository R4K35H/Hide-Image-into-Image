%% Image into Image hiding
clc;
clear;
close all;

%----------Embedding----------

%Get the cover image
in_image = imread('lena_gray.jpg');
cover = in_image;
[r c]=size(cover);
Secret_Image=imread('onion_gray.png');
[x y]=size(Secret_Image);
b=(dec2bin(Secret_Image))';
secret_img=reshape(b,1,[]);
message_img=secret_img;

%Ensure that the input message does not exceed the size of the cover image
assert(numel(cover)*8 > numel(message_img), 'ERROR: image is too large for cover image');

%Insert some uncommon character to append to the message text as a
%terminator.
eof=dec2bin('þ');
binary=strcat(message_img,eof);
%Find the least-significant bits to be set to one or zero.
zeroBit = find(binary == '0');
oneBit = find(binary == '1');
cover1=bitget(cover,1);% LSB plane
cover2=bitget(cover,2);% 2nd last LSB plane
cover=cat(2,(cover1),(cover2));% concatenate last two LSB bitplanes
%Set the values of the least-significant bits
cover(zeroBit) = bitset(cover(zeroBit),1,0);
cover(oneBit) = bitset(cover(oneBit),1,1);
c1=cover(1:r*c);
c1=reshape(c1,r,c);
c2=cover(r*c+1:end);
c2=reshape(c2,r,c);
c3=bitget(in_image,3);
c4=bitget(in_image,4);
c5=bitget(in_image,5);
c6=bitget(in_image,6);
c7=bitget(in_image,7);
c8=bitget(in_image,8);
% combining image again to form equivalent to original grayscale image
stego = (2 * (2 * (2 * (2 * (2 * (2 * (2 * c8 + c7) + c6) + c5) + c4) + c3) + c2) + c1);

%% ----------Extraction----------%%

outputImage = {};
chars=[];
for i = 1:8:numel(cover)
   chars = bitget(cover(i:i+7),1);
    chars = char(dec2bin(chars))';
    if(chars == eof)
        break;
    else
        %outputImage1{i} = char1;
        outputImage{i} = chars;
    end
    
end
S_image = outputImage;
s_img=S_image(~cellfun('isempty',S_image));
new=char(s_img);
Hidden_Image=bin2dec(new);
Hidden_Image=uint8(reshape(Hidden_Image,x,y));
%isequal(Hidden_Image,Secret_Image)
%imshow(Hidden_Image);

%% ----------Outputs----------
%figure(1);
subplot(3,2,1);
imshow(in_image);
title('Original Image');
subplot(3,2,2);
%figure(3),
imhist(in_image);
title('Original Image Histogram');

%figure(2);
subplot(3,2,3);
imshow(stego);
title ('Stego Image');
subplot(3,2,4);
%figure(4)
imhist(stego);
title ('Stego Image Histogram');

%figure(3);
subplot(3,2,5,'align');
imshow(Secret_Image);
title ('Secret Image');

%% Using MSE and PSNR to evaluate output
MSE = mse(stego,in_image);
out=sprintf('\nMSE: %f\n',MSE);
fprintf(out);
peaksnr = psnr(in_image,stego);
out=sprintf('PSNR: %f\n',peaksnr);
fprintf(out);

