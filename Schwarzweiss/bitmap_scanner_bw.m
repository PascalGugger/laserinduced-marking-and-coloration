%% Hauptprogramm Bitmap Scanner black'n'white dithered
%mit dithering nur Schwarz Weiss ein Durchgang
clear all;
clc;
close all;

%% Parameter
ablage = 'C:\Users\Pascal Gugger\Desktop\SA_Test\'; %muss mit "\" enden!
annahme = 'C:\Users\Pascal Gugger\Desktop\SA_Test\/*.jpg'; %/*.jpg jpg-Filter
string = input('Freq._Pulsdauer_Wellenlänge: ');
SkywriteLaenge = 0.1;    %[mm] zur Be- und Entschleunigung der Galvoscanner
t = input('TIFF Datei? [0 1]: '); 
r = input('Auflösung reduzieren? [0 1]: ');
if r == true
    f = input('Reduktionsfaktor: ');
else
    f=1;
end
Scangeschwindigkeit = input('Scangeschwindigkeit [mm/s]: ');
P = input('Laserleistung [V]: ');
pg = input('Pixelgroesse [mm]: '); %[mm] Pixelgrösse > Linienabstand
Groesse = pg*f; %[mm]
Linienabstand = input('Linienabstand [mm]: ');    %[mm]
if Linienabstand > Groesse
    disp('Linienabstand grösser als Pixelgrösse!');
    pg = input('Pixelgrösse [mm]: ');
    Groesse = pg*f;
    Linienabstand = input('Linienabstand [mm]: '); 
end

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

bitmap_gray = rgb2gray(bitmap);
bitmap_dithered = dither(bitmap_gray);
%% Darstellung der Bitmap-Datei
figure; imshow(bitmap);
title('Original');
figure; imshow(bitmap_gray);
title('Graustufen');
figure; imshow(bitmap_dithered);
title('dithered');
%% Einordnen der Farben nicht nötig
[x,y] = size(bitmap_gray);

%% Konturberechnung
%Funktionsaufruf Konturberechnung
bitmap_dithered = [ones(x,1),bitmap_dithered,ones(x,1)]; %zusätzliche Nullspalten
K = Konturberechnung(x,y,bitmap_dithered); %Konturpunkte Matrix hat eine Spalte mehr als bitmap (Ränder)

%% Erstellung des NC-Codes
[x,y] = size(bitmap_gray);
Titel = [FileName(1:end-4),'_',string,'_',num2str(P),'V_',num2str(Scangeschwindigkeit),'mms_',num2str(Linienabstand),'mm_bw_dithered_(',num2str(Groesse*y),'mm_x_',num2str(Groesse*x),'mm)_red_',num2str(f),'_NC.txt'];
Bahnanzahl = Groesse/Linienabstand; %Bahnen pro Pixelbreite
fid = fopen(fullfile(ablage,Titel), 'W'); 
fprintf(fid,['G90','\r\n']);
fprintf(fid,['G359','\r\n']);
fprintf(fid,['VELOCITY ON','\r\n']);

bar = waitbar(0,'NC-Code wird berechnet...');   %Ladebalken erstellen
%Funtionsaufrufe der NC-Berechnungen der verschiedenen Farbtöne
NC_Berechnung(P,Scangeschwindigkeit,bitmap_dithered,x,y,Bahnanzahl,Groesse,Linienabstand,SkywriteLaenge,fid);

%Abschluss des NC-Codes
fprintf(fid,['END PROGRAM','\r\n']);
fclose(fid); %txt-file wird geschlossen
close(bar); %Ladebalken schliessen
type ([ablage,Titel]);
toc