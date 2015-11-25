% - Main File To Execute Program
% EE368 - Aut 15 - Project
% Nov 20, 2015
% 
clear all;
close all;

%% Load Template Character Template Data and Identity Info
% If not available, see importCharacterTemplates.m to create
load('red_charPalette_withText.mat');
load('red_charPalette_Classifier.mat');

%% Read in desired equation and convert to double grayscale
dir = strcat(pwd,'/LaTeX Equations');
eq = im2double(rgb2gray(imread(strcat(dir,'/eq10-2_hr.jpg'))));

%% Optimize page and binarize

% TESTING code to binarize until optimize page code finished
th = graythresh(eq);
eq_bin = eq;
eq_bin(eq <= th) = 0;
eq_bin(eq > th) = 1;

%% Segment Equation Characters and Create Identifier
eq_chars = fn_segment(eq_bin);
for i = 1:length(eq_chars)
   eq_chars(i).ident = fn_createIdent(eq_chars(i).img); 
end

%% Match Characters (pass in struct of segmented chars and related info. 
for i = 1:length(eq_chars)
    idx_matched = knnsearch(X_orig(:,1:length(chars(1).ident)),...
            eq_chars(i).ident,'distance','cityblock');
    % Set the matched character value
    eq_chars(i).char = chars(X_orig(idx_matched,end)).char;
    
    % OPTIONAL: Code to show input characters and their determined matches
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

%% Pass struct of segmented characters (eq_chars) with matched character 
% data to equation creator

%% Output LaTeX Code