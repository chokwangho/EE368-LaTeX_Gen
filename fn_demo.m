function [ eq_string , outfile ] = fn_demo( filePath, showFigs, outputName )
%FN_DEMO Demonstrate the LaTeX equation assembler
%   This function is a modified version of fn_main that looks in specific
%   directories, developed for the EE368 poster session held on December 2,
%   2015.
%
%   filePath: Full file path to jpg input image

%   showFigs: Set true to show all figure outputs of process. default is false
%   outputName: Optional filename for output .tex file (no extension). If
%       none specified, will use input file name.
%
%   eq_string: Returns the string of the equation LaTeX code.

[~,fileName,~] = fileparts(filePath);

if nargin == 1
    showFigs = false;
    outputName = fileName;
elseif nargin == 2
    outputName = fileName;
end

% Get directory
my_full_path = which('fn_demo');
[file_dir,~,~] = fileparts(my_full_path);

cur_dir = pwd;
cd(file_dir);


%% Load Template Character Template Data and Identity Info
% If not available, see importCharacterTemplates.m to create
load('red-charPalette_withText_demo3.mat');
load('red-charPalette_Classifier_demo3.mat');
load('equation_truth_mod.mat');

%% Read in desired equation
eq = imread(filePath);
if(showFigs)
    figure(1);
    imshow(eq);
end

%% Optimize page and binarize
eq_bin = fn_lighting_compensation(eq);
if(showFigs)
    figure(2);
    imshow(eq_bin);
end

[eq_deskew, ~] = fn_deskew2(eq_bin,true,true, 3);

% eq = im2double(rgb2gray(eq));
% th = graythresh(eq);
% eq_bin = eq;
% eq_bin(eq <= th) = 0;
% eq_bin(eq > th) = 1;
% eq_deskew = eq_bin;
% disp(th);

if(showFigs)
    figure(3);
    imshow(eq_deskew);
end



%% Segment Equation Characters and Create Identifier
if(showFigs)
    eq_chars = fn_segment(eq_deskew,true,4);
else
    eq_chars = fn_segment(eq_deskew);
end
for i = 1:length(eq_chars)
   eq_chars(i).ident = fn_createIdent(eq_chars(i).img); 
end

%% Match Characters (pass in struct of segmented chars and related info. 
for i = 1:length(eq_chars)
    idx_matched = knnsearch(X_orig(:,1:length(chars(1).ident)),...
            eq_chars(i).ident,'distance','cityblock');
    % Set the matched character value
    eq_chars(i).char = chars(X_orig(idx_matched,end)).char;
    
    % Code to show input characters and their determined matches
    if(showFigs)
        figure(6);
        subplot(2,length(eq_chars),i);
        imshow(eq_chars(i).img);
        title('Input');
        subplot(2,length(eq_chars),i+length(eq_chars));
        imshow(chars(X_orig(idx_matched,end)).img);
        if(eq_chars(i).char(1) == '\')
            printChar = strcat('\',eq_chars(i).char);
        else
           printChar = eq_chars(i).char;
        end
        str = sprintf('Match: %s',printChar);
        title(str);
    end
end

%% Pass struct of segmented characters (eq_chars) with matched character 
% data to equation creator

EqStruct.characters = eq_chars;
eq_string = fn_assemble_eq(EqStruct);

%% Output LaTeX Code
writeTex(eq_string, fullfile(cur_dir,outputName));
outfile = fullfile(cur_dir,outputName);
cd(cur_dir);

end

