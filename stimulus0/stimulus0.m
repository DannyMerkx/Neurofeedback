function stimulus0
%% stimulus 0 presentation 
DEBUG = 0; % turn off bufferBCI for debugging (if DEBUG==1)


% run ../../matlab/utilities/initPaths.m
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
fbDuration = 2; % duration of all the text promts
trial_duration = 10; % s
number_of_trial_sets = 2;
trials_in_set = 2;
show_instr = 1; % shows insturction to a user if necessary
warnings = 0; % switch off warnings if necessary
game_title = 'Game 0: Learn/recall imagine movements';
random_trial = 1; % DO NOT CHANGE
cueDuration = 2;  % DO NOT CHANGE

% path to media (img) NO SLASH AT THE END
img_path = '.'; 

% hidden scores - is printed into matlab output window after all
Scores = [0 0 0]'; 

% load parameters from file
try    
    load('parameters.mat');
end

% other parameters
screen_size = [1050 264]; % main screen size
title = 'Training: 0. Current trial '; % main screen (figure) title
RIGHT = 1; %flag of right hand movement
LEFT  = 2; %flag of left hand movement
FEET  = 3; %flag of feet movement

% switch off warnings if necessary
if ~warnings, warning ('off','all'); end

%% Start a new Game and apply a background image:
G = SpriteKit.Game.instance('Title',title,'Size',screen_size, 'ShowFPS', 0);

%% show instruction if necessary
if show_instr,
    fID = fopen('insturtions.txt');
    if fID>0, % no file - no isntructions
        lines = textscan(fID,'%s','delimiter','\n'); 
        fclose(fID);
        instr = lines{1};
        prompt_text_handle = text(30,140,instr,'Color',[0 0 0],...
        'FontSize',16,'HorizontalAlignment','left');        
        waitforbuttonpress;
        set(prompt_text_handle,'String', '','FontSize',16);
    end
end

%% loading media
% setting background
bkg = SpriteKit.Background([img_path '/img/bck.png']);

% preload animation sets
% left and right hand movement
animationRight = SpriteKit.Sprite('right');
animationLeft = SpriteKit.Sprite('left');
for k=1:10
    spritename = sprintf('r%d',k);
    pngFile = [img_path '/img/' spritename '.png'];
    animationRight.initState(spritename,pngFile,true);
    spritename = sprintf('l%d',k);
    pngFile = [img_path '/img/' spritename '.png'];
    animationLeft.initState(spritename,pngFile,true);
end
animationLeft.Location = [175, 512];
animationRight.Location = [875, 512];

% feet movement
animationFeet = SpriteKit.Sprite('feet');
for k=1:15
    spritename = sprintf('f%d',k);
    pngFile = [img_path '/img/' spritename '.png'];
    animationFeet.initState(spritename,pngFile,true);    
end
animationFeet.Scale = 0.25;
animationFeet.Location = [525, 512];

% handle for text messages
prompt_text_handle = text(530,140,'','Color',[1 1 1],...
        'FontSize',24,'HorizontalAlignment','center');

% to user: get ready?    
set(prompt_text_handle,'String', 'Prepare and get ready','FontSize',24);
pause(fbDuration);    
set(prompt_text_handle,'String', '','FontSize',24);

%% run the stimulus presentation
trial_counter = 0;
% superloop

if ~DEBUG,
sendEvent('stimulus.training','start');
end

for trial_set = 1:number_of_trial_sets
    
    if ~DEBUG
    % WARNIING! it is not a point when a game starts! I marked the game start below    
    sendEvent('stimulus.sequence','start');
    end
    
    for trial = 1:trials_in_set
        % trial counter update
        trial_counter = trial_counter +1;
        G.Title = [title num2str(trial_counter) '/' num2str(number_of_trial_sets*trials_in_set)];
        
        for current_stimulus = 1:3
            % showing cue                       
         
            switch current_stimulus
                case RIGHT                    
                    set(prompt_text_handle,'String', 'Imagine opening the right door','FontSize',24);
                    animation_step = 10/trial_duration;                   

                    if ~DEBUG, sendEvent('stimulus.targetSymbol','right'); end
                
                case LEFT                    
                    set(prompt_text_handle,'String', 'Imagine opening the left door','FontSize',24);
                    animation_step = 10/trial_duration;
                    
                    if ~DEBUG, sendEvent('stimulus.targetSymbol','left'); end
               
                case FEET                    
                    set(prompt_text_handle,'String', 'Imagine walking','FontSize',24);
                    animation_step = 6.5/trial_duration;
                    
                    if ~DEBUG, sendEvent('stimulus.targetSymbol','feet'); end
            end            
            
            % WARNING! you can send event about the current stimulus, by read value
            % from the variable current_stimulus, it can be RIGHT/LEFT/FEET 
            % (flags, defined on top of this file), once here. It will be
            % easy for you to handle it in SigProc and return the glag as a prediction.
            % example:
            % if ~DEBUG, sendEvent('stimulus.targetSymbol',current_stimulus); end         
            
            % clearing clue
            pause(fbDuration);
            set(prompt_text_handle,'String', '','FontSize',24);
            
            % showing the animated stumulus and reset to initial frame
            switch current_stimulus
                case RIGHT, 
                    animationRight.Location = [875, 128];
                    animationRight.State = 'r1';
                case LEFT,  
                    animationLeft.Location  = [175, 128];
                    animationLeft.State  = 'l1';
                case FEET,  
                    animationFeet.Location  = [525, 128];
                    animationFeet.State  = 'f1';
            end 
            
            % TODO Danny: a game starts here
            
            % run a game per trial                        
            prediction = 0;
            status = 0;
            G.onKeyPress = @keypress_game;
            TSTART = tic;            
            G.play(@action);

            % game finished -> feedback to user
            % clear screen
            animationFeet.Location = [525, 512];
            animationLeft.Location = [175, 512];
            animationRight.Location = [875, 512];
            
            if ~DEBUG,
            sendEvent('stimulus.sequence','end');
            end
            
            % adding a score if preicted events: correct > wrong            
            if status>0, Scores(current_stimulus) = Scores(current_stimulus)+1; end
            
            % show feedback message
            set(prompt_text_handle,'String', 'Well done!','FontSize',24);            
            pause(fbDuration);
            % clear feedback message
            set(prompt_text_handle,'String', '','FontSize',24);            
        end    
    end
    
    % intertrial relax:
    if number_of_trial_sets~=trial_set,
        % show message
        set(prompt_text_handle,'String', {'Pause between trials, you can relax now '; 'press the -spacebar- to go the next trial'}, 'FontSize',24);
        waitforbuttonpress;
        % clear  message
        set(prompt_text_handle,'String', '','FontSize',24);
    end
    
end

if ~DEBUG,
    sendEvent('stimulus.feedback','end');
end

% training is finished
% say thank to a user
set(prompt_text_handle,'String', 'Thank you for your participating', 'FontSize',24);
% pause 
pause(fbDuration);
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
% just add to arrows the correct buttons 'a', 'w' ,... and for keyrelase!

function keypress_game(~,e)
    switch e.Key        
        case {'uparrow',  'w'}
            if ~prediction,
                prediction = FEET;               
            end            
        case {'leftarrow','q'}
            if ~prediction,
                prediction = LEFT;
            end            
        case {'rightarrow', 'e'}
            if ~prediction,
                prediction = RIGHT;            
            end                 
    end
end

%% Function: to be called on each tic/toc of each trial
function action
    if toc(TSTART)>animation_step
        TSTART = tic;
        if strcmp(animationRight.State,'r10')||strcmp(animationLeft.State,'l10')||strcmp(animationFeet.State,'f15'),
            G.stop();
        end         
        animationRight.cycleNext;
        animationLeft.cycleNext;
        animationFeet.cycleNext;         
    end
    
    % TODO Danny: put here your code that takes prediction from buffer
    % LEFT/RIGHT/FEET    
    if ~DEBUG,
    [devents,state]=buffer_newevents(buffhost,buffport,[],'classifier.prediction',[],0);
    [devents,state]=buffer_newevents(buffhost,buffport,state,'classifier.prediction',[],100);
    if (~isempty(devents))
    [predVal,pred] = max(devents.value);
        if pred == 3
            prediction = RIGHT;
        elseif pred == 2
            prediction = LEFT;
        elseif pred == 1
            prediction = FEET;
        end
    end
    end
    
    % WARNING! prediction should be LEFT/RIGHT/FEET  or 0 if nothing received 
    % (i.e. which IM is catched) 
    % Danny, I am not sure that it is a good idea to use batch mode in
    % SigProc with several predictions or you should clamp them to one
    % (before switch prediction routine).
    
    % checking events and jump if necessary
    switch prediction
        case RIGHT 
            if current_stimulus == RIGHT,
                prediction = 0;
              
                % TODO Danny: put here your continous handler for RIGHT
                % hand (optional)
                 
                if strcmp(animationRight.State,'r10'),
                   G.stop();
                end            
                animationRight.cycleNext;  
                status = status + 1;
            else
                status = status - 1;
                prediction = 0;
            end
                 
        case LEFT
            if current_stimulus == LEFT,
                prediction = 0;
               
                % TODO Danny: put here your continous handler for LEFT 
                % hand (optional)                
                
                if strcmp(animationLeft.State,'l10'),
                   G.stop();
                end                
                animationLeft.cycleNext;
                status = status + 1;
            else
                status = status - 1;
                prediction = 0;
            end
            
        case FEET
            if current_stimulus == FEET,
                prediction = 0;
               
                % TODO Danny: put here your continous handler for FEET
                % (optional)
                 
                if strcmp(animationFeet.State,'f15'),
                    G.stop();
                end
                animationFeet.cycleNext; 
                status = status + 1;
            else
                status = status - 1;
                prediction = 0;
            end
     end     
end

end
%EOF