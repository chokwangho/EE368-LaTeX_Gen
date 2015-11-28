lighting_dir = 'Lighting\';
combined_dir = 'Opt\';
results_dir = [combined_dir 'Results\'];
listing = dir(lighting_dir);

for i = 1:length(listing)
    fname = listing(i).name;
    if ~listing(i).isdir && ~strcmp(fname,'.') && ~strcmp(fname,'..')
        img = imread([lighting_dir fname]);
        bw_img = fn_lighting_compensation(img);
        detected_angle = fn_deskew2(bw_img)
        out_img = imrotate(bw_img,detected_angle);
        imwrite(out_img,[results_dir 'result_hough_' fname]);
    end
end
