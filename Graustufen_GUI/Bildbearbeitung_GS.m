function [bitmap_gray,map]=Bildbearbeitung_GS(t,r,Pfad,fd,AG)


%% gray colormap weiss, schwarz zu hell
map = zeros(AG+1,3);
for z = 2:1:AG+1
    map(z,:) = (1/AG)*(z-1)-(1/(AG*2));
end
map(1,:) = 1;
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
%% Grauumwandlung
if fd == true
    bitmap_gray = rgb2ind(bitmap,map,'dither');
else
    bitmap_gray = rgb2ind(bitmap,map,'nodither');
end
[x,~] = size(bitmap_gray);
bitmap_gray = [zeros(x,1),bitmap_gray,zeros(x,1)];
end