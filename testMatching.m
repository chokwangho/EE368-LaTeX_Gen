% Test Classifier/Matching
% EE368
% Nov 20, 2015

% Assume character palette has been created and saved out. If not, use
% importCharacterTemplates to do so
load('red_charPalette_withText.mat');

%% Create identifiers for each character
for i = 1:length(chars)
    chars(i).ident = fn_createIdent(chars(i).img);
    % 0 out count for how many times that character is a false positive
    chars(i).wrong = 0;
end

%% Train Nearest Neighbor Classifier
% Create data matrix for KNN Search with just original templates
X_orig = zeros(length(chars), length(chars(1).ident) + 1);
for i = 1:length(chars)
    X_orig(i,1:length(chars(1).ident)) = chars(i).ident;
    X_orig(i,end) = i;
end
% save('red_charPalette_Classifier.mat','X_orig');

%% Find percentage correct with resized/rotated test images over entire palette
correct = 0;
total = 0;
% Scale Robustness Test
scale = false;
numResize = 4;
maxScale = 1.25;
minScale = .5;
% Skew Robustness Test
rotate = true;
numRot = 7;
minAng = -15;
maxAng = 15;
scaleMatches = zeros(1,numResize);
rotMatches = zeros(1,numRot);
for j = 1:length(chars)
    if(scale)
        ident_testing = fn_resizeForTest(chars(j).img, numResize, ...
            minScale, maxScale);
    elseif(rotate)
        ident_testing = fn_rotateForTest(chars(j).img, numRot, ...
            minAng, maxAng);
    end
    chars(j).match = [];
    for i = 1:size(ident_testing,1)
       idx_hat = knnsearch(X_orig(:,1:length(chars(1).ident)),...
           ident_testing(i,:),'distance','cityblock');
       % Record what it thinks the match is
       chars(j).match = [chars(j).match X_orig(idx_hat,end)];
       if(j == X_orig(idx_hat,end))
           correct = correct + 1;
           % Increment the correct number for that scale
           if(scale)
               scaleMatches(i) = scaleMatches(i) + 1;
           elseif(rotate)
               rotMatches(i) = rotMatches(i) + 1;
           end
       else
          % Mark which ones are common false matches
          chars(j).wrong = chars(j).wrong + 1;
       end
       total = total + 1;
    end
end

if(scale)
    fprintf('Resized Test Images (%d) with KNNSEARCH:\n',numResize);
    fprintf('# of Templates:%d\n',length(chars));
    fprintf('# of Test Images:%d\n\n',total);
    for i = 1:numResize
       fprintf('Correct for Scale %.2f: %.0f \t %.1f%%\n',...
            ((maxScale - minScale) / (numResize-1)) * (i-1) + minScale,...
            scaleMatches(i), (scaleMatches(i)/length(chars))*100);
    end
    fprintf('\nTotal Correct:\t\t%.0f \t %.1f%%\n',correct,(correct/total)*100);
elseif(rotate)
    fprintf('Rotated Test Images (%d) (CCW) with KNNSEARCH:\n',numRot);
    fprintf('# of Templates:%d\n',length(chars));
    fprintf('# of Test Images:%d\n\n',total);
    for i = 1:numRot
       fprintf('Correct for Rotation Angle %.0fDeg: %.0f \t %.1f%%\n',...
            ((maxAng - minAng) / (numRot - 1)) * (i-1) + minAng,...
            rotMatches(i), (rotMatches(i)/length(chars))*100);
    end
    fprintf('\nTotal Correct:\t\t%.0f \t %.1f%%\n',correct,(correct/total)*100);
end


% 80.3% Correct with 119 characters in reduced set using cityblock
% knnsearch and X_orig with no scaling additions
%
% With k = 8, ident=[I R1-R7 D2-D8]
% # of Templates:120
% # of Test Images:600
% Total Percent Correct:87.5
% 
% Percent Correct for Scale 0.25: 55.0
% Percent Correct for Scale 0.50: 88.3
% Percent Correct for Scale 0.75: 98.3
% Percent Correct for Scale 1.00: 100.0
% Percent Correct for Scale 1.25: 95.8
% 
% With Inverted characters for ident centroid
% Resized Test Images (5) with KNNSEARCH:
% # of Templates:119
% # of Test Images:595
% 
% Correct for Scale 0.25: 80 	 67.2%
% Correct for Scale 0.50: 109 	 91.6%
% Correct for Scale 0.75: 115 	 96.6%
% Correct for Scale 1.00: 119 	 100.0%
% Correct for Scale 1.25: 111 	 93.3%
% 
% Total Correct:		534 	 89.7%
%
% With Hu Moments as part of Ident
% Resized Test Images (5) with KNNSEARCH:
% # of Templates:119
% # of Test Images:595
% 
% Resized Test Images (5) with KNNSEARCH:
% # of Templates:119
% # of Test Images:595
% 
% Correct for Scale 0.25: 84 	 70.6%
% Correct for Scale 0.50: 111 	 93.3%
% Correct for Scale 0.75: 116 	 97.5%
% Correct for Scale 1.00: 119 	 100.0%
% Correct for Scale 1.25: 111 	 93.3%
% 
% Total Correct:		541 	 90.9%
%
% Less Scaling:
% Resized Test Images (4) with KNNSEARCH:
% # of Templates:119
% # of Test Images:476
% 
% Correct for Scale 0.50: 111 	 93.3%
% Correct for Scale 0.75: 116 	 97.5%
% Correct for Scale 1.00: 119 	 100.0%
% Correct for Scale 1.25: 111 	 93.3%
% 
% Total Correct:		457 	 96.0%
%
% Added closing to circular vectors
% Resized Test Images (4) with KNNSEARCH:
% # of Templates:118
% # of Test Images:472
% 
% Correct for Scale 0.50: 114 	 96.6%
% Correct for Scale 0.75: 116 	 98.3%
% Correct for Scale 1.00: 118 	 100.0%
% Correct for Scale 1.25: 113 	 95.8%
% 
% Total Correct:		461 	 97.7%
% 
% With circle counts normalized to hu moments mean (better here, worse on
% test equations)
% Resized Test Images (5) with KNNSEARCH:
% # of Templates:118
% # of Test Images:590
% 
% Correct for Scale 0.25: 107 	 90.7%
% Correct for Scale 0.50: 115 	 97.5%
% Correct for Scale 0.75: 117 	 99.2%
% Correct for Scale 1.00: 118 	 100.0%
% Correct for Scale 1.25: 117 	 99.2%
% 
% Total Correct:		574 	 97.3%
%
% Following are for corrected circular topology (not normalized, k+1)
% Rotated Test Images (5) (CCW) with KNNSEARCH:
% # of Templates:118
% # of Test Images:590
% 
% Correct for Rotation Angle -10Deg: 111 	 94.1%
% Correct for Rotation Angle -5Deg: 113 	 95.8%
% Correct for Rotation Angle 0Deg: 118 	 100.0%
% Correct for Rotation Angle 5Deg: 113 	 95.8%
% Correct for Rotation Angle 10Deg: 109 	 92.4%
% 
% Total Correct:		564 	 95.6%
% 
% Resized Test Images (4) with KNNSEARCH:
% # of Templates:118
% # of Test Images:472
% 
% Correct for Scale 0.50: 107 	 90.7%
% Correct for Scale 0.75: 115 	 97.5%
% Correct for Scale 1.00: 118 	 100.0%
% Correct for Scale 1.25: 116 	 98.3%
% 
% Total Correct:		456 	 96.6%

% With normalized circle topology, k+1.
% Rotated Test Images (7) (CCW) with KNNSEARCH:
% # of Templates:118
% # of Test Images:826
% 
% Correct for Rotation Angle -15Deg: 105 	 89.0%
% Correct for Rotation Angle -10Deg: 112 	 94.9%
% Correct for Rotation Angle -5Deg: 116 	 98.3%
% Correct for Rotation Angle 0Deg: 118 	 100.0%
% Correct for Rotation Angle 5Deg: 116 	 98.3%
% Correct for Rotation Angle 10Deg: 112 	 94.9%
% Correct for Rotation Angle 15Deg: 108 	 91.5%
% 
% Total Correct:		787 	 95.3%
%
% Resized Test Images (4) with KNNSEARCH:
% # of Templates:118
% # of Test Images:472
% 
% Correct for Scale 0.50: 115 	 97.5%
% Correct for Scale 0.75: 117 	 99.2%
% Correct for Scale 1.00: 118 	 100.0%
% Correct for Scale 1.25: 118 	 100.0%
% 
% Total Correct:		468 	 99.2%

%% Show which characters are being mismatched with which

matches = [(1:length(chars))' cat(1,chars.match)];
matches_bool = matches(:,2:end) ~= repmat(matches(:,1),1,numRot);
scl = 2; %Pick a scale number (1 to numResize above)
[row, col] = find(matches_bool(:,scl));
figure(1);
for i = 1:length(row)
   subplot(2,length(row),i);
   imshow(chars(row(i)).img);
   subplot(2,length(row),i+length(row));
   imshow(chars(matches(row(i),scl+1)).img);
end

%% Test with input equation
directory = strcat(pwd,'/Lighting');
% dir = strcat(pwd,'/Lighting');
% eq = im2double(rgb2gray(imread(strcat(dir,'/eq7_hr.jpg'))));
% th = graythresh(eq);
% eq_bin = eq;
% eq_bin(eq <= th) = 0;
% eq_bin(eq > th) = 1;

% eq_rot = imrotate(ones(size(eq))-eq,15);
% eq = ones(size(eq_rot)) - eq_rot;_test_lightin

eq = imread(strcat(directory,'/eq8_hr.jpg'));

% ang = 20;
% mask = true(size(eq(:,:,1)));
% mask_rot = imrotate(mask,ang);
% mask_rot = imerode(mask_rot,ones(4,4));
% eq = imrotate(eq,ang,'bilinear');
% eq(~repmat(mask_rot,1,1,3)) = 255;

eq_bin = fn_lighting_compensation(eq);
[eq_deskew, ~] = fn_deskew2(eq_bin,true);
eq_bin = eq_deskew;
figure(1);
imshow(eq_bin);

eq_chars = fn_segment(eq_bin);
for i = 1:length(eq_chars)
   eq_chars(i).ident = fn_createIdent(eq_chars(i).img); 
end

figure(2);
for i = 1:length(eq_chars)
    subplot(2,length(eq_chars),i);
    imshow(eq_chars(i).img);
    title('Input');
    
    idx_matched = knnsearch(X_orig(:,1:length(chars(1).ident)),...
        eq_chars(i).ident,'distance','cityblock');
    eq_chars(i).char = chars(X_orig(idx_matched,end)).char;
    subplot(2,length(eq_chars),i+length(eq_chars));
    imshow(chars(X_orig(idx_matched,end)).img);
    str = sprintf('Matched %d',X_orig(idx_matched,end));
    title(str);
end



