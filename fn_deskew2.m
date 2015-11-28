function [ deskew_img ] = fn_deskew2( bw_img )
edges = edge(bw_img,'canny');
[H,T,~] = hough(edges,'RhoResolution',1,'ThetaResolution', 0.1 );

P = houghpeaks(H,1);

detected_angle = T(P(1,2))-90;
deskew_img = detected_angle;
end