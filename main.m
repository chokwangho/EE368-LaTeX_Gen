% - Main File To Execute Program
% EE368 - Aut 15 - Project
% Nov 20, 2015
% 
% Main file to execute the detection and LaTeX code generation and output.
% To run, set the directory and file name under "dir" and "eq" and ensure
% the template character and identity *.mat files are available, then run
% the entire script.

clear all;
close all;
showFigs = true;

%% Load Template Character Template Data and Identity Info
% If not available, see importCharacterTemplates.m to create
load('red_charPalette_withText.mat');
load('red_charPalette_Classifier.mat');

%% Read in desired equation and convert to double grayscale
dir = strcat(pwd,'/LaTeX Equations/');
fileName = 'demo_equation.jpg';
eq = imread(strcat(dir,fileName));
% eq = imrotate(ones(size(eq)) - im2double(eq),10,'bilinear');
% eq = ones(size(eq)) - eq;

%% Optimize page and binarize
eq_bin = fn_lighting_compensation(eq);
if(showFigs)
    figure(1);
    imshow(eq_bin);
end

[eq_deskew, ang] = fn_deskew2(eq_bin,true,true,3);

% deskewed = imrotate(eq,ang);
% mask = true(size(eq(:,:,1)));
% mask_rot = imrotate(mask,ang);
% mask_rot = imerode(mask_rot,ones(2,2));
% 
% eq_deskew = fn_lighting_compensation(deskewed);
% eq_deskew(~mask_rot) = true;
% eq_deskew = fn_soften_edges(eq_deskew,3);

if(showFigs)
    figure(2);
    imshow(eq_deskew);
end

% TESTING code to binarize until optimize page code finished
% eq = im2double(rgb2gray(eq));
% th = graythresh(eq);
% eq_bin = eq;
% eq_bin(eq <= th) = 0;
% eq_bin(eq > th) = 1;
% eq_deskew = eq_bin;

%% Segment Equation Characters and Create Identifier
if(showFigs)
    eq_chars = fn_segment(eq_deskew,true,3);
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
    
    % OPTIONAL: Code to show input characters and their determined matches
    if(showFigs)
        figure(5);
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
disp(eq_string);

%% Output LaTeX Code
writeTex(eq_string, strcat(dir,fileName(1:end-4)));


