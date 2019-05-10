function NC_Berechnung(P,Scangeschwindigkeit,bitmap_dithered,x,y,Bahnanzahl,Groesse,Linienabstand,SkywriteLaenge,fid)
leer = ceil((2*SkywriteLaenge)/Groesse);
Zeilensummen = sum(bitmap_dithered,2);

fprintf(fid,['//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::Farbton schwarz','\r\n']);
fprintf(fid,['P=',num2str(P),'\r\n']);
fprintf(fid,['DWELL 1','\r\n']);
fprintf(fid,['F',int2str(Scangeschwindigkeit),'\r\n']);
m = 1;
%NEUER NULLPUNKT IM ZENTRUM DES BILDES
%überall wo NC-Code geschrieben wird, in X-Rtg die halbe Bilddimension abziehen und in Y-Rtg die halbe Bilddimension addieren
xOffset = y/2*Groesse;
yOffset = x/2*Groesse;
%% Pixelreihen
while m <= x
    while m<x && Zeilensummen(m) == y+2          %falls Zeile voll (umgekehrt), dann wird diese übersprungen
        m = m+1;
    end
    if Zeilensummen(m) == y+2 && m==x                 %sonst Fehlermeldung da m>x
        break;
    end
    fprintf(fid,['//========================Pixelreihe: ',int2str(m),'von ',int2str(x),'\r\n']);
    fprintf(fid,['CRITICAL START','\r\n']);
    %% Bahnlinien
    for Bahnlinie = 1:1:Bahnanzahl      %Bahnlinien der einzelnen Pixelreihen
        fprintf(fid,['//_____________________Bahnlinie: ',int2str(Bahnlinie),'\r\n']);
        % einheitlicher Leckleistungs-Einfluss
        fprintf(fid,['G00 U',num2str(round(-SkywriteLaenge-xOffset,4)),' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
        %% Abfahren der Pixelreihe
        for n = 1:1:y+1
            %% START einer Scanlinie??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
            if bitmap_dithered(m,n) == true && bitmap_dithered(m,n+1) == false
                
                %% Zeilenbeginnkontakt?
                if leer >= (n)
                    %unbeschriftet innerhalb Leer?
                    if sum(bitmap_dithered(m,1:1:n)) == n
                        %Jump zum Skywritestart!
                        fprintf(fid,['G00 U',num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                            ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                        % beschriftet innerhalb Leer?
                    elseif sum(bitmap_dithered(m,1:1:n)) ~= n
                        %drive zum Skywritestart
                        fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                            ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                    end
                    %% kein Zeilenbeginnkontakt!
                    % unbeschriftet innerhalb Leer?
                elseif sum(bitmap_dithered(m,n-leer:1:n)) == leer
                    %Jump zum Skywritestart!
                    fprintf(fid,['G00 U',num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                        ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                    % beschriftet innerhalb Leer?
                elseif sum(bitmap_dithered(m,n-leer:1:n)) ~= leer
                    %drive zum Skywritestart
                    fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                        ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                end
                
                %% Anfahren des Startpunktes & Laser anschalten
                fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse-xOffset,4)),...
                    ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                fprintf(fid,['L1','\r\n']);
                
                %% ENDE einer Scanlinie??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
            elseif  bitmap_dithered(m,n) == false && bitmap_dithered(m,n+1) == true
                %% Anfahren des Endpunktes & Laser ausschalten
                fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse-xOffset,4)),...
                    ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                fprintf(fid,['L0','\r\n']);
                %% Zeilenendekontakt?
                if leer >= ((y+1)-(n))
                    %unbeschriftet innerhalb Leer?
                    if sum(bitmap_dithered(m,(n+1):1:(y+1))) == (y+1)-(n)
                        %drive zum Skywriteende
                        fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse+SkywriteLaenge-xOffset,4)),...
                            ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                    end
                    %% kein Zeilenendekontakt
                    %unbeschriftet innerhalb Leer?
                elseif sum(bitmap_dithered(m,(n+1):1:(n)+leer)) == leer
                    %drive zum Skywriteende
                    fprintf(fid,['G08 G01 U',num2str(round((n-1)*Groesse+SkywriteLaenge-xOffset,4)),...
                        ' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                end
            end
        end
        % Ende immer am Bildrand
        fprintf(fid,['G00 U',num2str(round(SkywriteLaenge+xOffset,4)),' V',num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
    end
    waitbar(m/x); %Aktualisierung Ladebalken
    m = m+1;
    fprintf(fid,['CRITICAL END','\r\n']);
    fprintf(fid,['DWELL 0.5','\r\n']);
end % Pixelreihen-Ende
end