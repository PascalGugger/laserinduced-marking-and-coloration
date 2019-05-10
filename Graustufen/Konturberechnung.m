function K = Konturberechnung(x,y,bitmap_copy,AnzahlGraustufen)
K = cell(AnzahlGraustufen,1);
for z = 1:1:AnzahlGraustufen
    K{z} = zeros(x,y+1);
end

for z = 1:1:AnzahlGraustufen
    for m = 1:1:x
         for n = 2:1:y+2
             if bitmap_copy{z}(m,n) >= 1 &&  bitmap_copy{z}(m,n-1)  == false    %Startpunkt
                 K{z}(m,n-1)=1;
            elseif bitmap_copy{z}(m,n)  == false &&  bitmap_copy{z}(m,n-1)  >= 1    %Endpunkt
                 K{z}(m,n-1)=1;
             end
         end
    end
end

 %Darstellung der Konturpunkte
 for z = 1:1:AnzahlGraustufen
    subplot(2,5,AnzahlGraustufen+1+z); imshow(K{z});
    title(['Konturpunkte gray' int2str(z)]);
 end

end