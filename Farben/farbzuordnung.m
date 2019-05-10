function [bitmap_produce] = farbzuordnung(bitmap_copy_ind,C)
[F,~] = size(C);
[x,y] = size(bitmap_copy_ind);
bitmap_produce = cell(F,1);


%% Erstellen der Nullmatrizen mit zwei zusätzlichen Spalten
for z = 1:1:F
    bitmap_produce{z} = uint8(zeros(x,y+2));
end
%% Einfüllen der versch. Farbtonmatrizen
    for z = 1:1:F
        for m = 1:1:x
            for n = 1:1:y              
                if bitmap_copy_ind(m,n) == z-1;
                    bitmap_produce{z}(m,n+1) = z;
                end
            end
        end
    end
end