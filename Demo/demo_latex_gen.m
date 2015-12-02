clear;
close all;

my_full_path = which('demo_latex_gen');
[file_dir,~,~] = fileparts(my_full_path);
cd('C:\Users\James\Documents\GitHub\EE368-LaTeX_Gen\Demo\');

box_photo_dir = 'C:\Users\James\Box Sync\Project\DemoPictures';

addpath('..');
listing = dir(box_photo_dir);

for i = 1:length(listing)
    fname = listing(i).name;
    [~,~,ext] = fileparts(fname);
    if strcmp(ext,'.jpg')
        [eq_string, output_file] = fn_demo(fullfile(box_photo_dir,fname),false);
        disp(eq_string);
        system(['pdflatex ' output_file]);
        system([output_file '.pdf']);
        system(['write ' output_file '.tex']);
        
        movefile(fullfile(box_photo_dir,fname) ,fullfile(box_photo_dir,'Finished',fname));
        delete('*.aux');
        delete('*.log');
        

    end
end