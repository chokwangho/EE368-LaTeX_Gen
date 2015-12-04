function softened = fn_soften_edges(bw_img, se_size)
%FN_SOFTEN_EDGES Softens the edges of a binary image using a opening operation.
%This function expects the image to have text in the background (black
%text on white)
% Optional args:
%   se_size - Disk Structuring Element Size. Default value = 5.
    
if nargin == 1
%     se_size = 7;
    se_size = 5;
end

%% New Implementation - Needs more testing

% fg = fspecial('gaussian', se_size, 3);
% softened = ~imfilter(~bw_img, fg, 'conv','replicate');

%% Previous Implementation
se = strel('disk',se_size);

softened = imopen(bw_img,se);

%% End Changes

end