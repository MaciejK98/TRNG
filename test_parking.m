clear;
clc;
n=12000;
side = 100;
no_succ=0; %number of succes
fileID = fopen('binaryfile4.bin');

A = uint32(fread(fileID,'uint32'));
stala = 2^32;

C = double(A)/stala;
B = C*100;

xtemp = B(1:2:end);         % Odd-Indexed Elements  %zapisanie do xtemp co drugiej wartosci 
ytemp = B(2:2:end);         % Even-Indexed Elements  %zapisanie do ytemp co drugiej wartosci 

x=[];
y=[];

%wynik=1:1:10;
%for m=1:100
for i=1:100   
    x(1) = xtemp(1); %pierwsze parkowanie
    y(1) = ytemp(1);
   no_succ=1;
   
    for j=1:n
        
       val_x_temp = mod(j+n*i,length(xtemp))+1;
       val_y_temp = mod(j+n*i,length(ytemp))+1;
        
            x(end+1) = xtemp(val_x_temp); 
            y(end+1) = ytemp(val_y_temp);
            k=1;
            while(1==1)
                    if(abs(x(k)-xtemp(val_x_temp))<=1 && abs(y(k)-ytemp(val_y_temp))<=1)
                     break;
                    end
                    k=k+1;
                    if(k<no_succ+1)
                        continue;
                    end
            x(no_succ) = xtemp(val_x_temp); 
            y(no_succ) = ytemp(val_y_temp);
            no_succ= no_succ+1;
            break;
            end
        
    end
wynik(i)=(no_succ-3523)/(21.9);
no_succ=0;
end

[h,p] = kstest(wynik);
%wynik = 0;
%end
