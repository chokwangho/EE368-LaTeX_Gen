clear;
close all;

my_full_path = which('demo_latex_gen');
[file_dir,~,~] = fileparts(my_full_path);
cd('E:\Github\EE368-LaTeX_Gen\Demo\');

addpath('..');
listing = dir(pwd);

for i = 1:length(listing)
    fname = listing(i).name;
    [~,~,ext] = fileparts(fname);
    if strcmp(ext,'.jpg')
        [eq_string, output_file] = fn_demo(fullfile(pwd,fname),false);
        disp(eq_string);
        system(['pdflatex ' output_file]);
        system([output_file '.pdf']);
        system(['write ' output_file '.tex']);
        
        movefile(fname,['Finished\' fname]);
        delete('*.aux');
        delete('*.log');
        

    end
end