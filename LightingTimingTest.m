fname = 'LaTeX Equations\demo_equation.jpg';
img = imread(fname);

tic
for i = 1:20
    fn_lighting_compensation(img);
end
toc

tic
for i = 1:20
    fn_lighting_otsu(img);
end
toc