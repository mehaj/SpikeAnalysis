%AUTHOR MEHA
%this function taken in data with one event at a time and calculates the
%risetime, decaytime and width for each event
%rise time is defined as the time taken for amplitude to reach 10 to 100%
%decay time is time taken for signal to decay to 10% of amplitude
%width is the full width at half max amplitude of the event
% Input arguments: event= array corresponding to Vm of one event
%     time= time stamps corresponding to one event
% Output arguments: Risetime= float
%     Decaytime= float
%     Width= float
% values for all of the above can be NaN in case the event does not have a
% action potential shape
function[risetime,decaytime,width]=EventKinetics(event,time)

    %first find the peak of the event and the corresponding time stamp
    peak=max(event);
    peak_loc=find(event==peak);
    
    %in case there are more than two peaks the function picks the first one
    if length(peak_loc)>1
        peak_loc=peak_loc(1,1);
    end
    
    %amplitude is calculated as the differene between threshold and peak
    %amplitudde
    %applying a gaussian filter
    smoothened= smoothdata(event,'gaussian','SmoothingFactor',0.01);
    
    %dv is calculated as the difference between consecutive sample points
    dv=diff(smoothened);
    dt=diff(time);
    slope=dv./dt;
    
    %max_dvdt membrane potential and maximum dv/dt value
    max_slope=max(slope);
    max_dvdt= event(slope==max_slope);
    
    %threshold is Vm for half of max dv/dt
    %this ends up being a range of values since the exact half dv/dt value is
    %not always available
    %so the range is averaged and that is calculated as the threshold.
    thresh_slope=max_slope*0.5;
    thresh_range=event(slope<=(thresh_slope+0.3) & slope>=(thresh_slope-0.3));
    threshold=mean(thresh_range);
    amp=threshold-peak;
    
    %calculate the 10% and 50% of peak
    amp_10=threshold+(0.1*amp);
    amp_50=threshold-(0.5*amp);
    
    %find the point on event before peak where the voltage value is closest to 10%
    %amplitude
    %in case it is not available this part is skipped and rise time is not
    %calculated
    i=peak_loc;
    try
        while event(i,1)>amp_10
        i=i-1;
        end
        rise_loc=i;
        risetime=time(peak_loc)-time(rise_loc);
        i=peak_loc;
    catch
        risetime=NaN;
        i=peak_loc;
    end
    
    %find the point on event after peak where the voltage value is closest to 10%
    %amplitude
    %in case it is not available this part is skipped and decay time is not
    %calculated
    
    try
        while event(i,1)>amp_10
        i=i+1;
        end
        decay_loc=i;
        decaytime=time(decay_loc)-time(peak_loc);
        i=peak_loc;
    catch
        decaytime=NaN;
        i=peak_loc;
    end
    
    %first find the time point before peak where voltage is 50% amplitude
    
    
    i=peak_loc;
    try
        while event(i,1)>amp_50
            i=i-1;
        end
        width_loc1=i;
    %second find the time point after peak where voltage is 50% amplitude
        i=peak_loc;
        while event(i,1)>amp_50
            i=i+1;
        end
        width_loc2=i;
    %width is difference between these two time points
        width=time(width_loc2)-time(width_loc1);
    catch
        i=peak_loc;
        width=NaN;
    end

end


