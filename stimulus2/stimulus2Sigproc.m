% This script collects data from the buffer and classifies it.

% add paths
try; cd(fileparts(mfilename('fullpath')));catch; end;
try;
   run ../../matlab/utilities/initPaths.m
catch
   msgbox({'Please change to the directory where this file is saved before running the rest of this code'},'Change directory'); 
end
try; cd(fileparts(mfilename('fullpath')));catch; end; %ARGH! fix bug with paths on Octave

% connect to buffer
buffhost='localhost';buffport=1972;
% wait for the buffer to return valid header information
hdr=[];
while ( isempty(hdr) || ~isstruct(hdr) || (hdr.nchans==0) ) % wait for the buffer to contain valid data
  try 
    hdr=buffer('get_hdr',[],buffhost,buffport); 
  catch
    hdr=[];
    fprintf('Invalid header info... waiting.\n');
  end;
  pause(1);
end;

% set the real-time-clock to use
initgetwTime;
initsleepSec;

cname='clsfr';
% length of data to collect for each event
trlen_ms=1000;
clsfr=load(cname);if(isfield(clsfr,'clsfr'))clsfr=clsfr.clsfr;end;

state=[]; 
endTest=0; fs=0;
sequences=0;
clsfrData=[];
while ( endTest==0 )
  % reset the sequence info
  endSeq=0; 
  fs=[];  % predictions
  nFlash=0; % number flashes processed
  
  while ( endSeq==0 && endTest==0 )
    % wait for data to apply the classifier to
    [data,devents,state]=buffer_waitData(buffhost,buffport,state,'startSet',{{'stimulus.targetSymbol'}},'trlen_ms',trlen_ms,'exitSet',{'data' {'stimulus.sequence' 'stimulus.feedback'} 'end'});
    for ei=1:size(devents,2)
      if ( matchEvents(devents(ei),{'stimulus.targetSymbol'}) ) % flash, apply the classifier
         target= devents(ei).value;
         nFlash=nFlash+1;
        [testdata,testevents]=cont_applyClsfr(clsfr,'endType',{'stimulus.sequence'},'endValue',{'end'},'trlen_ms',1000,'step_ms',600);
        
        endSeq=1;
       
      elseif (matchEvents(devents(ei),'stimulus.feedback','end') ) % end training
        endTest=ei; % record which is the end-feedback event 
      end
    end
  end % sequences
  sequences= sequences+1;
  clsfrData{sequences}=testdata; 
  targets{sequences}= target;
end % feedback phase
  
  [data,labels] = prepData(clsfrData,targets);
  save('calibrate_data_s2','data','labels');
  
