function stimulus2(GAME3)
%% stimulus 2 presentation 
DEBUG = 0; % turn off bufferBCI for debugging (if DEBUG==1)

if ~DEBUG,
% WARNING! hard-coded path
addpath(genpath('C:\Users\Beheerder\Documents\Computational Neuroscience\BCI practical\buffer_bci-mki46\'))
    
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
trial_duration = 10; % one trial duration,s 
number_of_trial_sets = 1; 
trials_in_set = 2; % trials in one set (of trials)
random_trial = 1; % if 1 trials (1 2 3) picked up randomly, of 0 one-by-one
show_instr  = 1; % shows insturction to a user if necessary
fbDuration  = 2; % feedback duration
cueDuration = 2; % cue message duration
warnings = 0; % switch on/off warnings during game
if ~exist('GAME3','var'), GAME3=0; end; % if 0 - run game 2, if 1 - run game 3

if ~GAME3,
    settingsFile = 'parameters2.mat';
    game_title = 'Game 2: learning continuous imagine movements';
else
    settingsFile = 'parameters3.mat';
    game_title = 'Game 3: learning continuous imagine movements with distractors';
end        

% matrix with constants for graphics
% col = game number
% row:         1 - number of frames
%              |   2 - scaling of an animal
%              |   |    3 - altitude of an animal
%              |   |    |    4 - scaling of the target
%              |   |    |    |     5 - rotation of the target
%              |   |    |    |     |   6 - animation step,s
%              |   |    |    |     |   |    7 - altitude of a target
%              |   |    |    |     |   |    |
img_preset = [ 8, 1.2, 090, 0.12, 0.0 0.07 80 ;... % goat
               4, 0.5, 150, 0.20, 0.0 0.20 80 ;... % bunny
              14, 0.7, 250, 0.50, 0.0 0.05 140];   % bird
          
animals_number = size(img_preset,1);

% load parameters from file
try    
    load(settingsFile);
end

% switch off warnings if necessary
if ~warnings, warning ('off','all'); end

% parameters of figure, size and title:
screen_size = [908 464]; 
title = ['Training: ' num2str(2+GAME3) '. Current trial '];

% constants , flags initials, and minor parameters
img_path = '.'; % path to media (img) NO SLASH AT THE END
stimuli = 1:3; % normal order of presentaion
Scores = [0 0 0]'; % hidden scores - is printed into matlab output window after all
prediction = 0; % info received from bufer
speed_step = 5;
LEFT  = 1; %flag
RIGHT = 2; %flag
FEET  = 3; %flag
GOAT  = 1; %flag
BUNNY = 2; %flag
BIRD  = 3; %flag
t_left = 180;
t_right = 760;
t_center = 454;
speed = 0;
mutex = 0;
status = 0;
reach_target = 0;

%% Start a new Game and apply a background image:
G = SpriteKit.Game.instance('Title',title,'Size',screen_size, 'ShowFPS', 0);

%% show instruction if necessary
if show_instr,
    fID = fopen('insturtions.txt');
    if fID>0, % no file - no isntructions
        lines = textscan(fID,'%s','delimiter','\n'); 
        fclose(fID);
        instr = lines{1};        
        prompt_text_handle = text(30,300,instr,'Color',[0 0 0],...
        'FontSize',16,'HorizontalAlignment','left');        
        waitforbuttonpress;
        set(prompt_text_handle,'String', '','FontSize',16);
    end
end

%% setting background
SpriteKit.Background([img_path '/img/bck.png']);

%% preload graphics
% messages
message = SpriteKit.Sprite('messages');
message.initState('welldone',[img_path '/img/welldone.png'],true); % well done feedback
message.initState('righthand',[img_path '/img/rh.png'],true); % command door - right hand
message.initState('lefthand',[img_path '/img/lh.png'],true); % command window - left hand
message.initState('feet',[img_path '/img/feet.png'],true); % command feet - cockloft
message.initState('thanks',[img_path '/img/thanks.png'],true); % thanks for playing
message.initState('ready',[img_path '/img/ready.png'],true); % ready for playing?
message.initState('zero', [img_path '/img/zero.png' ],true); %
message.initState('actmore',[img_path '/img/actmore.png'],true); % relax between trials
message.initState('nobad',[img_path '/img/nobad.png'],true); % relax between trials
message.Location = [454, 380];
message.State = 'ready';

% games graphics 
goatL  = SpriteKit.Sprite('A1L');
goatR  = SpriteKit.Sprite('A1R');
bunnyL = SpriteKit.Sprite('A2L');
bunnyR = SpriteKit.Sprite('A2R');
birdL  = SpriteKit.Sprite('A3L');
birdR  = SpriteKit.Sprite('A3R');
    
% loading frames of animation
for frame_index = 1:img_preset(1,1)
    % animation for left oriented goat
    pngFile = [img_path '/img/A1L' num2str(frame_index) '.png'];
    goatL.initState(['A1L' num2str(frame_index) ],pngFile,true);        
    % animation for right oriented goat      
    pngFile = [img_path '/img/A1R' num2str(frame_index) '.png'];
    goatR.initState(['A1R' num2str(frame_index) ],pngFile,true);
end
for frame_index = 1:img_preset(2,1)    
    % animation for left oriented bunny
    pngFile = [img_path '/img/A2L' num2str(frame_index) '.png'];
    bunnyL.initState(['A2L' num2str(frame_index) ],pngFile,true);        
    % animation for right oriented bunny      
    pngFile = [img_path '/img/A2R' num2str(frame_index) '.png'];
    bunnyR.initState(['A2R' num2str(frame_index) ],pngFile,true);         
end
for frame_index = 1:img_preset(3,1)
    % animation for left oriented bird
    pngFile = [img_path '/img/A3L' num2str(frame_index) '.png'];
    birdL.initState(['A3L' num2str(frame_index) ],pngFile,true);        
    % animation for right oriented goat      
    pngFile = [img_path '/img/A3R' num2str(frame_index) '.png'];
    birdR.initState(['A3R' num2str(frame_index) ],pngFile,true);        
end
    
% scaling animal images
goatL.Scale = img_preset(1,2);
goatR.Scale = img_preset(1,2);
bunnyL.Scale = img_preset(2,2);
bunnyR.Scale = img_preset(2,2);
birdL.Scale = img_preset(3,2);
birdR.Scale = img_preset(3,2);    
   
% preload targets
target  = SpriteKit.Sprite('targets');
target.initState('T1',[img_path '/img/T1.png'],true);
target.initState('T2',[img_path '/img/T2.png'],true);
target.initState('T3',[img_path '/img/T3.png'],true);

% preload fake targets
fake_target  = SpriteKit.Sprite('fake_targets');
fake_target.initState('T1',[img_path '/img/T1.png'],true);
fake_target.initState('T2',[img_path '/img/T2.png'],true);
fake_target.initState('T3',[img_path '/img/T3.png'],true);   
    
%% run the stimulus presentation   
% to user: get ready?
waitforbuttonpress;
message.State = 'zero';
trial_counter = 0;

% initial states of animation of animals
birdR.State = 'A3R1';
bunnyR.State = 'A2R1';
goatR.State = 'A1R1';
birdL.State = 'A3L1';
bunnyL.State = 'A2L1';
goatL.State = 'A1L1';

if ~DEBUG,
sendEvent('stimulus.feedback','start');
end

% superloop
for trial_set = 1:number_of_trial_sets
    for trial = 1:trials_in_set
        
        if ~DEBUG, sendEvent('stimulus.sequence','start'); end
        % trial counter update
        trial_counter = trial_counter +1;
        G.Title = [title num2str(trial_counter) '/' num2str(number_of_trial_sets*trials_in_set)];     
        
        % preparing stimuli order        
        if random_trial, stimuli = randperm(3); end
        
        % loop for a trial
        for current_stimulus = stimuli
            
            CLS(1); % clear screen: rid off animals and targets            

            % random selecting animal
            speed = 0;
            animal = datasample(1:animals_number,1);
            
            % random pick up a fake target from the rest
            fake_target_list = 1:3;
            fake_target_list(animal) = [];
            fake_t = datasample(fake_target_list,1);
            fake_target.State = ['T' num2str(fake_t)];
            fake_target.Scale = img_preset(fake_t,4);       
            
            % preparing real target to show
            animation_step = img_preset(animal,6);
            target.State = ['T' num2str(animal)];
            target.Scale = img_preset(animal,4);                       
            
            % settings direction of an animal (feet - randomly)
            % and showing cue message            
            direction = current_stimulus;            
            switch current_stimulus
                case RIGHT, message.State = 'righthand'; % show message
                    if ~DEBUG, sendEvent('stimulus.targetSymbol','right'); end
                case LEFT,  message.State = 'lefthand'; % show message
                    if ~DEBUG, sendEvent('stimulus.targetSymbol','left'); end
                case FEET,  message.State = 'feet'; % show message
                    if ~DEBUG, sendEvent('stimulus.targetSymbol','feet'); end
                            % random sample direction for feet                    
                            direction = datasample(LEFT:RIGHT,1);
            end
            animated_direction = direction;
            pause(cueDuration); % showing cue message
            
            % showing animals and targets
            animal_initial_position = t_center;
            switch direction
                case LEFT
                    target.Location = [t_left, img_preset(animal,7)];  % show target                          
                    
                    if ~GAME3, animal_initial_position = t_right;
                    else       fake_target.Location = [t_right, img_preset(fake_t,7)]; % show target
                    end
                    
                    position = [animal_initial_position, img_preset(animal,3)];
                    setAnimal(animal, direction);                    
                    
                case RIGHT
                    target.Location = [t_right, img_preset(animal,7)];  % show target                          
                    
                    if ~GAME3, animal_initial_position = t_left;
                    else       fake_target.Location = [t_left, img_preset(fake_t,7)]; % show target
                    end
            end            
            position = [animal_initial_position, img_preset(animal,3)];
            setAnimal(animal, direction);            

            
            % TODO Danny: there is stimulus presentation starts
            
            
            % run game per trial                        
            prediction = 0;
            status = 0;
            reach_target = 0;            
            G.onKeyPress = @keypress;
            G.onKeyRelease = @keyrelease;
            TSTART  = tic;
            TSTARTA = tic;
            G.play(@action);

            % game finished -> feedback to user
            
            % TODO Danny: there is stimulus presentation ended
            if ~DEBUG,sendEvent('stimulus.sequence','end'); end
            % feedback message and scores
            if status > 0,
                if reach_target,
                    % reach the target + right answers> wrong ones = WIN
                    message.State = 'welldone';
                    Scores(current_stimulus) = Scores(current_stimulus)+1;
                else            
                    % reach the target + right answers < wrong ones = NOBAD
                    message.State = 'nobad';
                end
            else
                % no attempt or
                % right answers < wrong ones = LOSE
                message.State = 'actmore';
            end                       
            % message is showing
            pause(fbDuration);
        end    
    end
    
    % intertrial relax        
    if number_of_trial_sets~=trial_set,
        % clear screen
        CLS(1); 
        message.State = 'zero';
        % black screen and message show
        SpriteKit.Background([img_path '/img/bck_black.png']);               
        waitforbuttonpress;        
        % resetting background
        SpriteKit.Background([img_path '/img/bck.png']);
    end
end

if ~DEBUG,sendEvent('stimulus.feedback','end'); end
% presentation of stimulus is finished
% say thank to a user

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

%% key press/release for game (trial)

% TODO Danny: Jason's code simulates button pressing
% just add to arrows the correct buttons 'a', 'w' ,...

function keypress(~,e)
    switch e.Key        
        case {'uparrow', 'w'}
            mutex = FEET;          
        case {'leftarrow', 'q'}
            mutex = LEFT;            
        case {'rightarrow', 'e'}
            mutex = RIGHT;
    end
end

function keyrelease(~,e)
    switch e.Key        
        case {'uparrow', 'w'}
            if mutex == FEET,
                prediction = FEET;          
                mutex = 0;
            end
            
        case {'leftarrow', 'q'}
            if mutex == LEFT,
                prediction = LEFT;          
                mutex = 0;
            end
            
        case {'rightarrow', 'e'}
            if mutex == RIGHT,
                prediction = RIGHT;
                mutex = 0;
            end                        
    end
end

%% Function: to be called on each tic/toc of each trial
% gameplay
function action
    % trial timeout
    if toc(TSTART)>trial_duration, % stop processing        
        G.stop();         
    end
    

    % animation cycle of an animal
    if toc(TSTARTA)>(1+GAME3)*animation_step/(speed+1),
       TSTARTA = tic;       
       goatR.cycleNext;
       bunnyR.cycleNext;
       birdR.cycleNext;       
       goatL.cycleNext;
       bunnyL.cycleNext;
       birdL.cycleNext;              
    end
    
    % animal speed decay
    speed = speed - 0.025*(abs(status)+1)*(1+~GAME3*2);
    if speed<0, speed = 0; end    
    
    % animal speedup parameter
    speedup = ~GAME3*trial_duration/(15*(1+GAME3))+speed;    
    
    % update an animal position 
    switch animated_direction
        case RIGHT            
            position(1) = position(1) + speedup;
            if position(1)>t_right-50,                         
                if direction==RIGHT, reach_target = 1; end
                G.stop();
            end
        
            switch animal
                case GOAT,  goatR.Location(1)  = position(1);
                case BUNNY, bunnyR.Location(1) = position(1);
                case BIRD,  birdR.Location(1)  = position(1);
            end
            
        case LEFT
            position(1) = position(1) - speedup;
            if position(1)<t_left+50,                         
                if direction==LEFT, reach_target = 1; end
                G.stop();
            end
        
            switch animal
                case GOAT,  goatL.Location(1)  = position(1);
                case BUNNY, bunnyL.Location(1) = position(1);
                case BIRD,  birdL.Location(1)  = position(1);
            end
    end
         
     
    % handlers of buffer BCI events
    
    % TODO Danny: place here your code that connects to buffer and receives
    % user's prediction: prediction = RIGHT/LEFT/FEET
    if ~DEBUG,
    [devents,state]=buffer_newevents(buffhost,buffport,[],'classifier.prediction',[],0);
    [devents,state]=buffer_newevents(buffhost,buffport,state,'classifier.prediction',[],600);
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
     
    switch prediction
        case RIGHT
            if current_stimulus==RIGHT, command(1);             
            else command(0); end            
        case LEFT
            if current_stimulus==LEFT, command(1);
            else command(0); end
        case FEET
            if current_stimulus==FEET, command(1);
            else command(0); end        
    end
    
end

%% clear screen: rid off animals and targets
function CLS(th)
	% th = 1, rid off animals and targets
    % th = 0, rid off animals only
    goatR.Location(2)  = 1000;
    goatL.Location(2)  = 1000;
    bunnyR.Location(2) = 1000;
    bunnyL.Location(2) = 1000;
    birdR.Location(2)  = 1000;
    birdL.Location(2)  = 1000;
    if th,
        target.Location = [1000, 1000];
        fake_target.Location = [1000, 1000];
    end
end

%% set animal and direction
function setAnimal(an, dir)
    animal = an;
    position(2) = img_preset(animal,3);
    CLS(0);
    switch dir
        case LEFT          
            switch animal
                case GOAT,  goatL.Location  = position;                            
                case BUNNY, bunnyL.Location = position;
                case BIRD,  birdL.Location  = position;                            
            end
            
        case RIGHT           
            switch animal
                case GOAT,  goatR.Location  = position;                            
                case BUNNY, bunnyR.Location = position;
                case BIRD,  birdR.Location  = position;                            
            end
    end
end

%% user command handler
function command(correct)    
if correct, % answer is correct                 
    if animated_direction==direction,
        speed = speed +speed_step/(1+GAME3);
    else
        speed = speed -speed_step/(1+GAME3);
    end
	status = status +1;
else
    if animated_direction==direction,
        speed = speed -speed_step/(1+GAME3);                                                      
    else
        speed = speed +speed_step/(1+GAME3);
    end
    status = status -1;
end
prediction = 0;
% change animal direction of movement if necessary
if speed<0&&GAME3,        
    switch animated_direction
        case LEFT
            setAnimal(animal,RIGHT);
            animated_direction=RIGHT;
        case RIGHT
            setAnimal(animal,LEFT);
            animated_direction=LEFT;
    end
end    
    
end

end % EOF
