function [bitmap_,bitmap_dithered]=Bildbearbeitung(t,r,Pfad,fd)
%% Einlesen der Bitmap-Datei
if t == false
    bitmap_ = imread(Pfad);
else
    [bitmap_,map_tiff] = imread(Pfad);
end
if t == true
    bitmap_ = ind2rgb(bitmap_,map_tiff);
end

[~,~,z] = size(bitmap_);
if z == 1
    bitmap_d(:,:,2) = bitmap_;
    bitmap_d(:,:,3) = bitmap_;
    bitmap_ = bitmap_d;
end
%% reducing resolution
if r >= 1
    bitmap(:,:,1) = bitmap_(1:r:end,1:r:end,1);
    bitmap(:,:,2) = bitmap_(1:r:end,1:r:end,2);
    bitmap(:,:,3) = bitmap_(1:r:end,1:r:end,3);
else
    bitmap = bitmap_;
end

bitmap_gray = rgb2gray(bitmap);
%% dithering?
if fd == true
    bitmap_dithered = double(dither(bitmap_gray));
else
    bitmap_dithered = double(bitmap_gray);
end
[x,~] = size(bitmap_dithered);
bitmap_dithered = [zeros(x,1),bitmap_dithered,zeros(x,1)];
end