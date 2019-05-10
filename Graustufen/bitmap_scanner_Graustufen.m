%% Hauptprogramm Bitmap Scanner Graustufen dithered
%% für rgb-Bitmaps --> dithered Graustufen
clear all;
clc;
close all;

%% Parameterangabe
ablage = 'C:\Users\Pascal Gugger\Desktop\SA_Test\';
annahme = 'C:\Users\Pascal Gugger\Desktop\SA_Test\/*.jpg'; %/*.jpg für .jpg-Filter
string = input('[Freq._Pulsdauer_Wellenlänge_Material_etc]: ');
SkywriteLaenge = 0.1;    %[mm] zur Be- und Entschleunigung der Galvoscanner
manuell = input('manuelle Werteeingabe? [0 1]: ');
%% Grauparameter
AnzahlGraustufen = input('Anzahl Graustufen: ');
P = cell(AnzahlGraustufen,1);
if manuell == false
    P_max = 3;
    for z = 1:1:AnzahlGraustufen
        P{z} = (P_max/AnzahlGraustufen)*(z);
    end
elseif manuell == true
    disp('Leistugnswerte steigend eingeben.');
    for z = 1:1:AnzahlGraustufen
        P{z} = input([num2str(z),'. Leistungswert: ']);
    end
end
Pstr0 = '';
for z = 1:1:AnzahlGraustufen
    Pstr = [Pstr0,'_',num2str(P{z}),'V'];
    Pstr0 = Pstr;
end

%% Graustufen-Abgrenzung
gray = cell(AnzahlGraustufen,1);
for z = 1:1:AnzahlGraustufen+1
    gray{z} = round((1-z/(AnzahlGraustufen+1))*(255));
end

%% Parameter
t = input('TIFF Datei? [0 1]: '); 
r = input('Auflösung reduzieren? [0 1]: ');
if r == true
    f = input('Reduktionsfaktor: ');
else
    f=1;
end
d = input('Fehlerdiffusion? [0 1]: ');
Ls = input('Ls [mm]: ');
pg = input('Pixelgrösse [mm]: ');
Groesse = pg*f; %[mm]

if Ls > Groesse
    disp('Linienabstand ist grösser als Pixelgrösse!');
    Ls = input('Ls [mm]: ');
    pg = input('Pixelgrösse [mm]: ');
    Groesse = pg*f; %[mm]
end

Linienabstand = cell(AnzahlGraustufen,1);    %[mm] von 1um aufwärts

for z = 1:1:AnzahlGraustufen
    Linienabstand{z} = Ls;
end

Vs = input('Vs [mm/s]: ');
Scangeschwindigkeit = cell(AnzahlGraustufen,1);
for z = 1:1:AnzahlGraustufen
    Scangeschwindigkeit{z} = Vs;
end

%gray colormap
map = zeros(AnzahlGraustufen+1,3);
for z = 1:1:AnzahlGraustufen
    map(z,:) = ((gray{z+1}+gray{z})/2)/255;
end
map(AnzahlGraustufen+1,:) = 1;

%% Dialogfenster zum Einlesen der Bitmap-Datei
[FileName,PathName] = uigetfile(annahme,'Auswahl der Bitmap-Datei');
Pfad = [PathName,FileName];

tic
%% Einlesen der Bitmap-Datei
if t == false
    bitmap_ = imread(Pfad);
else
    [bitmap_,map_tiff] = imread(Pfad);
end
if t == true
    bitmap_ = ind2rgb(bitmap_,map_tiff);
end

%% reducing resolution
if r == true
    bitmap(:,:,1) = bitmap_(1:f:end,1:f:end,1);
    bitmap(:,:,2) = bitmap_(1:f:end,1:f:end,2);
    bitmap(:,:,3) = bitmap_(1:f:end,1:f:end,3);
else
    bitmap = bitmap_;
end

%% Darstellung der Bitmap-Datei
figure;
imshow(bitmap);
title('Original');

%% Darstellung Graustufen dithered
%dithering with various grayscales
[x,y,z] = size(bitmap);
if d == true
    gray_dithered_ind = rgb2ind(bitmap,map,'dither'); % dithering with indexed matrix & colormap
else
     gray_dithered_ind = rgb2ind(bitmap,map,'nodither');
end
gray_dithered_rgb = ind2rgb(gray_dithered_ind,map); %from ind to rgb(double)
gray_dithered  = rgb2gray(uint8(255*(gray_dithered_rgb))); %transform to uint8 and gray
gray_dithered  = [zeros(x,1) gray_dithered zeros(x,1)];
figure;
imshow(gray_dithered(1:x,2:y+1));
title('Gray-Dithering');

%% Einordnen der Farben[255-0] in ein Leistungsfenster
%Funktionsaufruf Farbzuordnung
[bitmap_copy,patch] = Farbzuordnung(gray,x,y,gray_dithered,AnzahlGraustufen,t);
subplot(2,AnzahlGraustufen+2,AnzahlGraustufen+2); imshow(bitmap);
title('Original');

%% Konturberechnung
%Funktionsaufruf Konturberechnung
K = Konturberechnung(x,y,bitmap_copy,AnzahlGraustufen); %Konturpunkte Matrix hat eine Spalte mehr als bitmap (Ränder)

%% Erstellung des NC-Codes
Titel = [FileName(1:end-4),'_',string,Pstr0,'_',num2str(Vs),'mm-s_',num2str(Ls),'mm_','(',num2str(Groesse*y),'mm x ',num2str(Groesse*x),'mm)',num2str(AnzahlGraustufen),'_Graustufen_',num2str(f),'_red_NC.txt'];
fid = fopen(fullfile(ablage,Titel), 'W'); 
fprintf(fid,['G90','\r\n']);
fprintf(fid,['G359','\r\n']);
fprintf(fid,['VELOCITY ON','\r\n']);

bar = waitbar(0,'NC-Code wird berechnet...');   %Ladebalken erstellen
%Funtionsaufrufe der NC-Berechnungen der verschiedenen Farbtöne
NC_Berechnung(P,Scangeschwindigkeit,bitmap_copy,x,y,Groesse,Linienabstand,SkywriteLaenge,fid,AnzahlGraustufen);

%Abschluss des NC-Codes
fprintf(fid,['END PROGRAM','\r\n']);
fclose(fid); %txt-file wird geschlossen
close(bar); %Ladebalken schliessen
type ([ablage,Titel]);
toc