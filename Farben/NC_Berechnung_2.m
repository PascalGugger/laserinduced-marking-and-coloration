function NC_Berechnung_2(bitmap_produce,C,fid)
%% Bugfix:
    % round-Klammer-Fehler behoben
    % bei "beschriftet innerhalb Leer" --> drive zu Scanlinienstart
    % Offset korrigiert
% Diese Funktion schreibt den NC-Code in das bereits geöffnete Text-File.
[AnzFarben,~] = size(C);
[x,y] = size(bitmap_produce{1,1});
y = y-2; % ohne die zusätzlichen Anfangs- und Endspalten

%% Zeilensummen zur Detektierung von Leeren Zeilen
Zeilensummen = cell((AnzFarben),1);
for z = 1:1:(AnzFarben)
    Zeilensummen{z} = sum(bitmap_produce{z},2);
end

%% Abstand Definierung für Jump-Befehl
% Falls der leere Abstand zwischen zwei zu bearbeitenden Pixel grösser als
% "Leer" ist, dann wird der Laser auf Jump-Geschwindigkeit beschleunigt, um
% Zeit zu sparen.
% "Leer" entspricht entspricht Anzahl Pixel von zwei Skywritelängen.
Leer = ceil((2*C{1,5})/C{1,4}); % 2*Skywritelänge/Pixelgrösse

%% Nullpunkt im Zentrum des Bildes, in x-Rtg. abziehen und in y-Rtg. addieren
% Alle Koordinateneinträge werden um den jeweiligen Offset verschoben,
% damit sich der Fehler der F-Theta-Linse symmetrisch auf die Abbildung
% auswirkt.
xOffset = y/2*C{1,4}; % Hälfte der Bildhöhe
yOffset = x/2*C{1,4}; % Hälfte der Bildbreite

%% NC-Code-Generierung
% Es wird sukzessiv für jeden Parametersatz/Farbton den zugehörigen NC-Code
% geschrieben. Jede Pixelreihe besteht aus einer definierten Anzahl von
% Bahnlinien. Innerhalb einer Pixelreihe unterscheiden sich die
% verschiedenen Bahnlinien nur in den y-Werten, weil sie die gleiche
% Pixelabfolge abbilden. 
for F = 1:1:(AnzFarben-1) %unbearbeitete Oberfläche wird aus gelassen: -1
    Bahnanzahl = C{1,4}/C{F,1}; %Pixelgrösse/Linienabstand
    counter = 0;
    while counter == 0          %counter Schleife, damit break auswerfen kann (anstatt goto)
        if sum(Zeilensummen{F}) ==0       %falls ganze Matrix Leer, dann wird zum nächsten F gesprungen
            break;
        end
        %% Überschrift und Parametersatz
        fprintf(fid,['//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::Farbton ',int2str(F),'\r\n']);
        fprintf(fid,['P=',num2str(C{F,3}),'\r\n']); % Laserleistung
        fprintf(fid,['DWELL 3','\r\n']);                    
        fprintf(fid,['F',int2str(C{F,2}),'\r\n']);      % Scangeschwindigkeit
        
        %% Pixelreihen
        m = 1;
        while m <= x
            while m<x && Zeilensummen{F}(m) == 0          %falls die Zeile keine Einträge enthält, wird sie übersprungen
                m = m+1;
            end
            if Zeilensummen{F}(m) == 0 && m==x                
                break;
            end
            % Überschrift der Pixelreihen zur Orientierung
            fprintf(fid,['//========================Pixelreihe: ',int2str(m),'von ',int2str(x),'\r\n']);
            fprintf(fid,['CRITICAL START','\r\n']);
            %% Bahnlinie
            for Bahnlinie = 1:1:Bahnanzahl     
                fprintf(fid,['//_____________________Bahnlinie: ',int2str(Bahnlinie),'\r\n']);
                % Start immer am Bildrand
                fprintf(fid,['G00 U',num2str(-C{1,5}-xOffset),' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                
                %% Abfahren einer Pixelreihe
                for n = 1:1:y+1
                    %% Startbedingung einer Scanlinie
                    if bitmap_produce{F}(m,n) < 1 && bitmap_produce{F}(m,n+1) >= 1
                        %% Zeilenbeginnkontakt
                        if Leer >= (n)
                            % unbeschriftet innerhalb Leer?
                            if sum(bitmap_produce{F}(m,1:1:n)) == 0
                                %Jump zum Skywritestart!
                                fprintf(fid,['G00 U',num2str(round((n-1)*C{1,4}-C{1,5}-xOffset,4)),' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                                %drive zum Scanlinienstart!
                                fprintf(fid,['G08 G01 U',num2str(round((n-1)*C{1,4}-xOffset,4)),...
                                ' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                                
                            % beschriftet innerhalb Leer?
                            elseif sum(bitmap_produce{F}(m,1:1:n)) ~= 0
                                %drive zum Scanlinienstart!
                                fprintf(fid,['G08 G01 U',num2str(round((n-1)*C{1,4}-xOffset,4)),...
                                    ' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                            end
                        %% kein Zeilenbeginnkontakt
                        %unbeschriftet innerhalb Leer?
                        elseif sum(bitmap_produce{F}(m,n-Leer:1:n)) == 0    % "elseif" wird nur ausgeführt, wenn "if" zuvor nicht erfüllt wurde
                            %Jump zum Skywritestart!
                            fprintf(fid,['G00 U',num2str(round((n-1)*C{1,4}-C{1,5}-xOffset,4)),...
                                ' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                            %drive zum Scanlinienstart! 
                            fprintf(fid,['G08 G01 U',num2str(round((n-1)*C{1,4}-xOffset,4)),...
                                ' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                        
                        % beschriftet innerhalb Leer?
                        elseif sum(bitmap_produce{F}(m,n-Leer:1:n)) ~= 0
                            %drive zum Scanlinienstart!
                            fprintf(fid,['G08 G01 U',num2str(round((n-1)*C{1,4}-xOffset,4)),...
                                ' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                        end
                        
                        %% Laser anschalten
                        fprintf(fid,['L1','\r\n']);
                        
                    %% Ende einer Scanlinie
                    elseif  bitmap_produce{F}(m,n) >= 1 && bitmap_produce{F}(m,n+1) < 1
                        %% Anfahren des Endpunktes 
                        fprintf(fid,['G08 G01 U',num2str(round((n-1)*C{1,4}-xOffset,4)),...
                            ' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                        %% Laser ausschalten
                        fprintf(fid,['L0','\r\n']);
                        
                        %% Zeilenendekontakt?
                        if Leer >= ((y+1)-(n))
                            %unbeschriftet innerhalb Leer?
                            if sum(bitmap_produce{F}(m,(n+1):1:(y+1))) == 0
                                %drive zum Skywriteende!
                                fprintf(fid,['G08 G01 U',num2str(round((n-1)*C{1,4}+C{1,5}-xOffset,4)),...
                                    ' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                            end
                            % beschriftet innerhalb "Leer"? --> abgedeckt durch Startbedingung
                            
                        %% kein Zeilenendekontakt
                        %unbeschriftet innerhalb Leer?
                        elseif sum(bitmap_produce{F}(m,(n+1):1:(n)+Leer)) == 0
                            %drive zum Skywriteende
                            fprintf(fid,['G08 G01 U',num2str(round((n-1)*C{1,4}+C{1,5}-xOffset,4)),...
                                ' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
                        end
                    end
                end
                % Ende immer am Bildrand
                fprintf(fid,['G00 U',num2str(round(C{1,5}+xOffset,4)),' V',num2str(round((1-m)*C{1,4}-(Bahnlinie-1)*C{F,1}+yOffset,4)),'\r\n']);
            end
            fprintf(fid,['CRITICAL END','\r\n']);
            fprintf(fid,['DWELL 0.5','\r\n']);
            m = m+1;
            waitbar((m+x*(F-1))/(x*(AnzFarben-1))); %Aktualisierung Ladebalken
        end % Pixelreihen-Ende
        counter = counter+1;
    end %Auswurfschleife
end %Farbton
end %function