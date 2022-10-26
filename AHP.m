function [threshold,max_slope,ahp]=AHP(event,time)

%% AUTHOR MEHA
%this function takes one spike at a time and calculates its threshold, max
%dv/dt, ahp amplitude. It first applies a gaussian filter to smooth out the
%spike.It then calculates the dv/dt using the diff function. Threshold is
%calculated at the point where dv/dt is 10 percent of its max value. The first
%minima after spike peak is the max AHP. AHP amplitude is difference
%between this minima and the threshold.
%Input argument- Event- membrane potential of one event as a an array
%                   Time- duration of the event as an array
%Output arguments threshold- threshold Vm
%                 max_dvdt- Vm at max dv/dt
%                 ahp-ahp amplitude

    %applying a gaussian filter
    smoothened= smoothdata(event,'gaussian','SmoothingFactor',0.01);
    
    %dv is calculated as the difference between consecutive sample points
    dv=diff(smoothened);
    dt=diff(time);
    slope=dv./dt;
    
    %max_dvdt membrane potential and maximum dv/dt value
    max_slope=max(slope);
    
    
    %threshold is Vm for half of max dv/dt
    %this ends up being a range of values since the exact half dv/dt value is
    %not always available
    %so the range is averaged and that is calculated as the threshold.
    
    thresh_slope=max_slope*0.1;
    %sometimes exact value is not availavle. Hence take +-0.3 and average it.
    inflect_range=event(slope<=(thresh_slope+0.3) & slope>=(thresh_slope-0.3)); 
    threshold=mean(inflect_range);
    
    %find minima in the array. since it is a single event, we assume there will
    %be only one minima
    minima=findpeaks(event.*(-1));
    true_min=max(minima);
    min=true_min*(-1);
    
    %ahp amplitude is the absolute difference between minima and threshold
    ahp=abs(threshold-min);
end
