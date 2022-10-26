function [rmp]=RMP(volt,burstdet,time)
%AUTHOR - MEHA
%this function calculates the approximate resting membrane potential of the
%trace as the mode value of membrane potential
%input argument: [volt]array with membrane potential
%                  [burstdet]1 for bursting trace and 0 for tonic trace
%output argument:single floating point number as output 'rmp' for tonic
%                       trace
%                  two floating point number rmp and rmp2 the first is the
%                  mode value between 0 to -55mV and rmp2 is the mode value
%                  between -90 and -56mV
if burstdet==0
    rmp=mode(volt);
else
    filt_data = smoothdata(volt,'movmedian','SmoothingFactor',0.4,'SamplePoints',time);
    [h1,e1]=histcounts(filt_data,[-60:0]);
    rmp(1,1)=e1(h1==max(h1));
    [h2,e2]=histcounts(filt_data,[-80:-60]);
    rmp(1,2)=e2(h2==max(h2));
end
end 
 




