%%%This is the firing rate estimation function written as part of another group project. It takes in Spike train Data or 'A' as an input and returns a calculation based on a particular kernel of a particular width. The kernel can be linear i.e Boxcar, Gaussian or Exponential. The width of the kernel is the amount of samples that are used in calculating the average. 


function l = fr_es(A, dt,kernel)

if(length(A)==1) 
    l = A;  
end 

if (~kernel)
index = 1; 
for j = (dt+1):(length(A))
l(index) = sum(A((j-dt):j))./(dt);
index = index +1;
end  

else
    
l= zeros(1,length(A));

indices = find(A==1);

for i = 1:length(indices)
if (strcmp(kernel,'Boxcar'))
    if (ceil(indices(i) + sqrt(3)*dt) < length(A)+1 && ceil(indices(i) - sqrt(3)*dt) > 0)
        range  = indices(i)-sqrt(3)*dt:indices(i)+sqrt(3)*dt; 
    elseif(ceil(indices(i) + sqrt(3)*dt) > length(A) && ceil(indices(i) - sqrt(3)*dt) < 1)
        range = 1:length(A); 
    elseif(ceil(indices(i) + sqrt(3)*dt) > length(A) && ceil(indices(i) - sqrt(3)*dt) > 0) 
        range  = indices(i)-sqrt(3)*dt:length(A); 
    else
        range  = 1:indices(i)+sqrt(3)*dt; 
    end 
    
    range = ceil(range);
    
else 
    if (indices(i) + 5*dt < length(A)+1 && indices(i) - 5*dt > 0)
        range  = indices(i)-5*dt:indices(i)+5*dt; 
    elseif(indices(i) + 5*dt > length(A) && indices(i) - 5*dt < 1)
        range = 1:length(A); 
    elseif(indices(i) + 5*dt > length(A) && indices(i) - 5*dt > 0) 
        range  = indices(i)-5*dt:length(A); 
    else
        range  = 1:indices(i)+5*dt; 
    end 
end 

if (strcmp(kernel,'Gaussian'))
l(range) = l(range) + gauss(range,indices(i),dt);  
elseif (strcmp(kernel,'Exp'))
l(range) = l(range) + exponent(range,indices(i),dt); 
elseif (strcmp(kernel,'Boxcar')) 
l(range) = l(range) + box(dt); 
end
end 
    
end 
end 

function f = gauss(x, mu, s)
mu2 = ones(1,length(x)).*mu;
p1 = -.5 * ((x - mu2)/s) .^ 2;
p2 = (s * sqrt(2*pi));
f = exp(p1) ./ p2; 

end 

function f = exponent(x, mu, s)
mu2 = ones(1,length(x)).*mu;
p1 = -sqrt(2) * (norm((x - mu2)/s)) ;
p2 = (s * sqrt(2));
f = exp(p1) ./ p2; 

end 

function f = box(s)

f = 1/(2*sqrt(3)*s); 

end 