function eq_string = fn_assemble_eq( EqStruct )
%AssembleEquation Assembles an equation given a struct of extracted
%character information
%   Input: EquationStruct is a struct returned from the fn_segment
%   function. The struct will contain the following fields:
%       centroid - The centroid of the

% Create Greek letter recognition table
greeks = {
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
    };
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
            % Normal op
            if any(strcmp(detected,greeks))
                detected = ['\' detected ' '];
            end
            eq_string = [eq_string detected];
        case 1
            % Make sure the overlap is the next char
            assert(overlap_idx(i+1))
            overlap_char = chars(i+1).char;
            % Manually check for cases
            if strcmp(detected,'-') && strcmp(overlap_char,'-')
                eq_string = [eq_string '='];                
            end
            i = i+1; % Skip next char
            
    end
    i = i+1;
end


end

