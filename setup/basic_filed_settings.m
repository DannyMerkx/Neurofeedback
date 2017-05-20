menu_g = menu('Which game settings to save:',...
     'Game 0',...
     'Game 1',...
     'Game 2',...
     'Game 3');
 
    switch menu_g
        case 1
            % defaults 0
            game_title = 'Game 0: Learn/recall imagine movements';
            filename = 'parameters.mat';
            trial_duration = 10; % s
            number_of_trial_sets = 2;
            trials_in_set = 2;
            show_instr = 1; % shows insturction to a user if necessary
            warnings = 0; % switch off warnings if necessary
            
            fbDuration = 2; % !!! Former promptDuration            
            
            random_trial = 1; % DO NOT CHANGE
            cueDuration = 2;  % DO NOT CHANGE
        case 2
            % defaults 1
            game_title = 'Game 1: learning simple trial-fashion imagine movements';
            filename = 'parameters.mat';
            trial_duration = 2; % s
            number_of_trial_sets = 2;
            trials_in_set = 2;
            show_instr = 1; % shows insturction to a user if necessary
            warnings = 0; % switch on/off warnings during game
            fbDuration = 2; % feedback duration
            
            random_trial = 1; % if 1 trials (1 2 3) picked up randomly, of 0 one-by-one                        
            
            cueDuration = 2;  % DO NOT CHANGE        
        case 3 
            % defaults 2
            game_title = 'Game 2: learning continuous imagine movements';
            filename = 'parameters2.mat';
            trial_duration = 10; % one trial duration,s 
            number_of_trial_sets = 2; 
            trials_in_set = 2; % trials in one set (of trials)
            show_instr  = 0; % shows insturction to a user if necessary
            warnings = 0; % switch on/off warnings during game
            fbDuration  = 2; % feedback duration

            random_trial = 1; % if 1 trials (1 2 3) picked up randomly, of 0 one-by-one          
            cueDuration = 2; % cue message duration
            %GAME3 = 1; % if 0 - run game 2, if 1 - run game 3
            
        case 4

            % defaults 3
            game_title = 'Game 3: learning continuous imagine movements with distractors';
            filename = 'parameters3.mat';
            trial_duration = 10; % one trial duration,s 
            number_of_trial_sets = 3; 
            trials_in_set = 2; % trials in one set (of trials)
            show_instr  = 0; % shows insturction to a user if necessary
            warnings = 0; % switch on/off warnings during game
            fbDuration  = 2; % feedback duration

            random_trial = 1; % if 1 trials (1 2 3) picked up randomly, of 0 one-by-one            
            cueDuration = 2; % cue message duration
            %GAME3 = 1; % if 0 - run game 2, if 1 - run game 3
            menu_g = 3;
    end

save(['..\stimulus' num2str(menu_g-1) '\' filename],'game_title','trial_duration',...
    'number_of_trial_sets', 'trials_in_set', 'show_instr', 'warnings', 'random_trial', ...
    'fbDuration', 'cueDuration');





