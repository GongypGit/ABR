#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division, absolute_import, print_function

#Importing packages
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt 
import brian
from brian import siemens,ms #Brian works with units therefore it is important to import them as well 

import cochlea
import cochlear_nucleus.brn as cn
import thorns as th
import thorns.waves as wv
import scipy.io as sio


def main():

    Fs = float(100e3); #The entire simulation must be done at a common sampling frequency. As the Zilany model takes a minimum sampling frequency of 100KHz, everything is upsampled to that 
    
    #Extracting speech signal and pre-processing:
    dictsample = sio.loadmat('resampled.mat') #Resampled.mat is simply a speech signal resampled to 100KHz, here you can have anything that is sampled at 100KHz, be it a segment of a song or any arbritary signal. There is no file path because we assume that this file is the same directory 
    sample = dictsample['newstory']; #newstory is just the key title for the array 
    sample  = sample.flatten() #making the signal a Row vector 
    duration = float(2); #This is how long you want your sample to be, we take 2 seconds of the speech signal because it contains significant amount of vowel sounds but you can change this number to anything 
    index = int(duration*Fs) ;#Converting the duration wanted into an index value using the sampling frequency
    mysample = sample[0:index]; #Selecting the desired duration of signal interms of index value 
    wv.set_dbspl (mysample,78) #setting the level to 78 dB SPL. SPL is the sound pressure level. This is an arbritary number and can be changed.

    
    brian.defaultclock.dt = 0.01*ms; #This coincides with the desired sampling frequency of 100KHz 

    # Generate spike trains from Auditory Nerve Fibres using Cochlea Package 
    anf_trains = cochlea.run_zilany2014(
        sound=mysample,
        fs=Fs,
        anf_num=(13,3,1),    # (Amount of High spike rate, Medium spike rate, Low spike rate fibres. You can choose these as you want but these numbers are taken from the Verhulst et.al 2015 paper)
        cf=(125,8000,30),
        species='human', #This can be changed to cat as well 
        seed=0,
        powerlaw= 'approximate' #The latest implementation of the Zilany model includes the power law representation however we do not want this to be too computationally intensive. Therefore we pick approximate
    )

    # Generate ANF and GBC groups in Brian using inbuilt functions in the Cochlear Nucleus package  
    
    anfs = cn.make_anf_group(anf_trains) #The amount of neurons for the Auditory Nerve = 30 * Amount of Fibres 
    gbcs = cn.make_gbc_group(200) #200 is the number of neurons for globular bushy cells in the cochlear nucleus. You can change this to any number but it doesn't affect the result 

    # Connect ANFs and GBCs using the synapses class in Brian 
    synapses = brian.Connection(
        anfs,
        gbcs,
        'ge_syn',
        delay = 5*ms #This is important to make sure that there is a delay between the groups
    )

    #this value of convergence is taken from the Cochlear Nucleus documentation 
    convergence = 20

    weight = cn.synaptic_weight(
        pre='anf',
        post='gbc',
        convergence=convergence
    )

    #Initiating the synaptic connections to be random with a fixed probability p that is proportional to the synaptic convergence 
    synapses.connect_random(
        anfs,
        gbcs,
        p=convergence/len(anfs),
        fixed=True,
        weight=weight,
    )

    # Monitors for the GBCs. Brian Spike Monitors are objects that basically collect the amount of spikes in a neuron group 
    gbc_spikes = brian.SpikeMonitor(gbcs)
    

    # Run the simulation using the run function in the CN package. This basically uses Brian's run function 
    cn.run(
        duration=duration,
        objects=[anfs, gbcs, synapses,gbc_spikes] #include ANpop and CN pop in this if you need to
    )

    gbc_trains = th.make_trains(gbc_spikes)

    #Extracting the spike times for both AN and CN groups 
    CNspikes = gbc_trains['spikes'];
    ANspikes = anf_trains['spikes'];

    #Converting dict format to array format so that spike train data is basically a one dimensional array or row vector of times where spikes occur 
    CN_spikes = np.asarray(CNspikes)
    AN_spikes = np.asarray(ANspikes)
    
    #Saving it in the appropriate format so that we can do further processing in MATLAB
    data = {'CN':CN_spikes,'AN':AN_spikes}
    sio.savemat('Spiketrains',data)


    #If you want to plot the rasters of these spike trains in MATPLOTLIB, you can use the following code:
    
    fig, ax = plt.subplots(2, 1)

    th.plot_raster(anf_trains, ax=ax[0])
    th.plot_raster(gbc_trains, ax=ax[1])
    plt.show()
    plt.tight_layout()


if __name__ == "__main__":
    main()
