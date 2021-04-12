clear;
clc;
bity=[0,0,0,0,0,0,0,0];
bity=uint8(bity);
[R,R1,R2,G,G1,G2,B,B1,B2,watchdog,runcnt]=deal(0);
th=100; K=500;
figure(1)
%ścieżka foniczna
filename='videosample_2hour.mp4';
hmfr = dsp.AudioFileReader(filename,'SamplesPerFrame',500,'OutputDataType','uint8');
output(8)=0;

liczba_probek = 100000;
wyjscie(liczba_probek)=0;

for i=1:12
   audiobity = step(hmfr); 
end
plot(audiobity);
%normalized2=audiobity./max(abs(audiobity));  
entropia2 = entropy(audiobity);
figure(2)
h1=audiobity(:,1);
h2=audiobity(:,2);
audiobity= horzcat(h1',h2');
audiobity=audiobity';
histogram(audiobity,256,'Normalization','probability')
xlabel('Wartości (xi)')
ylabel('Częstość występowania (pi)')

%ścieżka wizyjna
video=VideoReader(filename);
vidHeight=video.Height; 
vidWidth=video.Width; 

numberOfFrames = video.NumFrames;
r = zeros(vidHeight, vidWidth, 1, 'uint8');
g = zeros(vidHeight, vidWidth, 1, 'uint8');
b = zeros(vidHeight, vidWidth, 1, 'uint8');


frame = double(read(video,180));
vt= var(frame(:))/2;
k=180;
frame = (read(video,180));
%imshow(frame)

figure(3)
%imhist(frame)
%histgram znormalizowany z obrazu 
histogram(rgb2gray(uint8(frame)),256,'Normalization','probability')
xlabel('Wartości (xi)')
ylabel('Częstość występowania (pi)')
entropia3 = entropy(rgb2gray(uint8(frame)));

% Rhist=imhist(frame(:,:,1));
% Ghist=imhist(frame(:,:,2));
% Bhist=imhist(frame(:,:,3));
% figure(4), plot(Rhist,'r')
% hold on, plot(Ghist,'g')
% plot(Bhist,'b'), legend(' Red channel','Green channel','Blue channel');
% hold off,
% 
%     r(:,:,1)=frame(:,:,1);
%     g(:,:,1)=frame(:,:,2);
%     b(:,:,1)=frame(:,:,3);
%     k = k+2;

Xc=vidHeight/2;
Yc=vidWidth/2;

centerpoints=[Xc-1,Yc-1; Xc-1,Yc; Xc-1,Yc+1;
              Xc,Yc-1;   Xc,Yc;   Xc,Yc+1;
              Xc+1,Yc-1; Xc+1,Yc; Xc+1,Yc+1];
          
colori=0;
colori=double(colori);
          
for i= 1:9
red=double(r(centerpoints(i,1),centerpoints(i,2),1));
green=double(g(centerpoints(i,1),centerpoints(i,2),1));
blue=double(b(centerpoints(i,1),centerpoints(i,2),1));

colori=colori+bitshift(red,16)+bitshift(green,8)+blue;

%fprintf('Red %5d na bin %08s \n',red,dec2bin(red));
%fprintf('Green %5d na bin %08s \n',green,dec2bin(green));
%fprintf('Blue %5d na bin %08s \n',blue,dec2bin(blue));
%fprintf('combined %5d na bin %08s \n',rgb,dec2bin(rgb));

colori=colori/9; %suma 9 kolorów dzielona na 9 - colori
end

%set initial x,y
x= mod(colori,vidWidth/2) +vidWidth/4;
y= mod(colori,vidHeight/2) +vidHeight/4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
counter1=1;
%ustawienie tresholdów już mamy vt,th,watchdog - punkt b)
counter2=0;

tic
        while  counter1-1<liczba_probek
while ~isDone(hmfr)
    counter2=counter2+1;
    if counter1>liczba_probek
        figure(5)
        histogram(wyjscie,256,'Normalization','probability')
        xlabel('Wartości (xi)')
        ylabel('Częstość występowania (pi)')
        break
    end
    if counter2 >1000
        k=k+2;
        frame = double(read(video,k));
        counter2=0;
    end
        
%generowanie randomowego bajta

for i=1:8
    
    R=frame(ceil(y)+1,ceil(x)+1,1);
    G=frame(ceil(y)+1,ceil(x)+1,2);
    B=frame(ceil(y)+1,ceil(x)+1,3);
    

%czyVT=(R-R1)^2+(G-G1)^2+(B-B1)^2;    
    while (R-R1)^2+(G-G1)^2+(B-B1)^2 < vt %jeżeli mniejsze szukaj nowego x,y
        x=mod( (x+(bitxor(R,G)+1)), vidWidth);
        y=mod( (y+(bitxor(G,B)+1)), vidHeight);
        watchdog=watchdog+1;
        R=frame((y)+1,(x)+1,1);
        G=frame((y)+1,(x)+1,2);
        B=frame((y)+1,(x)+1,3);
        
        if watchdog > th
            k=k+1;
            frame = double(read(video,k));
            watchdog=0;
        end % zakonczenie watchodga
     end


%sound coordinate
SN1 = audiobity(10 + mod((R*i-1+ (bitshift(G,2)) +B +runcnt ),K) );
SN2 = audiobity(15 + mod((R*i-1+ (bitshift(G,3)) +B +runcnt ),K) );
SN3 = audiobity(20 + mod((R*i-1+ (bitshift(G,4)) +B +runcnt ),K) );
SN4 = audiobity( 5 + mod((R*i-1+ (bitshift(G,1)) +B +runcnt ),K) );
SN5 = audiobity(25 + mod((R*i-1+ (bitshift(G,5)) +B +runcnt ),K) );
%                                        %
%czym jest j i dlaczego jest pod sounbyte%
%                                        %
j=j+1;
audiobity = step(hmfr);

if j>100000
    runcnt=runcnt+1;
    j=0;
end
%wyznaczamy nowe cordy
x=mod( bitxor(bitxor(G,ceil(y)),bitshift(bitxor(R,ceil(x)),4)) ,vidWidth);
y=mod( bitxor(bitxor(B,ceil(y)),bitshift(bitxor(G,ceil(x)),4)) ,vidHeight);

%101010101 -> 233
bity(i)=bitxor(R,bitxor(G,bitxor(B,bitxor(R1,bitxor(G1,bitxor(B1,bitxor(R2,bitxor(G2,bitxor(B2,bitxor(SN1,bitxor(SN2,bitxor(SN3,SN4))))))))))));%bitxor(SN4,SN5)))))))))))));
binki= bitget(bity(i), 1:8);
output(i)=xor(binki(1),xor(binki(2),xor(binki(3),xor(binki(4),xor(binki(5),xor(binki(6),xor(binki(7),binki(8))))))));

R1=R;G1=G;B1=B;
%if watchdog > th %jeżeli paczpies wiekszy to przechodzimy do nastepnej framki
%    k=k+1;
%end

end %zakończenie petli 1-8 bitów

R2=R;G2=G;B2=B;
wyjscie(counter1)=(output(1)*128+output(2)*64+output(3)*32+output(4)*16+output(5)*8+output(6)*4+output(7)*2+output(8)*1);
counter1=counter1+1;


normalized=wyjscie/max(abs(wyjscie));  
entropia = entropy(normalized);         %%wyliczanie entropi


end
hmfr = dsp.AudioFileReader(filename,'SamplesPerFrame',500,'OutputDataType','uint8');
        c=1
        
        end
toc
fileID = fopen('binaryfile.bin', 'w');
fwrite(fileID, wyjscie, 'uint8');
fclose(fileID);
        

        
        
 
        
