%AUTHOR MEHA
%this function takes in a trace and detects bursts within it
%the main function used is burst info. for more information see
%documentation for it
%in addition to information from burstinfo function, it also calculates inter event
%interval only for the events within a burst as 'intraburst'
%it plots the trace with events and delimiters to indicate bursts
%other functions required:burstinfo, schmitt, scmittpeak
%Input arguments: Vm= array of membrane potential in a trace
%                     Time=time points for the membrane potenial trace
%                     thresh_ss=threshold for detecting simple spikes
%                     burst_threshold=threshold for detecting bursts
%  Output arguments: Burst- structure containing all information related 
%                           to bursts

function [burst]=BurstKinetics(Vm, time, thresh_ss,burst_thresh)
    
    %detect all peaks in the trace
    event_data=peakdet(Vm,thresh_ss,time);

    %considers a burst only if three or more peaks are within the defined
    %threshold. Here setting threshold to 300 ms
    burst=burstinfo(event_data(:,1),burst_thresh);

    %plot the trace with delimiters to show start and end of burst
    figure;
    plot(time,Vm,'LineWidth',1,'Color','black');
    hold on
    plot(burst.t_start, 20, 'r<');
    plot(burst.t_end,20, 'r>');
    
    %separate out intra burst timing ie all timings less than the burst
    %threshold
    j=1;
    all_iei=diff(event_data(:,1));
    for i=1:length(all_iei)
        if all_iei(i,1)<burst_thresh
        intraburst_iei(j,1)=all_iei(i,1);
        j=j+1;
        end
    end
    burst.intraburst=intraburst_iei;
end

