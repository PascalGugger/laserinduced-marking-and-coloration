function NC_Berechnung_GS(P,Scangeschwindigkeit,bitmap_copy,x,y,Groesse,Linienabstand,SkywriteLaenge,FileName,AnzahlGraustufen,f,Ziel,GCode)
Pstr0 = '';
for z = 1:1:AnzahlGraustufen
    Pstr = [Pstr0,'_',num2str(P{z}),'V'];
    Pstr0 = Pstr;
end

Titel = [FileName,'_',Pstr0,'_',num2str(Scangeschwindigkeit),'mms_',num2str(Linienabstand),'mm_','(',num2str(Groesse*y),'mm_x_',num2str(Groesse*x),'mm)_',num2str(AnzahlGraustufen),'_Graustufen_',num2str(f),'_red_NC.txt'];
fid = fopen(fullfile(Ziel,Titel), 'W'); 
fprintf(fid,['G90','\r\n']); %absolut G90
fprintf(fid,[GCode{7,1},'\r\n']); %wait mode auto G359(motion done after last command transfered)
fprintf(fid,[GCode{12,1},'\r\n']); % VELOCITY ON (no deceleration to zero)

bar = waitbar(0,'NC-Code wird berechnet...');   %Ladebalken erstellen
Zeilensummen = cell(AnzahlGraustufen,1);
leer = ceil((2*SkywriteLaenge)/Groesse);

%NEUER NULLPUNKT IM ZENTRUM DES BILDES
%überall wo NC-Code geschrieben wird, in X-Rtg die halbe Bilddimension abziehen und in Y-Rtg die halbe Bilddimension addieren
xOffset = y/2*Groesse;
yOffset = x/2*Groesse;

for g = 1:1:AnzahlGraustufen
    Zeilensummen{g} = sum(bitmap_copy{g+1},2);
end

for F = 1:1:AnzahlGraustufen
    Bahnanzahl = Groesse/Linienabstand; %Bahnen pro Pixelbreite
    counter = 0;
    while counter == 0          %counter Schleife, damit break auswerfen kann (anstatt goto)
        if sum(Zeilensummen{F}) == 0       %falls ganze Matrix leer, dann wird zum nächsten F gesprungen
            break;
        end
        
        fprintf(fid,['//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::Farbton ',int2str(F),'\r\n']);
        %fprintf(fid,['CRITICAL START','\r\n']);
        fprintf(fid,[GCode{5,1},num2str(P{F}),'\r\n']);
        fprintf(fid,[GCode{16,1},' ', GCode{13,1},'\r\n']);
        fprintf(fid,[GCode{6,1},int2str(Scangeschwindigkeit),'\r\n']);
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
            fprintf(fid,[GCode{9,1},'\r\n']);
            %% Bahnlinien
            for Bahnlinie = 1:1:Bahnanzahl      %Bahnlinien der einzelnen Pixelreihen
                fprintf(fid,['//_____________________Bahnlinie: ',int2str(Bahnlinie),'\r\n']);
                % einheitlicher Leckleistungs-Einfluss
                fprintf(fid,[GCode{4,1},' ',GCode{14,1},num2str(round(-SkywriteLaenge-xOffset,4)),' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                for n = 1:1:y+1
                    %% START einer Scanlinie??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
                    if bitmap_copy{F+1}(m,n) == F && bitmap_copy{F+1}(m,n+1) ~= F
                        
                        %% Zeilenbeginnkontakt?
                        if leer >= (n)
                            %unbeschriftet innerhalb Leer?
                            if sum(bitmap_copy{F+1}(m,1:1:n)) == 0
                                %Jump zum Skywritestart!
                                fprintf(fid,[GCode{4,1},' ',GCode{14,1},num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                                    ' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                            elseif sum(bitmap_copy{F+1}(m,1:1:n)) ~= 0
                                %drive zum Skywritestart
                                fprintf(fid,[GCode{3,1},' ',GCode{14,1},num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                                    ' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                            end
                            %% kein Zeilenbeginnkontakt!
                            %unbeschriftet innerhalb Leer?
                        elseif sum(bitmap_copy{F+1}(m,n-leer:1:n)) == 0
                            %Jump zum Skywritestart!
                            fprintf(fid,[GCode{4,1},' ',GCode{14,1},num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                                ' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                        elseif sum(bitmap_copy{F+1}(m,n-leer:1:n)) ~= 0
                            %drive zum Skywritestart!
                            fprintf(fid,[GCode{3,1},' ',GCode{14,1},num2str(round((n-1)*Groesse-SkywriteLaenge-xOffset,4)),...
                                ' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                        end
                        
                        %Anfahren des Startpunktes & Laser anschalten
                        fprintf(fid,[GCode{3,1},' ',GCode{14,1},num2str(round((n-1)*Groesse-xOffset,4)),...
                            ' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                        fprintf(fid,[GCode{1,1},'\r\n']);
                        
                        %% ENDE einer Scanlinie??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
                    elseif  bitmap_copy{F+1}(m,n) == F && bitmap_copy{F+1}(m,n+1) ~= F
                        %% Anfahren des Endpunktes & Laser ausschalten
                        fprintf(fid,[GCode{3,1},' ',GCode{14,1},num2str(round((n-1)*Groesse-xOffset,4)),...
                            ' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                        fprintf(fid,[GCode{2,1},'\r\n']);
                        
                        %% Zeilenendekontakt?
                        if leer >= ((y+1)-(n))
                            %unbeschriftet innerhalb Leer?
                            if sum(bitmap_copy{F+1}(m,(n+1):1:(y+1))) == 0
                                %drive zum Skywriteende
                                fprintf(fid,[GCode{3,1},' ',GCode{14,1},num2str(round((n-1)*Groesse+SkywriteLaenge-xOffset,4)),...
                                    ' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                            end
                            %% kein Zeilenendekontakt
                            %unbeschriftet innerhalb Leer?
                        elseif sum(bitmap_copy{F+1}(m,(n+1):1:(n)+leer)) == 0
                            %drive zum Skywriteende
                            fprintf(fid,[GCode{3,1},' ',GCode{14,1},num2str(round((n-1)*Groesse+SkywriteLaenge-xOffset,4)),...
                                ' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);
                        end
                    end
                end
                % Ende immer am Bildrand
                fprintf(fid,[GCode{4,1},' ',GCode{14,1},num2str(round(SkywriteLaenge+xOffset,4)),' ',GCode{15,1},num2str(round((1-m)*Groesse-(Bahnlinie-1)*Linienabstand+yOffset,4)),'\r\n']);                    
            end %Bahnlinien-Ende
            waitbar((m+x*(F-1))/(x*AnzahlGraustufen)); %Aktualisierung Ladebalken
            m = m+1;
            fprintf(fid,[GCode{10,1},'\r\n']);
            fprintf(fid,[GCode{16,1},' ',GCode{8,1},'\r\n']);
        end % Pixelreihen-Ende
        counter = counter+1;
    end
end

fprintf(fid,[GCode{11,1},'\r\n']);
fclose(fid); %txt-file wird geschlossen
close(bar); %Ladebalken schliessen
end