%% Farben einzeln auslesen --> Colormap
clc
clear all
close all
name = input('Name: ');
disp('Alle Farben auswählen inklusive der unbearbeiteten Oberfläche (zum Schluss).');
A=input('Anzahl Proben: ');
bitmap = cell(A,1);
map = zeros(A,3);
C = cell (A,5);
for z = 1:1:A
    %% Dialogfenster zum Einlesen der Bitmap-Datei
    [FileName,PathName] = uigetfile('C:\Users\Pascal Gugger\OneDrive\Semesterarbeit\colormaps/*.jpg',['Auswahl der Source-Datei Nummer ',num2str(z)]);
    Pfad = [PathName,FileName];
    
    %% Einlesen der Bitmap-Datei
    bitmap{z} = double(imread(Pfad))./255;
    [x,y,~] = size(bitmap{z});
    map(z,1) = sum(sum(bitmap{z}(:,:,1)))/(x*y);
    map(z,2) = sum(sum(bitmap{z}(:,:,2)))/(x*y);
    map(z,3) = sum(sum(bitmap{z}(:,:,3)))/(x*y);
    
    %% Abspeichern der zugehörigen Parameter
    C{z,1} = input([num2str(z),'. Ls [mm]: ']);
    C{z,2} = input([num2str(z),'. Vs [mm/s]: ']);
    C{z,3} = input([num2str(z),'. P [W]: ']);
end

save(['map_',name],'map');
save(['C_',name],'C');