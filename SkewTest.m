imgs = cell(13);
j = 1;
for i = 1:10
    if i == 4, continue, end;
    imgs{j} = rgb2gray(imread(['LaTeX Equations\eq' num2str(i) '_hr.jpg']));
    j = j+1;
end

detected = zeros(size(-25:0.5:25));
err = zeros(13,length(detected));
for j = 1:13
    img = imgs{j};
    i = 1;
    for theta = -25:0.5:25
        rotated = imrotate(img,theta);
        Mrot = ~imrotate(true(size(img)),theta,'bilinear');
        rotated(Mrot&~imclearborder(Mrot)) = 255;
        thresh = graythresh(rotated);
        bw_skew = im2bw(rotated, thresh);
        
        [~,detected(i)] = fn_deskew2(bw_skew);
        if theta ==0
            err(j,i) = abs((detected(i)+theta));
        else
            %         err(i) = abs((detected(i)+theta)/theta);
            err(j,i) = abs((detected(i)+theta));
        end
        i = i+1;
    end
end;
plot(-25:0.5:25,err(1:10,:))
legend('eq1','eq2','eq3','eq5','eq6','eq7','eq8','eq9','eq10')
title('Absolute Rotation Error')