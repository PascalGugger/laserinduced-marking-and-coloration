function [bitmap_copy,patch] = Farbzuordnung(gray,x,y,gray_dithered,AnzahlGraustufen,t)
%cell array sind einfacher dynamisch aufrufbar
bitmap_copy = cell(AnzahlGraustufen+1,1);
for h = 1:1:AnzahlGraustufen+1        %Erstellen der Nullmatrizen mit zwei zusätzlichen Spalten
    bitmap_copy{h} = uint8(zeros(x,y+2));
end
for F = 1:1:AnzahlGraustufen
        for m = 1:1:x               %% Erstellen der bitmap_copy Matrizen
            for n = 2:1:y+1               %Matrizeneinträge werden jeweils auf den Mittelwert ihrer Grenzwerte gesetzt
                if gray_dithered(m,n) <= gray{F} && gray_dithered(m,n) > gray{F+1}
                    bitmap_copy{F}(m,n) = (gray{F+1}+gray{F})/2;   
                elseif gray_dithered(m,n) >= gray{1}
                    bitmap_copy{AnzahlGraustufen+1}(m,n) = 255; 
                end
            end
        end
end

%Darstellung der verschiedenen Farbstufen, erste und letzte leere Spalten
%sind abgeschnitten
figure;
for z = 1:1:AnzahlGraustufen
    subplot(2,AnzahlGraustufen+2,z); imshow(bitmap_copy{z}(1:x,2:y+1));
    title(['grey ' int2str(z)]);
end
subplot(2,AnzahlGraustufen+2,AnzahlGraustufen+1); imshow(bitmap_copy{z+1}(1:x,2:y+1));
title('unbearbeitet');

%Zusammensetzung der einzelnen Bearbeitungsmatrizen
patch = bitmap_copy{AnzahlGraustufen+1};
for z = 1:1:AnzahlGraustufen
    patch = patch + bitmap_copy{z};
end
subplot(2,AnzahlGraustufen+2,(AnzahlGraustufen+2)*2); imshow(patch(1:x,2:y+1));
title('patchwork');
end