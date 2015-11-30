function softened = fn_soften_edges(bw_img, se_size)
%FN_SOFTEN_EDGES Softens the edges of a binary image using an opening
%operation
    
if nargin == 1
    se_size = 5;
end

se = true(se_size,se_size);
se = strel('disk',se_size);

softened = imopen(bw_img,se);

end