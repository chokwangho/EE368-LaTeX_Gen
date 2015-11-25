% Jim Brewer
% EE368
% Project
% Nov 11, 2015

clear all;
%% Create Test Sets with "true" characters for equation/code assembly
% Data Structure:
% Each entry in equations(i) is a structure containing the segmentation
% data from fn_segment in ".characters" and the filename of the original
% equation in ".filename"
% Within each "character(i)" is (all x,y w.r.t. original image, origin UL):
%     .centroid (1x2 vector of x,y position of centroid of character
%     .boundingbox (1x4 vector of x,y coord of upper left and x,y lengths
%     .img (matrix image of extracted character)
%     .char (string of actual letter or character)
% To extract single equation for testing (as if received from fn_segment),
%     run: eq = equations(i).characters;

path = 'LaTeX Equations/';
files = dir(strcat(path,'*.jpg'));

for i = 1:size(files,1)
    eq = im2double(rgb2gray(imread(strcat(path,files(i).name))));

    % Threshold image using Otsu's method
    th = graythresh(eq);
    eq_bin = eq;
    eq_bin(eq <= th) = 0;
    eq_bin(eq > th) = 1;

    equations(i).filename = files(i).name;
    equations(i).characters = fn_segment(eq_bin);
end

%% TODO - Manual Entry of correct Characters for each equation
% Currently use letter, number, or english spelling of each symbol

figure(1);
j=10;
numChars = size(equations(j).characters,2);
for i = 1:numChars
   subplot(2,ceil(numChars/2),i);
   imshow(equations(j).characters(i).img);
end

% Save out structure of equation data
% save('EquationTestData.mat','equations');




