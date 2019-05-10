function K = Konturberechnung4(x,y,bitmap_dithered)
K = zeros(x,y+1);
%Achtung hier werden nur die leere/schwarzen Pixel gezeichnet
for m = 1:1:x
     for n = 2:1:y+2
         if bitmap_dithered(m,n) == false &&  bitmap_dithered(m,n-1)  == true    %Startpunkt
             K(m,n-1)=1;
        elseif bitmap_dithered(m,n)  == true &&  bitmap_dithered(m,n-1)  == false    %Endpunkt
             K(m,n-1)=1;
         end
     end
end


 %Darstellung der Konturpunkte
figure; imshow(K);
title('Konturpunkte');

end