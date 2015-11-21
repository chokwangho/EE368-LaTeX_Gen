% Test Classifier/Matching
% EE368
% Nov 20, 2015

% Assume character palette has been created and saved out. If not, use
% importCharacterTemplates to do so
load('red_charPalette.mat');

%% Create identifiers for each character
for i = 1:length(chars)
    chars(i).ident = fn_createIdent(chars(i).img);
    % 0 out count for how many times that character is a false positive
    chars(i).wrong = 0;
    chars(i).match = [];
end

%% Train Nearest Neighbor Classifier
% Create data matrix for KNN Search with just original templates
X_orig = zeros(length(chars), length(chars(1).ident) + 1);
for i = 1:length(chars)
    X_orig(i,1:length(chars(1).ident)) = chars(i).ident;
    X_orig(i,end) = i;
end
% save('red_charPalette_Classifier.mat','X_orig');
% Results So Far: 68-70% Recognition with scaled iamges

%% Train Nearest Neighbor with Scaled Images
% num = 2; % Number of different sizes/scales to put in training matrix
% sizes = [.5 1];
% X_orig = zeros(num*length(chars), length(chars(1).ident));
% for j = 1:num
%     scl = sizes(j);
%     for i = 1:length(chars)
%         if(scl ~= 1)
%             img_scl = imresize(chars(i).img, scl);
%             % Threshold to binary again
%             th = graythresh(img_scl);
%             img_bin = img_scl;
%             img_bin(img_scl <= th) = 0;
%             img_bin(img_scl > th) = 1;
%             identity = fn_createIdent(img_bin);
%         else
%             identity = chars(i).ident;
%         end
%         X_orig(i+((j-1)*length(chars)),1:length(chars(1).ident)) = identity;
%         X_orig(i+((j-1)*length(chars)),end) = i;
%     end
% end
% % Results So Far: It is always 1.9%, thinks everything is first 1-3. Not
% % sure why that is

%% Find percentage correct with resized test images over entire palette
correct = 0;
total = 0;
numResize = 5;
scaleMatches = zeros(1,numResize);
for j = 1:length(chars)
    ident_testing = fn_resizeForTest(chars(j).img, numResize, .25, 1.25);
%     ident_testing = chars(j).ident;
    for i = 1:size(ident_testing,1)
       idx_hat = knnsearch(X_orig(:,1:length(chars(1).ident)),...
           ident_testing(i,:),'distance','cityblock');
       % Record what it thinks the match is
       chars(j).match = [chars(j).match X_orig(idx_hat,end)];
       if(j == X_orig(idx_hat,end))
           correct = correct + 1;
           % Increment the correct number for that scale
           scaleMatches(i) = scaleMatches(i) + 1;
       else
          % Mark which ones are common false matches
          chars(j).wrong = chars(j).wrong + 1;
       end
       total = total + 1;
    end
end

fprintf('Resized Test Images (%d) with KNNSEARCH:\n',numResize);
fprintf('# of Templates:%d\n',length(chars));
fprintf('# of Test Images:%d\n\n',total);
for i = 1:numResize
   fprintf('Correct for Scale %.2f: %.0f \t %.1f%%\n',...
        ((1.25-.25)/(numResize-1))*i, scaleMatches(i), (scaleMatches(i)/length(chars))*100);
end
fprintf('\nTotal Correct:\t\t%.0f \t %.1f%%\n',correct,(correct/total)*100);

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
% Correct for Scale 0.25: 84 	 70.6%
% Correct for Scale 0.50: 112 	 94.1%
% Correct for Scale 0.75: 116 	 97.5%
% Correct for Scale 1.00: 119 	 100.0%
% Correct for Scale 1.25: 112 	 94.1%
% 
% Total Correct:		543 	 91.3%

%% Show which characters are being mismatched with which

matches = [(1:length(chars))' cat(1,chars.match)];
matches_bool = matches(:,2:end) ~= repmat(matches(:,1),1,5);
scl = 5; %Pick a scale number (1 to numResize above)
[row, col] = find(matches_bool(:,scl));
figure(1);
for i = 1:length(row)
   subplot(2,length(row),i);
   imshow(chars(row(i)).img);
   subplot(2,length(row),i+length(row));
   imshow(chars(matches(row(i),scl+1)).img);
end

%% Test with input equation
dir = strcat(pwd,'/LaTeX Equations');
eq = im2double(rgb2gray(imread(strcat(dir,'/eq10_hr.jpg'))));

th = graythresh(eq);
eq_bin = eq;
eq_bin(eq <= th) = 0;
eq_bin(eq > th) = 1;

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
    subplot(2,length(eq_chars),i+length(eq_chars));
    imshow(chars(X_orig(idx_matched,end)).img);
    str = sprintf('Matched %d',X_orig(idx_matched,end));
    title(str);
end



