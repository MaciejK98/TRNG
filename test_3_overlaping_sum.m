clear;
clc;
fileID = fopen('SpeakToMicOutput.bin');
A = uint32(fread(fileID,'uint32'));
r1 = rand(1,100000000);
stala = 2^32;
C = double(A)/stala;
D = [C;C;C;C];%r1;
howmuch=100;
sumy2(howmuch)=0;

sumy = zeros(1,howmuch);
p = [];   
pd = makedist('uniform');
mean = 50;
std = sqrt(12);
index=0;
for m=1 : 10
    for k=1 : 100  
        sumy = zeros(1,howmuch);
        
        for i=1:howmuch
             for j=0:99
                 index = index + 1;
                sumy(i) = sumy(i) + D(index);%D(((m-1)*20000)+((k-1)*200)+j+i); % do jednego elementarnego testu potrzebujemy 200 wartości
             end  
        end
        for o=1:howmuch
            sumy2(o) = (sumy(o) - mean)/std;   % Spodziewana
            %średnia to 50, a  odchylenie standardowe sqrt(12) 
        end
        
        %tu należy dokonać transformacji liniowej
        
        [h,p(k)] = kstest(sumy2); 
    end
[h,p2(m)] = kstest(p,'CDF',pd);  %ten test jest liczony dla rozkładu równomiernego 'uniform', można skorzystać z funkcji make dist i podać parametr 'CDF'
end

[h,p3] = kstest(p2,'cdf',pd);  %ten test jest liczony dla rozkładu równomiernego 'uniform', można skorzystać z funkcji make dist i podać parametr 'CDF'


