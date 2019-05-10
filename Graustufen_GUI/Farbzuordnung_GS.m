function [bitmap_copy] = Farbzuordnung_GS(x,y,gray_dithered,AnzahlGraustufen)
%cell array sind einfacher dynamisch aufrufbar
bitmap_copy = cell(AnzahlGraustufen+1,1);
for h = 1:1:AnzahlGraustufen+1        %Erstellen der Nullmatrizen mit zwei zusätzlichen Spalten
    bitmap_copy{h} = uint8(zeros(x,y+2));
end
for F = 0:1:AnzahlGraustufen
        for m = 1:1:x               %% Erstellen der bitmap_copy Matrizen
            for n = 2:1:y+1               
                if gray_dithered(m,n) == F
                    bitmap_copy{F+1}(m,n) = F;
                end
            end
        end
end
end