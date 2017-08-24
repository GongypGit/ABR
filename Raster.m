%%TAKING THE SPIKE TRAIN DATA AND MAKING IT INTO BINARY SO WE CAN PROCESS
%%IT WITH FR_ES, the Firing rate estimation function. This function returns an array with 1's at the index number where a spike occurs and also returns the number of spikes. It takes a 'Cell' , which is a MATLAB data structure as an input. This is directly produced when the python code is exported with the savemat function. It also takes the time vector and the sampling frequency of the simulation as an input. 

function [Overallspikes,nspikes] = Raster(SpikeCell,T,StimFs)

for m = 1 : length (SpikeCell)
    a(m) = length(SpikeCell{m}); 
end

maxlength = max(a); 

for mm = 1 : length (SpikeCell) 
   SpikeData(mm,:) = [SpikeCell{mm},zeros(1,maxlength-length(SpikeCell{mm}))];
end 

res = 1/StimFs; 
npts = length(T); 
indices = single(SpikeData./res); 
indices = round(indices) ;
size_spikes = size(SpikeData); 
i = size_spikes(1); 
j = size_spikes(2); 
BinarySpikes = zeros(i,npts); 
nspikes = 0; 

for s = 1 : i
    for p = 1 : j
        if indices(s,p) ~= 0 
            BinarySpikes(s,indices(s,p)) = 1;
            nspikes = nspikes + 1 ; 
        end
    end
end

Overallspikes = sum(BinarySpikes);

end

            
%for single array: 
%x= SpikeData./res;
%x = single(x);
% y = zeros(1,length(T));
% for i = 1 : length(x) 
%     y(x(i)) = 1; 
% end

%^^ y is an array of the duration with the correct amount of samples
%%% at the simulation sampling rate with 1's where spikes occur



