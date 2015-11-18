% Jim Brewer
% EE368
% Project - Character Recogition. Create Rotational Profile Development
% Nov 13, 2015

% Read in equation to get character to test feature extraction
dir = strcat(pwd,'/LaTeX Equations');
eq = im2double(rgb2gray(imread(strcat(dir,'/eq1_hr.jpg'))));

th = graythresh(eq);
eq_bin = eq;
eq_bin(eq <= th) = 0;
eq_bin(eq > th) = 1;

chars = fn_segment(eq_bin);

ident = fn_createIdent(chars(5).img,true,true)

% k = 8; % Decrease if have more low-res input or small characters?
% % Identity vector of character for nearest neighbor match
% % Contains normalized central moment of inertia, # of circular crossings,
% % and k-1 largest circle ratios of arc lengths to circumference
% identity = zeros(1,2*k);
% %% Create normalized central moment (assume image is binary, object = 0)
% temp = chars(1).img;
% % temp = large_bin;
% N = sum(temp(:));
% % Find x,y positions of 0 elements (object)
% [y, x] = find(~temp);
% % Find centroid
% cent = regionprops(temp,'centroid');
% cent = cat(1, cent.Centroid);
% cent_x = cent(1);
% cent_y = cent(2);
% 
% % Find central moment of inertia
% I = sum((x - cent_x).^2 + (y - cent_y).^2);
% IN2 = I / N^2;
% identity(1) = IN2;
% %% Extract k-circular templates
% 
% % Radius spacing between circles
% y = size(temp,1);
% x = size(temp,2);
% dr = max(x - cent_x, y - cent_y) / k;
% [c, r] = meshgrid(1:x, 1:y);
% 
% figure(1);
% tempcirc = temp;
% for i = 1:k
%     rad = dr * i;
%     % Create circle line of logical 1s to extract template
%     C = xor(sqrt((c-cent_x).^2+(r-cent_y).^2)<=rad, ...
%         sqrt((c-cent_x).^2+(r-cent_y).^2)<=(rad-1));
%     % Extract circular template linear indices (do top and bottom separate 
%     % because of how linear indices work)
%     C1 = C(1:round(cent_y),:);
%     C2 = C(round(cent_y)+1:end,:);
%     idx1 = find(C1);
%     idx2 = find(C2);
%     temp1 = temp(1:round(cent_y),:);
%     temp2 = temp(round(cent_y)+1:end,:);
%     circVec = [temp1(idx1) ; flipud(temp2(idx2))];
%     
%     idx = find(C);
%     % Extract values from character based on circular indices
% %     % Test: Smoother values, if [0 1 1 0]=>[0 0 0 0]
% %     th = 1; % number of pixels in between that should all be 0
% %     len = th+2;
% %     testV = zeros(len,1);
% %     testV(2:end-1,1) = 1;
% %     circVec = temp(idx);
% %     for j = 1:(size(idx,1) - (len-1))
% %         if(circVec(j) == 0 && circVec(j+(len-1)) == 0)
% %            circVec(j:(j+len-1)) = 0; 
% %         end
% %     end
% %     for j = 1:(size(idx,1) - (len-1))
% %         if(circVec(j) == 1 && circVec(j+(len-1)) == 1)
% %                 circVec(j:(j+len-1)) = 1; 
% %         end
% %     end
%     % Need to do closing of gaps? initially seems better without
% %     circVec = ones(size(circVec))-imclose(ones(size(circVec))-circVec,ones(2,1));
%     
%     
%     
%     coding(i).circ = circVec;
%     tempcirc(idx) = .5;
% %     tempcirc = xor(tempcirc,C); % Show circles on character
% 
%     % Count number of sections of at least 2 0s.
%     cnt = strfind(circVec',[0 0]);
%     coding(i).count = length(cnt(diff([1 cnt])~=1));
%     identity(1+i) = coding(i).count;
%     % Handle wrap around
%     if(circVec(1) == 0 && circVec(end) == 0)
%         coding(i).count = coding(i).count - 1;
%     end
%     subplot(2,4,i);
%     imshow(coding(i).circ);
%     str = sprintf('%d',coding(i).count);
%     title(str);
%     
%     % Find 2 longest arcs of background and divide by total length
%     % If 1s wrap around, move all 1s to one side.
%     circ = length(circVec);
%     if(circVec(1) == 1 && circVec(end) == 1)
%         idx = find(circVec==0,1,'last');
%         circVec = [circVec(idx+1:end); circVec(1:idx)];
%     end
%     % Vector of length of each section of 1s
%     B = [0 circVec' 0]; % Pad with 0s for diff
%     bgrd_len = find(diff(B)==-1) - find(diff(B)==1);
%     % If not crossings, set ratio to 0
%     if(coding(i).count < 1);
%         d2 = 0;
%         d1 = 0;
%     else
%         [d2, idx_d2] = max(bgrd_len);
%         bgrd_len(idx_d2)=NaN;
%         d1 = max(bgrd_len);
%     end
%     coding(i).ratio = (d2-d1) / circ;
%     if(i > 1) % Only keep k-1 largest ratios
%         identity(k+i) = coding(i).ratio;
%     end
%     fprintf('Count=%d, d2=%d, d1=%d, c=%d, ratio = %.4f\n',...
%         coding(i).count,d2,d1,circ,coding(i).ratio);
% end
% 
% figure(2);
% imshow(tempcirc);
% 

