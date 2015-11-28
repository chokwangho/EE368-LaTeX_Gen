% Project - Import Templates for Character Recognition and create
% Classifier matrix
% Jim Brewer
% EE368
% Nov 18, 2015

% Helper Script to create the MatLab data of the character templates and
% their character string and identifier data. Output used by "main.m"

dir = strcat(pwd,'/LaTeX Equations');
palette = im2double(rgb2gray(imread(strcat(dir,'/reduced_characterPalette.jpg'))));

th = graythresh(palette);
pal_bin = palette;
pal_bin(palette <= th) = 0;
pal_bin(palette > th) = 1;

%% Extract character templates
chars = fn_segment(pal_bin, true);

% Remove doubles from non-contigous characters (manually review and remove)
% Check for accuracy
chars(119)=[]; %.
chars(103)=[]; %.
chars(102)=[]; %.
chars(92)=[]; %.
chars(80)=[]; %@
chars(3)=[]; %~

% Add "truth" labels (verify order in text file versus char struct)
fileID = fopen(strcat(dir,'/reduced_characters.txt'));
text_chars = textscan(fileID,'%s', 'delimiter',',');
text_chars = char(text_chars{1,1});
fclose(fileID);

%% Create identifiers for each character
for i = 1:length(chars)
    chars(i).ident = fn_createIdent(chars(i).img);
    chars(i).char = text_chars(i,:);
end

%% Save out character palette
% save('red_charPalette_withText.mat','chars');

%% Train Nearest Neighbor Classifier
% Create data matrix for KNN Search with just original templates
X_orig = zeros(length(chars), length(chars(1).ident) + 1);
for i = 1:length(chars)
    X_orig(i,1:length(chars(1).ident)) = chars(i).ident;
    X_orig(i,end) = i;
end
% save('red_charPalette_Classifier.mat','X_orig');