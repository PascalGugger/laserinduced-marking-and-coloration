function NC_Berechnung(P,Scangeschwindigkeit,bitmap_copy,x,y,Groesse,Linienabstand,SkywriteLaenge,fid,AnzahlGraustufen)
Zeilensummen = cell(AnzahlGraustufen,1);
leer = ceil((2*SkywriteLaenge)/Groesse);

%NEUER NULLPUNKT IM ZENTRUM DES BILDES
%überall wo NC-Code geschrieben wird, in X-Rtg die halbe Bilddimension abziehen und in Y-Rtg die halbe Bilddimension addieren
xOffset = y/2*Groesse;
yOffset = x/2*Groesse;

for g = 1:1:AnzahlGraustufen
    Zeilensummen{g} = sum(bitmap_copy{g},2);
end

for F = 1:1:AnzahlGraustufen
    Bahnanzahl = Groesse/Linienabstand{F}; %Bahnen pro Pixelbreite
    counter = 0;
    while counter == 0          %counter Schleife, damit break auswerfen kann (anstatt goto)
        if sum(Zeilensummen{F}) ==0       %falls ganze Matrix leer, dann wird zum nächsten F gesprungen
            break;
        end
        
        fprintf(fid,['//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::Farbton ',int2str(F),'\r\n']);
        %fprintf(fid,['CRITICAL START','\r\n']);
        fprintf(fid,['P=',num2str(P{F}),'\r\n']);
        fprintf(fid,['DWELL 3','\r\n']);
        fprintf(fid,['F',int2str(Scangeschwindigkeit{F}),'\r\n']);
        m = 1;
        %% Pixelreihen
        while m <= x
            while m<x && Zeilensummen{F}(m) == 0          %falls Zeile leer, dann wird diese übersprungen
                m = m+1;
            end
            if Zeilensummen{F}(m) == 0 && m==x                 %sonst Fehlermeldung da m>x
                break;
            end
            fprintf(fid,['//========================Pixelreihe: ',int2str(m),'von ',int2str(x),'\r\n']);
            fprintf(fid,['CRITICAL START','\r\n']);
            %% Bahnlinien
            for Bahnlinie = 1:1:Bahnanzahl      %Bahnlinien der einzelnen Pixelreihen
                fprintf(fid,['//_____________________Bahnlinie: ',int2str(Bahnlinie),'\r\n']);
                % einheitlicher Leckleistungs-Einfluss
                fprintf(fid,['G00 U',num2str(round(-SkywriteLaenge-xOffset,4)),' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                for n = 1:1:y+1
                    %% START einer Scanlinie??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
                    if bitmap_copy{F}(m,n) < 1 && bitmap_copy{F}(m,n+1) >= 1
                        
                        %% Zeilenbeginnkontakt?
                        if leer >= (n)
                            %unbeschriftet innerhalb Leer?
                            if sum(bitmap_copy{F}(m,1:1:n)) == 0
                                %Jump zum Skywritestart!
                                fprintf(fid,['G00 U',num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                                    ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                            elseif sum(bitmap_copy{F}(m,1:1:n)) ~= 0
                                %drive zum Skywritestart
                                fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                                    ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                            end
                            %% kein Zeilenbeginnkontakt!
                            %unbeschriftet innerhalb Leer?
                        elseif sum(bitmap_copy{F}(m,n-leer:1:n)) == 0
                            %Jump zum Skywritestart!
                            fprintf(fid,['G00 U',num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                                ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                        elseif sum(bitmap_copy{F}(m,n-leer:1:n)) ~= 0
                            %drive zum Skywritestart!
                            fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                                ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                        end
                        
                        %Anfahren des Startpunktes & Laser anschalten
                        fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse-xOffset,4)),...
                            ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                        fprintf(fid,['L1','\r\n']);
                        
                        %% ENDE einer Scanlinie??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
                    elseif  bitmap_copy{F}(m,n) >= 1 && bitmap_copy{F}(m,n+1) < 1
                        %% Anfahren des Endpunktes & Laser ausschalten
                        fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse-xOffset,4)),...
                            ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                        fprintf(fid,['L0','\r\n']);
                        
                        %% Zeilenendekontakt?
                        if leer >= ((y+1)-(n))
                            %unbeschriftet innerhalb Leer?
                            if sum(bitmap_copy{F}(m,(n+1):1:(y+1))) == 0
                                %drive zum Skywriteende
                                fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse+SkywriteLaenge-xOffset,4)),...
                                    ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                            end
                            %% kein Zeilenendekontakt
                            %unbeschriftet innerhalb Leer?
                        elseif sum(bitmap_copy{F}(m,(n+1):1:(n)+leer)) == 0
                            %drive zum Skywriteende
                            fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse+SkywriteLaenge-xOffset,4)),...
                                ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);
                        end
                    end
                end
                % Ende immer am Bildrand
                fprintf(fid,['G00 U',num2str(round(SkywriteLaenge+xOffset,4)),' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand{F}+yOffset,4)),'\r\n']);                    
            end %Bahnlinien-Ende
            waitbar((m+x*(F-1))/(x*AnzahlGraustufen)); %Aktualisierung Ladebalken
            m = m+1;
            fprintf(fid,['CRITICAL END','\r\n']);
            fprintf(fid,['DWELL 0.5','\r\n']);
        end % Pixelreihen-Ende
        counter = counter+1;
    end
end
end