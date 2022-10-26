% AUTHOR MEHA
% This functions takes membrane potential values and detects one or two events 
% depending on user defined thresholds. It also then calculates the amplitude
% and interevent interval of one or both of these events
%It then plots the trace and shows ss and cf events detected on it as blue
%and green dots respectively
% Input arguments- Vm- membrane potential given as a vector
%                 rmp- basal membrane potential, single float
%                 thresh_ss- threshold for smaller of the two events
%                 thresh_cf- optional, threshold for the second, larger event
%                 time- time points at which vm was sampled as an array
%  Output arguments- ss- strucutre contains following fields
%                     peaks- absolute vm values of each spike
%                     time- time of the peak
%                     amp-amplitude of peak. calculated as difference between absolute peak value and rmp
%                     iei=inter event interval
%                   structure Cf contains the same fields as above for the
%                   larger event
%

function [ss,cf]=EventDetect(Vm,rmp,thresh_ss,time,thresh_cf)
    
    
    if nargin==4 % for only single type of event
        event_data=peakdet(Vm,thresh_ss);
        ss=struct('peaks',event_data(:,2));
        ss.peaklocs=event_data(:,1);
        ss.amp=event_data(:,2)-rmp; 
        for i=1:length(event_data)
            ss.time(i,1)=time(event_data(i,1));
        end
        ss.iei=diff(ss.time);

        figure;
        plot(time,Vm,'LineWidth',1,'Color','black');
        hold on 
        scatter(ss.time,ss.peaks,'MarkerFaceColor','blue')
    
    elseif nargin==5 %for two kinds of event
        all_peaks=peakdet(Vm,thresh_ss);
        cf_peaks=peakdet(Vm,thresh_cf);

        % all events from all_peaks that are not in cf_peaks are ss
        j=1; iscf=ismember(all_peaks(:,2),cf_peaks(:,2));
        for i=1:length(iscf)
	        if iscf(i,1)==0
            ss_peaks(j,:)=all_peaks(i,:);
            j=j+1;
          end
        end
        ss=struct('peaks',ss_peaks(:,2));
        ss.time=ss_peaks(:,1);
        ss.peaklocs=ss_peaks(:,1);
        ss.amp=ss_peaks(:,2)-rmp;
        for i=1:length(ss_peaks)
            ss.time(i,1)=time(ss_peaks(i,1));
        end
        ss.iei=diff(ss.time);
        

        cf=struct('peaks',cf_peaks(:,2));
        cf.time=cf_peaks(:,1);
        cf.peaklocs=cf_peaks(:,1);
        cf.amp=cf_peaks(:,2)-rmp;
        for i=1:length(cf_peaks)
            cf.time(i,1)=time(cf_peaks(i,1));
        end
        cf.iei=diff(cf.time);


        %plot the trace and mark event peaks on it
    
        figure;
        plot(time,Vm,'LineWidth',1,'Color','black');
        hold on 
        scatter(cf.time,cf.peaks,'MarkerFaceColor','green')
        scatter(ss.time,ss.peaks,'MarkerFaceColor','blue')

    % just in case there is error in input arguments
    else
        error('Not enough input arguments')
    end

end