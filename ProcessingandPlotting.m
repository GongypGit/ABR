%%%This is the main script that is run in MATLAB to do the entire analysis 

load('/Users/amnasaskari/Documents/MATLAB/Amna/F0_1.mat') %Load the fundamental frequency waveform for the speech signal if you are doing analysis on the fundmanetal frequency 
load('Spiketrains.mat') %Load the file that was exported by the python script 

Fs = 100e3; %Here is the sampling frequency that must match the same Fs in the python script 
Dur = 2; %Here is the duration that must match the same duration picked in the Python script 
npts = Dur * Fs; 


T = (0:npts-1)/Fs; %Establishing a time vector 

%res = 1/StimFs; 

F0 = resample(F0,100000,8820); %Resampling the fundamental frequency to 100kHz
NewF0 = F0 ( 1: npts); % Slicing the F0 signal to required duration 

ms_res = 0.01; %1e-5/1e-3 basically getting the sampling resolution in ms
msT = (-4000:ms_res:4000); % getting the lags axis in milisecond. need to delete two elements of this 
msT(400000)=[];
msT(400000)=[];

[CNSpikes,cn_numb]= Raster(CN,T,Fs); %Using the raster function to produce Binary arrays of Spike trains so that we can process it with the firing estimation function 
[ANSpikes,an_numb]= Raster(AN,T,Fs); %Doing the above for AN as well 

%Using the firing estimation function with a Boxcar kernel of width 2, these parameters can be changed. The width can be as big but a bigger width leads to rate values that arent accurate. The Kernal can be Gaussian or Exponential but for purposes of speech signal analysis, Boxcar is best. 

CNRate = fr_es(CNSpikes,2,'Boxcar');
ANRate = fr_es(ANSpikes,2,'Boxcar'); 

%%Computing the cross correlations and plotting them. For the current project, cross correlations between the obtained rate of the CN are carried out with the fundamental waveform for the speech signal  

%Cross correlation calculation and plotting for specified time ranges: 

[R_abs,lags_abs] = xcorr(CNRate,NewF0);
plot(msT,R_abs)
xlabel('Time / ms ' ) ;
ylabel('Correlation');
title('Cross correlation of CN Spike Rates with F0');
hill = hilbert(NewF0);
hill_imag = imag(hill);
[R_hilb,lags2] =xcorr(CNRate,hill_imag);

%plot(msT,R_abs,'black'); 
plot(msT,R_hilb,'black','LineWidth',0.75);axis([-60 100 -1e4 1e4]) ; xlabel('Time (s) '); ylabel('Correlation');hold on ; plot (msT,R_abs,'red','LineWidth',0.5); xlabel('Time (s) '); ylabel('Correlation'); axis([-60 100 -1e4 1e4]);

xcorrCoeff = R_abs + j*R_hilb;
rando = abs(xcorrCoeff) ;


