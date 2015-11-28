function eq_string = fn_assemble_eq( EqStruct )
%AssembleEquation Assembles an equation given a struct of extracted
%character information
%   Input: EquationStruct is a struct returned from the fn_segment
%   function. The struct will contain the following fields:
%       centroid - The centroid of the

% Create control sequence recognition table
control = help_create_control;

% Set white space threshold in pixels for letters
space = 10;

% Set sub/superscript threshold as fraction of height
script_perc = 0.5;

eq_string = '';
chars = EqStruct.characters;
num_chars = length(chars);
% Bounding boxes format:
% Upper left x, Upper left y, width, height
boxes = zeros(4,num_chars);

% Get boundingbox info
for i = 1:num_chars
    boxes(:,i) = chars(i).boundingbox;
end

% Make sure characters are sorted by upper left bound
[~, idxs] = sort(boxes(1,:));
chars = chars(idxs);
boxes = boxes(:,idxs);

% Get eqn height to detect exponents
eqn_height = help_get_eqn_height(chars);
prev_fraction = false; % Don't check for exponents if previously saw a fraction

% Loop through chars and create string
i = 1;
while i <= num_chars
    detected = chars(i).char;
    ul_coord = boxes(1,i);
    ur_coord = ul_coord+boxes(3,i);
    
    % Get overlaps
    overlap_idx = boxes(1,:)>=ul_coord & boxes(1,:)<=ur_coord;
    overlap_idx(1:i) = false;
    % Check to see how many overlaps there are
    num_overlaps = sum(overlap_idx);
    switch num_overlaps
        case 0
            
            % Check for super and sub scripts by comparing lower left with
            % previous char, unless previous character was a fraction
            if i-1 > 0 && ~prev_fraction
                ll_coord = boxes(2,i)+boxes(4,i);
                prev_centroid = chars(i-1).centroid(2);
                ll_diff = ll_coord-prev_centroid;
                ul_diff = boxes(2,i) - prev_centroid;
                if ll_diff <= 0 && boxes(4,i)<= script_perc*eqn_height
                    % Superscript
                    super_eq_struct.filename = '';
                    super_eq_struct.characters = chars(i);
                    super_str = fn_assemble_eq(super_eq_struct);
                    detected = ['^{' super_str '}'];
                elseif ul_diff >= 0 && boxes(4,i)<= script_perc*eqn_height
                    % Subscript
                    sub_eq_struct.filename = '';
                    sub_eq_struct.characters = chars(i);
                    sub_str = fn_assemble_eq(sub_eq_struct);
                    detected = ['_{' sub_str '}'];
                else
                    % Normal op
                    prev_fraction = false;
                    
                    % Store centroid to check for exponents
                    prev_centroid = chars(i).centroid(2);
                    if any(strcmp(detected,control))
                        detected = ['\' detected ' '];
                    end
                    
                    % Insert space if needed between letters
                    if i+1 <= num_chars && help_is_letter(detected) && help_is_letter(chars(i+1).char)
                        dist_to_next = boxes(1,i+1)-ur_coord;
                        if dist_to_next >= space
                            detected = [detected ' '];
                        end
                    end
                end
            else
                % Normal op
                prev_fraction = false;
                
                % Store centroid to check for exponents
                prev_centroid = chars(i).centroid(2);
                if any(strcmp(detected,control))
                    detected = ['\' detected ' '];
                end
                
                % Insert space if needed between letters
                if i+1 <= num_chars && help_is_letter(detected) && help_is_letter(chars(i+1).char)
                    dist_to_next = boxes(1,i+1)-ur_coord;
                    if dist_to_next >= space
                        detected = [detected ' '];
                    end
                end
            end
            eq_string = [eq_string detected];
        case 1
            % Make sure the overlap is the next char
            assert(overlap_idx(i+1))
            % Check if overlap is trivial
            overlap_ul = boxes(1,i+1);
            if abs(overlap_ul-ur_coord) <= 1
                % Normal op
                if any(strcmp(detected,control))
                    detected = ['\' detected ' '];
                end
                
                % Insert space if appropriate
                if i+1 <= num_chars && help_is_letter(detected) && help_is_letter(chars(i+1).char)
                    dist_to_next = boxes(1,i+1)-ur_coord;
                    if dist_to_next >= space
                        detected = [detected ' '];
                    end
                end
                eq_string = [eq_string detected];
            else
                
                overlap_char = chars(i+1).char;
                % Manually check for cases
                if strcmp(detected,'-') && strcmp(overlap_char,'-')
                    eq_string = [eq_string '='];
                end
                i = i+1; % Skip next char
            end
        otherwise
            % Grab the overlapped characters
            overlap_idx(i) = true;
            overlap_chars = chars(overlap_idx);
            % If just one '-', then it is a fraction
            if sum(strcmp('-',{overlap_chars.char}))==1
                prev_fraction = true;
                % Find the bar
                if strcmp(detected,'-')
                    % Easy case when we already have the bar
                    frac_height = chars(i).centroid(2);
                    numer_idx = false(1,length(overlap_chars));
                    denom_idx = numer_idx;
                    for frac_idx = 1:length(overlap_chars)
                        if ~strcmp(overlap_chars(frac_idx).char,'-')
                            if overlap_chars(frac_idx).centroid(2) < frac_height
                                numer_idx(frac_idx) = true;
                            elseif overlap_chars(frac_idx).centroid(2) > frac_height
                                denom_idx(frac_idx) = true;
                            end
                        end
                    end
                    numer_eq_struct.filename = '';
                    numer_eq_struct.characters = overlap_chars(numer_idx);
                    denom_eq_struct.filename = '';
                    denom_eq_struct.characters = overlap_chars(denom_idx);
                    
                    numer_str = fn_assemble_eq(numer_eq_struct);
                    denom_str = fn_assemble_eq(denom_eq_struct);
                    
                    detected = ['\frac_{' denom_str '}^{' numer_str '}'];
                    
                    % Set counter to next character
                    i = find(overlap_idx,1,'last');
                end
            end
            eq_string = [eq_string detected];
    end
    i = i+1;
end


end

function control = help_create_control()
control = {
    'alpha'
    'beta'
    'gamma'
    'delta'
    'epsilon'
    'zeta'
    'eta'
    'theta'
    'iota'
    'kappa'
    'lambda'
    'mu'
    'nu'
    'xi'
    'pi'
    'rho'
    'sigma'
    'tau'
    'upsilon'
    'phi'
    'chi'
    'psi'
    'omega'
    
    'Alpha'
    'Beta'
    'Gamma'
    'Delta'
    'Epsilon'
    'Zeta'
    'Eta'
    'Theta'
    'Iota'
    'Kappa'
    'Lambda'
    'Mu'
    'Nu'
    'Xi'
    'Pi'
    'Rho'
    'Sigma'
    'Tau'
    'Upsilon'
    'Phi'
    'Psi'
    'Omega'
    'int'
    'rightarrow'
    };
end

function out =  help_is_letter(str)
    out = length(str)==1 && isstrprop(str,'alpha');
end

function eq_height = help_get_eqn_height(chars)
    % Heuristic: max height of a character
    eq_height = 0;
    for i = 1:length(chars)
        if chars(i).boundingbox(4) > eq_height
            eq_height = chars(i).boundingbox(4);
        end
    end
end

