function [ deskew_img, deskewing_angle ] = fn_deskew2( bw_img, fill_flag, soften_flag, soften_size )
%FN_DESKEW2 Deskews an image using the hough transform
% Optional args:
%   fill_flag: if true: pads deskew_img with high values (whitespace) when
%                   rotating.
%   soften_flag: if true: Softens the image using the fn_soften_edges
%                   function.

% pre_theta = 10;
% rotated = imrotate(bw_img,pre_theta);
% Mrot = ~imrotate(true(size(bw_img)),pre_theta);
% rotated(Mrot&~imclearborder(Mrot)) = 255;
switch nargin
    case 1
        fill_flag = false;
        soften_flag = false;
        soften_size = 0;
    case 2
        soften_flag = false;
        soften_size = 0;
    case 3
        soften_size = 5;
end

edges = edge(bw_img);
[H,T,~] = hough(edges,'RhoResolution',1,'ThetaResolution', 0.1 );

%% Previous Implementation
% P = houghpeaks(H,1);

% deskewing_angle = T(P(1,2))-90;

% while(-deskewing_angle > 40)
%     deskewing_angle = deskewing_angle + 180;
% end

%% Current Implementation
P = houghpeaks(H,4);

dominant_orientation = mode(P(:,2));
if length(dominant_orientation) > 1
    dominant_orientation = dominant_orientation(1);
end
deskewing_angle = T(dominant_orientation)-90;


while(abs(deskewing_angle) > 40)
    deskewing_angle = deskewing_angle - sign(deskewing_angle)*90;
end

%% End Changes

deskew_img = imrotate(bw_img,deskewing_angle,'bilinear');
if fill_flag
    Mrot = ~imrotate(true(size(bw_img)),deskewing_angle,'bilinear');
    deskew_img(Mrot&~imclearborder(Mrot)) = true;
end

if soften_flag && abs(deskewing_angle) > 5
    deskew_img = fn_soften_edges(deskew_img, soften_size);
end


end