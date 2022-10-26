function [aux,data,time]=PlotTraces(directory, filename,epi)

%AUTHOR MEHA
%this function plots a trace from .abf files
%inputs directory : path of the file
%       filename : name of file with extentsion .abf
%       epi : episode number that you want to plot 
%       epi is only for episodic stimulation protocol.
%       Not needed if gap free
%other functions required: readabf

    %directory = 'D:\Documents\education\VT lab\ion channel characterization\Calcium\agatoxin raw\agatoxin 2020_9_2\animal 3';
    %filename = '20902046.abf';
    if nargin==2
        [data, aux] = readabf(fullfile(directory, filename));
    else 
         [data, aux] = readabf(fullfile(directory, filename),epi);
    end
    
    gain=aux.abf.adc.fTelegraphAdditGain;
    if gain>1
        data(:,1)=data(:,1)./gain;
    end
     dt = aux.dt_s;
     total_time = size(data,1)*dt;
     time = 0:dt:total_time; time = ((time(1:end-1))').*1000;
     %figure();
     set(gcf,'Position',[680,558,733,420])
     plot(time./1000,data(:,1),'Color','k','LineWidth',1);
     ylabel({'membrane potential (mV)'}, 'FontSize',14,'FontName','Verdana');
     xlabel({'time (s)'}, 'FontSize',14,'FontName','Verdana');
end

