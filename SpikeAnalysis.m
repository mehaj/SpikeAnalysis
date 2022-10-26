%SCRIPT
%%AUTHOR MEHA
%this scripts loads an ABF file from the defined path
%it first calculated the RMP
%based on user input, it can detect one or two different events
% it then calculates their amplitude, inter event interval, rise time,
% decay time, width, max dv/dt, ahp ampltiude and threshold
% if the cell is bursting, it calculates burst features - duration of
% bursts, inter burst interval and intraburst spike time
% Input arguments- file path, filename, number of event types to detect, event 1 threshold,
% event 2 threshold, whether bursting or tonic, burst threshold
%Output Arguments- ss- strucutre contains all kinetics information
%                     fields in ss
%                     peaks- location of events in trace
%                     times- time stamp of events in trace
%                     amp- ampltiude
%                     iei- inter event interval
%                     risetime
%                     decaytime
%                     width
%                     event- each event separated out
%                     event_avg- averaged shape of all events
%                     ahp- ahp amplitude
%                     threshold- threshold to spike
%                     max_dvdt- membrane potential at max dv/dt
%               same for CF if there are two events
%               burst- this is a structure containing following fields
%       T_START:  time of first spike in a burst
%       T_END:    time of last spike in a burst
%       T_MIDDLE: time of middle spike in a burst
%       DUR:      duration of a burst
%       N:        number of spikes in burst
%       IBI_PRE:  interval between previous burst's end and this burst's start
%       IBI_POST: interval between this burst's end and next start
%       ISI_PRE:  interval between last spike before this burst and start of
%                 this burst
%       ISI_POST: interval between end of this burst and next spike
%       PER_PRE:  period between middle spike of previous burst and this
%       PER_POST: period between middle spike of this burst and next's
%       I_START:  index of first spike in burst
%       I_END:    index of last spike in burst
%       intraburst: inter event interval of spikes within a burst
%Functions required: PlotTraces, readabf,RMP, EventDetect, pekadet,
%                   EventKinetics, AHP, BurstKinetics, burstinfo, schmitt,
%                   schmittpeak


%% set path, define the number of events, whether cell is bursting 
clc,clear;close all;
directory="D:\VTLab\ion channel characterization\control\animal5";
filename="22314009.abf";
event_number=1;
thresh_ss=10;
thresh_cf=32;
burstdet=0;             %   1= bursting 0=tonic
burst_thresh=600;

%% extract information from abf file, plot trace and save it

[aux,data,time]=PlotTraces(directory,filename);

fig_filename=strcat(filename,'_1', '.png');
saveas(gcf,(fullfile(directory,fig_filename)));

%calculate the RMP, if tonic only one rmp if burst (burstdet=1) rmp will contain two
%values
[rmp]=RMP(data,burstdet,time);

%detect event, calculate amplitude and inter event interval

% for detecting single event
if event_number==1
    [ss]=EventDetect(data(:,1),rmp,thresh_ss,time);

else        %for detecting two events
    [ss,cf]=EventDetect(data,rmp,thresh_ss,time,thresh_cf);
end

fig_filename=strcat(filename,'_2', '.png');
saveas(gcf,(fullfile(directory,fig_filename)));

%% separate out the events for both ss and cf
if event_number==2 %cf only present if two events are detected otherwise only ss will be calculated
    %separate out the cf events
    col=1;
    for a=1:length(cf.peaklocs)
       
       if cf.peaklocs(a,1)<=500 
           continue;
       end
        low=cf.peaklocs(a,1)-500; up=cf.peaklocs(a,1)+3200;
        if up>length(data)
            continue;
        end
        cf.event(:,col)=data(low:up,1);
        col=col+1;
    end
    time_cf=time(1:3701,1);

    [rowcf,colcf]=size(cf.event);
    for i=1:rowcf
        cf.cf_avg(i,1)=sum(cf.event(i,:))/colcf;
    end
end


% separate out simple spikes
col=1; 
for a=1:length(ss.peaks)
   
   if ss.peaklocs(a,1)<=500
       continue;
   end
    low=ss.peaklocs(a,1)-500; up=ss.peaklocs(a,1)+2000;
    if up>length(data)
        continue;
    end
    ss.event(:,col)=data(low:up,1);
    col=col+1;
end
time_ss=time(1:2501,1);


[rowss,colss]=size(ss.event);
for i=1:rowss
    ss.ss_avg(i,1)=sum(ss.event(i,:))/colss;
end
%% get kinetics for all the event kinetics
% cf kinetics
if event_number==2
    [~,col]=size(cf.event);
    for i=1:col
        [cf.risetime(i,1),cf.decaytime(i,1),cf.width(i,1)]=EventKinetics(cf.event(:,i),time_cf);
        [cf.threshold(i,1),cf.max_dvdt(i,1),cf.ahp(i,1)]=AHP(cf.event(:,i),time_cf);
    end
end

%ss kinetics

[~,col]=size(ss.event);
for i=1:col
    [ss.risetime(i,1),ss.decaytime(i,1),ss.width(i,1)]=EventKinetics(ss.event(:,i),time_ss);
    [ss.threshold(i,1),ss.max_dvdt(i,1),ss.ahp(i,1)]=AHP(ss.event(:,i),time_ss);
end



%% for cells that are bursting, detect bursts and their features
if burstdet
    [burst]=BurstKinetics(data, time, thresh_ss,burst_thresh);
    fig_filename=strcat(filename,'_3', '.png');
    saveas(gcf,(fullfile(directory,fig_filename)));

end
%% save all the data in a file
mat_filename = strcat(filename,'.mat');
if event_number==2 && burstdet==1 % two events and cell is bursting
    save(fullfile(directory,mat_filename),'aux','data','cf','rmp','ss','time','burst');

elseif event_number==2 && burstdet==0 %two events and tonic firing
    save(fullfile(directory,mat_filename),'aux','data','cf','rmp','ss','time');

elseif event_number==1
    save(fullfile(directory,mat_filename),'aux','data','rmp','ss','time');

end




