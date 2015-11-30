% Jim Brewer
% EE368
% Project
% Nov 30, 2015
%% Test full matching process against 8 test equation pictures. Export PDF
% of matched characters, count how many matched and weren't matched

directory = strcat(pwd,'/LaTeX Equations/Test Pictures/*lighting.jpg');
files = dir(directory);

for i =1:length(files)
    fn_main(strcat('Test Pictures/',files(i).name),true);
    print(strcat('matched_',files(i).name),'-djpeg');
end