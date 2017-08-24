# ABR
Computational Model for the Auditory Brainstem Response to Speech 

This repository contains a set of scripts written in Python and MATLAB that collectively describe a computational representation of the response of the subcortical part of the auditory pathway (known as the Auditory Brainstem) to speech stimuli. A sample speech signal and its corresponding fundamental frequency reconstruction titled F0 is given in the repository. The F0 is obtained through Empirical Mode Decomposition (EMD) methods. The computed rate from the computational model is cross correlated with the fundamental waveform and it's hilbert transform 

The code is ran as follows: 

1. Execution of Python script that creates Spike Train data for Auditory Nerve fibres and Cochlear Nucleus Neurons. This depends on the following packages: Brian 1.4.3, Cochlea 1.2, Thorns 0.7.2, Numpy 1.1.2, Cochlear_Nucleus

2. Importing Spike Train data into MATLAB for further analysis. The main script depends on the two functions: 
a) Raster: Converts spike times into a Binary array with indices that indicate when spikes occured
b) Fr_es: Firing rate estimation function that takes in Binary spike data and outputs the estimate spike rate with a desired kernel and kernel width 

3. Plotting the results: The main script includes the computation and plotting of cross correlation plots between the obtained results for the rates i.e. the rates from the Cochlear Nucleus and the Fundamental waveform of the speech (and its Hilbert transform). The results prove the experimental findings and are discussed and shown in the project report which is also in this repository.

Feel free to use the same code to test the ABR response to other auditory stimuli like music etc. You can adjust the parameters like fibre type and amount, amount of synaptic delay, length of the stimulus, etc. More information can be found as comments in the code and within the report :) 

