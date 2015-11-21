% Project - Import Templates for Character Recognition
% Jim Brewer
% EE368
% Nov 18, 2015

dir = strcat(pwd,'/LaTeX Equations');
palette = im2double(rgb2gray(imread(strcat(dir,'/reduced_characterPalette.jpg'))));

th = graythresh(palette);
pal_bin = palette;
pal_bin(palette <= th) = 0;
pal_bin(palette > th) = 1;
%% Extract character templates
chars = fn_segment(pal_bin, true);

% TODO: Add "truth" labels.

% Remove doubles from non-contigous characters


%% Save out character palette
% save('red_charPalette.mat','chars');
