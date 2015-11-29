function [ deskew_img ] = fn_deskew2( bw_img )

% pre_theta = 10;
% rotated = imrotate(bw_img,pre_theta);
% Mrot = ~imrotate(true(size(bw_img)),pre_theta);
% rotated(Mrot&~imclearborder(Mrot)) = 255;

edges = edge(bw_img,'canny');
[H,T,~] = hough(edges,'RhoResolution',1,'ThetaResolution', 0.1 );

P = houghpeaks(H,1);

deskewing_angle = T(P(1,2))-90; 
% deskewing_angle = deskewing_angle+pre_theta;
deskew_img = deskewing_angle;
end