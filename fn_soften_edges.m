function softened = fn_soften_edges(bw_img, se_size)
%FN_SOFTEN_EDGES Softens the edges of a binary image using a Gaussian Blur.
% This function expects the image to have text in the background (black
% text on white)
    
if nargin == 1
    se_size = 7;
end

fg = fspecial('gaussian', se_size, 3);
softened = ~imfilter(~bw_img, fg, 'conv','replicate');

end