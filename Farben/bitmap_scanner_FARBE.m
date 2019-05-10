%% Farbscanner mit Colormap aus Parameterstudie
clear all;
clc;
close all;
Name = input('[Freq._Pulsdauer_Wellenlänge_Material_Methode]: ');
%% Parameter
ablage = 'C:\Users\Pascal Gugger\Desktop\SA_Test\';
annahme = 'C:\Users\Pascal Gugger\Desktop\SA_Test\/*.jpg';
annahme_parameter = 'C:\Users\Pascal Gugger\Desktop\SA_Test\/*.mat';
annahme_colormap = 'C:\Users\Pascal Gugger\Desktop\SA_Test\/*.mat';
Skywrite = 0.1; %[mm]
t = input('TIFF Datei? [0 1]: '); 
r = input('Auflösung reduzieren? [0 1]: ');
if r == true
    f = input('Reduktionsfaktor: ');
else
    f=1;
end
d = input('Fehlerdiffusion? [0 1]: ');
pg = input('Pixelgrösse [mm]: ');
Groesse = pg*f; %Pixelgrösse [mm]

%% Dialogfenster zum Einlesen der Bitmap-Datei, des Parameterfiles und der Colormap
[bitmap_Name,bitmap_PathName] = uigetfile(annahme,'Auswahl der Bitmap-Datei');
[C_Name,C_PathName] = uigetfile(annahme_parameter,'Auswahl des Parameterfiles');
[map_Name,map_PathName] = uigetfile(annahme_colormap,'Auswahl der Colormap');
bitmap_Path = [bitmap_PathName,bitmap_Name];
map_Path = [map_PathName,map_Name];
C_Path = [C_PathName,C_Name];


%% Laden des Parameterfiles und der Colormap
load(map_Path);      % map
load(C_Path);           % C

%% Kontrolle, ob Pixelgrösse > Linienabstand
for z = 1:1:(size(C,1)-1)
    if C{z,1} > Groesse
        disp('Linienabstand grösser als Pixelgrösse!');
        pg = input('Pixelgrösse [mm]: ');
        Groesse = pg*f;
    end
end

tic
% Groesse und Skywrite werden im CellArray C abgespeichert
C{1,4} = Groesse;
C{1,5} = Skywrite;
[farben,~] = size(C);

%% Laden der Bitmap-Datei
if t == false %rgb-Format
    bitmap = imread(bitmap_Path);
    imshow(bitmap); title('original');
elseif t == true %tiff-Format
    [bitmap,map_tiff] = imread(bitmap_Path);
    imshow(bitmap,map_tiff); title('original');
end
% tiff-Datei in rgb-Datei umwandeln
if t == true
    bitmap = ind2rgb(bitmap,map_tiff);
end

%% Reduktion der Auflösung
if r == true
    bitmap_(:,:,1) = bitmap(1:f:end,1:f:end,1);
    bitmap_(:,:,2) = bitmap(1:f:end,1:f:end,2);
    bitmap_(:,:,3) = bitmap(1:f:end,1:f:end,3);
else
    bitmap_ = bitmap;
end

%% Farb- und Parameterzuordnung
% bitmap_copy_ind ist eine indexierte Matrix mit Bezug auf die importierte colormap
if d == true
    bitmap_copy_ind = rgb2ind(bitmap_,map,'dither');
elseif d == false
    bitmap_copy_ind = rgb2ind(bitmap_,map,'nodither');
end
figure
imshow(bitmap_copy_ind,map);
colormap(map);
title('Grafik in echten Farben')

%% Einteilung in die Bearbeitungsmatrizen
% bitmap_produce ist ein CellArray mit allen Bearbeitungsmatrizen
[bitmap_produce] = farbzuordnung(bitmap_copy_ind,C);
[x,y] = size(bitmap_copy_ind);


%% Schreiben des NC-Codes
Datei_Name = [bitmap_Name(1:end-4),'_',Name,'_',num2str(y*Groesse),'mm x ',num2str(x*Groesse),'mm_red_',num2str(f),'_Farben_NC.txt'];
% Öffnen eines beschreibbaren Text-Files / Speicherort / Namensgebung
fid = fopen(fullfile(ablage,Datei_Name), 'W'); 
% Kopfzeilen
fprintf(fid,['G90','\r\n']);
fprintf(fid,['G359','\r\n']);
fprintf(fid,['VELOCITY ON','\r\n']);
% Wartebalken
bar = waitbar(0,'NC-Code wird berechnet...');
%Funktionsaufruf
NC_Berechnung_2(bitmap_produce,C,fid);
% Endzeile
fprintf(fid,['END PROGRAM','\r\n']);
fclose(fid);
close(bar);
type (fullfile(ablage,Datei_Name));
toc



