function stimulus1
%% stimulus 1 presentation 
DEBUG = 0; % turn off bufferBCI for debugging (if DEBUG==1)


%% BufferBCI initializaion
if ~DEBUG,

 % WARNING! hard-coded path
 addpath(genpath('..\..\buffer_bci-mki46'))

%connect to buffer
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

end

%% parameters
% defaults
trial_duration = 5; % s
number_of_trial_sets = 3;
trials_in_set = 2;
random_trial = 1; % if 1 trials (1 2 3) picked up randomly, of 0 one-by-one
show_instr = 1; % shows insturction to a user if necessary
fbDuration = 2; % feedback duration
warnings = 0; % switch on/off warnings during game
cueDuration = 2;  % DO NOT CHANGE  
game_title = 'Game 1: learning simple trial-fashion imagine movements';

% load parameters from file
try
    load('parameters.mat');
end

% path to media (img) NO SLASH AT THE END
img_path = '.'; 

% switch off warnings if necessary
if ~warnings, warning ('off','all'); end

% parameters of figure, size and title:
screen_size = [640 768]; 
title = 'Training: 1. Current trial ';
stimuli = 1:3; % normal order of presentaion
Scores = [0 0 0]'; % hidden scores - is printed into matlab output window after all
prediction = 0; % info received from buffer
RIGHT = 1; %flag
LEFT  = 2; %flag
FEET  = 3; %flag

%% Start a new Game and apply a background image:
G = SpriteKit.Game.instance('Title',title,'Size',screen_size, 'ShowFPS', 0);

%% show instruction if necessary
if show_instr,
    fID = fopen('insturtions.txt');
    if fID>0, % no file - no isntructions
        lines = textscan(fID,'%s','delimiter','\n'); 
        fclose(fID);
        instr = lines{1};        
        prompt_text_handle = text(30,600,instr,'Color',[0 0 0],...
        'FontSize',16,'HorizontalAlignment','left');        
        waitforbuttonpress;
        set(prompt_text_handle,'String', '','FontSize',16);
    end
end

%% preload graphics sets

% setting background
bkg = SpriteKit.Background([img_path '/img/bck.png']);

% messages
message = SpriteKit.Sprite('messages');
message.initState('Well done!',[img_path '/img/welldone.png'],true); % well done feedback
message.initState('righthand',[img_path '/img/rh.png'],true); % command door - right hand
message.initState('lefthand',[img_path '/img/lh.png'],true); % command window - left hand
message.initState('feet',[img_path '/img/feet.png'],true); % command feet - cockloft
message.initState('thanks',[img_path '/img/thanks.png'],true); % thanks for playing
message.initState('ready',[img_path '/img/ready.png'],true); % ready for playing?
message.initState('zero', [img_path '/img/zero.png' ],true); %
message.initState('relax',[img_path '/img/relax.png'],true); % relax between trials
message.initState('Better luck next time',[img_path '/img/nobad.png'],true); % relax between trials
message.initState('actmore',[img_path '/img/actmore.png'],true); % relax between trials
message.Location = [320, 630];
message.State = 'ready';

% samples
sampleFb = SpriteKit.Sprite('samples');
sampleFb.initState('righthand',[img_path '/img/rh_sample.png'],true); % sample door - right hand
sampleFb.initState('lefthand',[img_path '/img/lh_sample.png'],true); % sample window - left hand
sampleFb.initState('feet',[img_path '/img/feet_sample.png'],true); % sample feet - cockloft
sampleFb.initState('zero',[img_path '/img/zero.png'],true); 

% feedbacks
feedback = SpriteKit.Sprite('feedbacks');
feedback.initState('righthand',[img_path '/img/rh_feedback.png'],true); % feedback door - right hand
feedback.initState('lefthand',[img_path '/img/lh_feedback.png'],true); % feedback window - left hand
feedback.initState('feet',[img_path '/img/feet_feedback.png'],true); %feedback feet - cockloft
feedback.initState('zero',[img_path '/img/zero.png'],true); 

% preparing animation for rest
animation = SpriteKit.Sprite('dance');
for k=1:16
    spritename = sprintf('win_%d',k);
    pngFile = [img_path '/img/anim/' spritename '.png'];
    animation.initState(spritename,pngFile,true);
end

% preparing text message and clock
prompt_text_handle = text(320,550,'','Color',[1 0.79 0.06],...
        'FontSize',24,'HorizontalAlignment','center');

%% run the stimulus presentation   
% to user: get ready?
waitforbuttonpress;
message.State = 'zero';
trial_counter = 0;
trial_duration = trial_duration;

if ~DEBUG,
sendEvent('stimulus.feedback','start');
end

% superloop
for trial_set = 1:number_of_trial_sets
    for trial = 1:trials_in_set
        
         if ~DEBUG
            % WARNIING! it is not a point when a game starts! I marked the game start below    
            sendEvent('stimulus.sequence','start');
         end
        % trial counter update
        trial_counter = trial_counter +1;
        G.Title = [title num2str(trial_counter) '/' num2str(number_of_trial_sets*trials_in_set)];
        
        % preparing stimuli order        
        if random_trial,
            stimuli = randperm(3);
        end
        
        for current_stimulus = stimuli
        % allocate index to stimulus name
            switch current_stimulus
                case RIGHT
                    cst = 'righthand';
                    sampleFb.Location = [450, 128];
                    feedback.Location = [450, 128];
                     if ~DEBUG, sendEvent('stimulus.targetSymbol','right'); end
                case LEFT
                    cst = 'lefthand';                
                    sampleFb.Location = [200, 158];
                    feedback.Location = [200, 158];
                    if ~DEBUG, sendEvent('stimulus.targetSymbol','left'); end
                case FEET
                    cst = 'feet';
                    sampleFb.Location = [250, 469];
                    feedback.Location = [250, 469];
                    if ~DEBUG, sendEvent('stimulus.targetSymbol','feet'); end
            end           
            
            % show cue and instruction
            feedback.State = 'zero';
            message.State = cst;
            sampleFb.State = cst;            

            % run game per trial                                   
            prediction = 0;
            right_prediction = 0;
            G.onKeyPress = @keypress_game;
            TSTART = tic;
            G.play(@action);

            % game finished -> feedback to user
            sampleFb.State = 'zero';
            
            if ~DEBUG,
            sendEvent('stimulus.sequence','end');
            end
            
            if right_prediction,
                % right attempt
                feedback.State = cst; % show graphical feedback
                message.State = 'Well done!';
                Scores(current_stimulus) = Scores(current_stimulus)+1;
            elseif prediction,
                % wrong attempt
                message.State = 'Better luck next time';
            else
                % no attempt
                message.State = 'actmore';
            end
            
            pause(fbDuration);
        end    
    end
    
    % intertrial relax:    
    if number_of_trial_sets~=trial_set,
        % show message and animatiion
        feedback.State = 'zero';
        message.State = 'relax';
        animation.Location = [365 100];
        % wait untill spacebar pressed
        G.onKeyPress = @keypress_relax;
        TSTART = tic;
        G.play(@action_relax);
        % hide animation
        animation.Location = [4000 330];
    end
end

if ~DEBUG,
sendEvent('stimulus.feedback','end');
end

% presentation is finished
% say thank to a user
feedback.State = 'zero';
message.State = 'thanks';
% pause 
waitforbuttonpress;
% destructor
warning ('on','all');
delete(gcf);

% scores report
Names = {'Right hand';'Left hand';'Feet'};
Trials = [1 1 1]'*number_of_trial_sets*trials_in_set;
Percentage = fix(100*Scores/Trials(1));
Percentage = strcat(num2str(Percentage),'%');
disp(game_title);
table(Scores,Trials, Percentage, 'RowNames',Names)

%% key press for game (trial)

% TODO Danny: Jason's code simulates button pressing
% just add to arrows the correct buttons 'a', 'w' ,...

function keypress_game(~,e)
    switch e.Key        
        case {'uparrow', 'w'}
            prediction = FEET;          
        case {'leftarrow', 'q'}
            prediction = LEFT;            
        case {'rightarrow', 'e'}
            prediction = RIGHT;
    end
end

%% key press for relax state
function keypress_relax(~,e)
    switch e.Key
        case 'space'
            G.stop();        
    end
end

%% Function: to be called on each tic/toc of each trial
function action
    % trial timeout
     if toc(TSTART)>trial_duration % stop processing
         G.stop();         
     end
     
     % handlers of buffer BCI events
     
     % TODO Danny: place here your code that connects to buffer and receives
     % user's prediction: prediction = RIGHT/LEFT/FEET
    if ~DEBUG,
    [devents,state]=buffer_newevents(buffhost,buffport,[],'classifier.prediction',[],0);
    pause(5);
    [devents,state]=buffer_newevents(buffhost,buffport,state,'classifier.prediction',[],0);
    if (~isempty(devents))
     for i=1:size(devents,1)
    [predVal(i),predict(i)] = max(devents(i).value);
     end
        for j=1:3
            pred(j)= sum(predict==j);
        end
        [x,pred]=max(pred);
        
        if pred == 3
            prediction = RIGHT;
        elseif pred == 2
            prediction = LEFT;
        elseif pred == 1
            prediction = FEET;
        end
    
    end
    end
    
     switch prediction
         case RIGHT
             if current_stimulus == RIGHT, % answer is correct
                 
                 % TODO Danny: put here your continous handler for RIGHT hand
                 
                 right_prediction = 1;
                 G.stop();
             end
         case LEFT
             if current_stimulus == LEFT, % answer is correct
                 
                 % TODO Danny: put here your continous handler for LEFT hand                                   
                 
                 right_prediction = 1;
                 G.stop();
             end
         case FEET 
             if current_stimulus == FEET, % answer is correct
                 
                 % TODO Danny: put here your continous handler for FEET

                 right_prediction = 1;
                 G.stop();
             end
     end     
end

%% Function: just play animation untill user press spacebar
function action_relax     
    % playing animation 
    if toc(TSTART)>0.05
         TSTART = tic;
         animation.cycleNext;
     end
     % clock code
     %set(prompt_text_handle,'String', 'Mandatory brake','FontSize',24);     
end

end % EOF
