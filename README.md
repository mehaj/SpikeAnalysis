# SpikeAnalysis
 Contains all the MATLAB code used for anaylis in the paper

Functions list:
Author Meha:
1. AHP: calculated threshold to spike, max dv/dt and AHP amplitude of a single event
2. BurstKinetics: detects bursts within a trace and calculates burst duration, inter burst interval, 
			intraburs spike frequency
			functions needed: burstinfo, scmitt, schmittpeak
3.EventDetect: detects one or two kinds of events, their amplitude abnd itner event interval.
		functions needed:peakdet
4. EventKinetics: calculates risetime, decaytime and full width and half amplitude
5. PlotTraces: plots the trace from an .abf file if given the path
		functions needed: readabf
6. RMP: calculates the resting membrane potential of a recording 
7. SpikeAnalysis: scripts runs all the above functions and saves the outputs as a .mat file. 3 plots generated are saved as images.