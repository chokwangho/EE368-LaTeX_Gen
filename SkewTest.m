% skew_img = rgb2gray(imread('rotated_eq1.jpg'));
% non_skew = rgb2gray(imread('LaTeX Equations\eq1_hr.jpg'));
% thresh = graythresh(skew_img);
% bw_skew = im2bw(skew_img, thresh);

img = rgb2gray(imread('LaTeX Equations\eq3_hr.jpg'));

theta = 5;
rotated = imrotate(img,theta,'bilinear');
Mrot = ~imrotate(true(size(img)),theta,'bilinear');
rotated(Mrot&~imclearborder(Mrot)) = 255;
thresh = graythresh(rotated);
bw_skew = im2bw(rotated, thresh);

ang = fn_deskew(bw_skew)


