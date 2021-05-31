clear;
clc;

no_wds = 256000; % number of words liczba słów
ltrspwd = 4; % letters per word  liter na słowo 4 lub 5
wdspos = 5^ltrspwd; % words possibilieties mozliwe słowa
prob = [37/256 56/256 70/256 56/256 37/256]; % prawdopodobieństwa każdej z liter ABCDE

for k=0:wdspos-1
      Ef = no_wds;%liczba wszystkich słów bedzie mnożona przez prawdopodobieństwo danej kombinacji liter
      wd  = k;
      for l=1:ltrspwd 
        ltr = mod(wd,5)+1;%przeliczanie kolejnych indeksów na sekwencje liter A=1 B=2 ..E=5 itd prouszamy się w systemie liczb o podstawie 5
        Ef = Ef*prob(ltr); %prawdopodobieństwo słowa jest kombinacją 
        wd = floor( wd/5);%prouszamy się w systemie liczb o podstawie 5, więc to jest przeskok na kolejną pozycję 
      end
     e4(k+1)=Ef; %expected frequency oczekiwana liczba słów dla danej kombinacji
end

ltrspwd = 5; % letters per word  liter na słowo 4 lub 5
wdspos = 5^ltrspwd; % words possibilieties mozliwe słowa

for k=0:wdspos-1
      Ef = no_wds;%liczba wszystkich słów bedzie mnożona przez prawdopodobieństwo danej kombinacji liter
      wd  = k;
      for l=1:ltrspwd 
        ltr = mod(wd,5)+1;%przeliczanie kolejnych indeksów na sekwencje liter A=1 B=2 ..E=5 itd prouszamy się w systemie liczb o podstawie 5
        Ef = Ef*prob(ltr); %prawdopodobieństwo słowa jest kombinacją 
        wd = floor( wd/5);%prouszamy się w systemie liczb o podstawie 5, więc to jest przeskok na kolejną pozycję 
      end
     e5(k+1)=Ef; %expected frequency oczekiwana liczba słów dla danej kombinacji
end


fileID = fopen('SpeakToMicOutput.bin');
A = fread(fileID,'ubit32');
r1 = randi(4294967296,10000000,1);
ile_slow =256000;
mean =2500;
std =sqrt(5000);
wynik=[];
chi=[];

tic %start liczenia czasu

for final=1:24

jedynki=0;
tablica = [];
tab_z_literkami=[];
temp=0;
temp_tablica5=[];
temp_tablica4=[];



for i=64005*(final-1)+1 : 64005*final
    for j=1 : 4
        for k=1 : 8
            temp = temp+1;
            jedynki = jedynki + bitget(r1(i),temp);
            
        end
        tablica(end+1)=jedynki;
        jedynki=0;
        
    end
    temp =0;
end

for i=1:ile_slow+5
   
    switch tablica(i)
            case {0,1,2}
                tab_z_literkami(end+1)=1;
            case 3
                tab_z_literkami(end+1)=2;
            case 4
                tab_z_literkami(end+1)=3;
            case 5
                tab_z_literkami(end+1)=4;
            otherwise
                tab_z_literkami(end+1)=5;
    end
    if(i<5) 
        continue 
    else
        temp_tablica5(end+1)=tab_z_literkami(i-4)+tab_z_literkami(i-3)*10+tab_z_literkami(i-2)*100+tab_z_literkami(i-1)*1000+tab_z_literkami(i)*10000;
        temp_tablica4(end+1)=tab_z_literkami(i-3)+tab_z_literkami(i-2)*10+tab_z_literkami(i-1)*100+tab_z_literkami(i)*1000;
    end
end

[aa,~,c]=unique(temp_tablica5', 'rows');
wyjscie1 = [aa, histcounts(c,1:max(c)+1)'];

Q5=0;
for i=1: length(wyjscie1) 
   
Q5 = Q5 + ((wyjscie1(i,2)-e5(i)).^2)/e5(i);

end

%///////////////////////////////////////////////////////////////
% 4 literowe slowa
%///////////////////////////////////////////////////////////

[aa,~,c]=unique(temp_tablica4', 'rows');
wyjscie2 = [aa, histcounts(c,1:max(c)+1)'];

Q4=0;
for i=1: length(wyjscie2) 
   
Q4 = Q4 + ((wyjscie2(i,2)-e4(i)).^2)/e4(i);

end

    chi(end+1) = Q5-Q4;
    z = (chi(end)-mean)/std;
    tmp = z/sqrt(2.);
    tmp = 1+erf(tmp);
    Phi=tmp/2;
    wynik(end+1) = 1-Phi;


end %final loop

toc %koniec liczenia czasu

pd = makedist('uniform');
[h,p] = kstest(wynik,'cdf',pd);

roznica= Q5-Q4;


%plot(wyjscie1(:,2))
%figure
%plot(wyjscie2(:,2))