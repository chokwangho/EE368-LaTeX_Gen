% Jim Brewer
% EE368
% Project - Import Templates for Character Recognition
% Nov 18, 2015

dir = strcat(pwd,'/LaTeX Equations');
palette = im2double(rgb2gray(imread(strcat(dir,'/eq10.jpg'))));

th = graythresh(palette);
pal_bin = palette;
pal_bin(palette <= th) = 0;
pal_bin(palette > th) = 1;

chars = fn_segment(pal_bin, true);



