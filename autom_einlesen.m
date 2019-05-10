%% Farben auslesen --> Colormap
clc
clear all
close all

%% Dialogfenster zum Einlesen der Bitmap-Datei
[FileName,PathName] = uigetfile('C:\Users\Pascal Gugger\OneDrive\Semesterarbeit\Bitmaps/*.jpg','Auswahl der Source-Datei');
Pfad = [PathName,FileName];

%% Einlesen der Bitmap-Datei
bitmap = double(imread(Pfad))./255;

%% Probenparameter
[x,y,z] = size(bitmap);
AnzPh = 11;
AnzPv = 6;
parHor = [2;0.1]; % Start und Inkrement Power
parVer = [50;50]; % Start und Inkrement Scangeschwindigkeit
p = y/(AnzPh+0.33*(AnzPh-1)); %Feldgrösse (Probe so einscannen, dass erste und letzte Fläche bündig beginnen/enden)
h = 0.33*p; %horizontale Lücke
v = 0.33*p; %vertikale Lücke
C = zeros(AnzPh*AnzPv+1,5);
C(:,1) = 0.01; %Linienabstand
%% Power
for z = 0:1:AnzPv-1
    for i = 1:1:AnzPh
        C(i+AnzPh*z,3) = parHor(1)+(i-1)*parHor(2);
    end
end
%% Scangeschw.
for z = 0:1:AnzPv-1
    for i = 1:1:AnzPh
        C(i+AnzPh*z,2) = parVer(1)+z*parVer(2);
    end
end
%% durchschnittliche Farben
map = zeros(AnzPh*AnzPv,3);
for u = 1:1:AnzPv
    for z=1:1:AnzPh
        a = round((z-1)*(p+h)+1);
        b = round(a+p-10);
        c = round((u-1)*(p+v)+1);
        d = round(c+p-10);
        summe1 = 0;
        summe2 = 0;
        summe3 = 0;
        for m = c:1:d %Zeile
            for n = a:1:b %Spalte
                summe1 = summe1 + bitmap(m,n,1);
                summe2 = summe2 + bitmap(m,n,2);
                summe3 = summe3 + bitmap(m,n,3);
            end
        end
        average1 = summe1 / (p^2);
        average2 = summe2 / (p^2);
        average3 = summe3 / (p^2);
        map(z+(u-1)*AnzPh,1) = average1;
        map(z+(u-1)*AnzPh,2) = average2;
        map(z+(u-1)*AnzPh,3) = average3;
    end
end
summe1 = 0;
summe2 = 0;
summe3 = 0;
for m = 1:1:round(p)
    for n = round(p+5):1:round(p+h)
                summe1 = summe1 + bitmap(m,n,1);
                summe2 = summe2 + bitmap(m,n,2);
                summe3 = summe3 + bitmap(m,n,3);
    end
end
average1 = summe1 / (p*(h-5));
average2 = summe2 / (p*(h-5));
average3 = summe3 / (p*(h-5));
map = [map;average1 average2 average3];
save('Parameter','C');
save('parHor_P.mat','parHor');
save('parVer.mat','parVer');
%% Darstellung der Bitmap-Datei
figure;
image(bitmap);
title('source');
bild_original = (imread('saturation.JPG'));
bild_copy = rgb2ind(bild_original,map,'nodither');

figure
image(bild_copy)
colormap(map)
title('Kopie')
figure
image(bild_original)
title('Original')