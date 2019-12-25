% % % % 讀取影像
% clc;
close all;
clear all;
date = '2017_0430';
obj = VideoReader('S1_M1_ICMS_2_32.AVI');
nframes = obj.NumberOfFrames;
position_xy=[];
num1=880.02;
mkdir(fullfile('D:\Seneory_Feedback\S1_M1_ICMS_2\Camera_Track',date));
Write = fullfile('D:\Seneory_Feedback\S1_M1_ICMS_2\Camera_Track',date);
filename = 'D:\Seneory_Feedback\S1_M1_ICMS_2\Plexon\Phase_1\2017_0430\S1_M1_ICMS_2_32.plx'
%% Get Event time
load('D:\Seneory_Feedback\S1_M1_ICMS_2\Combine_plx\2017_0430\2017_0430_5ms')
Touch_time = Combine_DAQ_plx.Event_touch{3,1};
[n, ts, sv] = plx_event_ts(filename, 257);
[nCoords, nDim, nVTMode, c] = plx_vt_interpret(ts, sv);
[n, Event_002, sv] = plx_event_ts(filename, 2);
c(find(c(:,1)==0),:) = [];
Camera_time = [];
Camera_time_time = [];
for i = 1:length(Touch_time)
    Camera_time(i) = find(c(:,1)>=Touch_time(i),1,'first');
    Camera_time_time(i) = c(find(c(:,1)>=Touch_time(i),1,'first'),1)
end
% Camera_time_new = Camera_time;
% Camera_time_new_2 = [];
% x = 1;
% for i = 2:length(Camera_time_new)
%     if Camera_time(i)-Camera_time(i-1)<136
%        Camera_time_new(i) = 0;
%     end
% end
% for i = 1:length(Camera_time_new)
%     if Camera_time_new(i) ~= 0          
%        Camera_time_new_2(x) = Camera_time_new(i);
%        x=x+1;
%     end
% end

%% image
% v = VideoWriter('0880-1.avi','Uncompressed AVI');
% open(v)

for f = 1:length(Camera_time)
   
    Number =0;
    C_P = [];
    Trial = sprintf('Trial_%d',f+13);
for i = Camera_time(f)-3:Camera_time(f)+7
    Number = Number + 1; 
drawnow
data=read(obj,i);  %取得第i個frame的資料
    
sourcePic=data;
[m,n,o]=size(sourcePic);   %取得frame每點像素的顏色資訊
% figure,imshow(sourcePic,[]);
% grayPic=rgb2gray(sourcePic);
grayPic=sourcePic(:,:,1);

gp=zeros(1,256); %計算各灰階(藍色強度的灰階???)出現的機率
for k=1:256
    gp(k)=length(find(grayPic==(k-1)))/(m*n);
end

newGp=zeros(1,256); %計算新的各灰階出現的機率
S1=zeros(1,256);
S2=zeros(1,256);
tmp=0;

for k=1:256
    tmp=tmp+gp(k);
    S1(k)=tmp;
    S2(k)=round(S1(k)*256);
end

for k=1:256
    newGp(k)=sum(gp(find(S2==k)));
end

newGrayPic=grayPic; %填充各像素點新的灰階值
for k=1:256
    newGrayPic(find(grayPic==(k-1)))=S2(k);
end
nr=newGrayPic;


grayPic=sourcePic(:,:,2);

gp=zeros(1,256); %計算各灰階出現的機率
for k=1:256
    gp(k)=length(find(grayPic==(k-1)))/(m*n);
end

newGp=zeros(1,256); %計算新的各灰階出現的機率
S1=zeros(1,256);
S2=zeros(1,256);
tmp=0;
for k=1:256
    tmp=tmp+gp(k);
    S1(k)=tmp;
    S2(k)=round(S1(k)*256);
end
for k=1:256
    newGp(k)=sum(gp(find(S2==k)));
end

newGrayPic=grayPic; %填充各像素點新的灰階值
for k=1:256
    newGrayPic(find(grayPic==(k-1)))=S2(k);
end
ng=newGrayPic;

grayPic=sourcePic(:,:,3);

gp=zeros(1,256); %計算各灰階出現的機率
for k=1:256
    gp(k)=length(find(grayPic==(k-1)))/(m*n);
end

newGp=zeros(1,256); %計算新的各灰階出現的機率
S1=zeros(1,256);
S2=zeros(1,256);
tmp=0;
for k=1:256
    tmp=tmp+gp(k);
    S1(k)=tmp;
    S2(k)=round(S1(k)*256);
end
for k=1:256
    newGp(k)=sum(gp(find(S2==k)));
end

newGrayPic=grayPic; %填充各像素點新的灰階值
for k=1:256
    newGrayPic(find(grayPic==(k-1)))=S2(k);
end
nb=newGrayPic;

res=cat(3,nr,ng,nb);
    data=res;
    % Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im = imsubtract(data(:,:,3), rgb2gray(data));
    %Use a median filter to filter out noise
    diff_im = medfilt2(diff_im, [3 3]);
    % Convert the resulting grayscale image into a binary image.
    diff_im = im2bw(diff_im,0.25);
    % Remove all those pixels less than 300px
    diff_im = bwareaopen(diff_im,800);
     % Label all the connected components in the image.
    bw = bwlabel(diff_im, 8);
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    
    % Display the image
%     imshow(diff_im)
imshow(data)
    hold on
    
    meow=zeros(1,2);
%     This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats)
        bb = stats(object).BoundingBox;
        bc = stats(object).Centroid;
        meow = meow + bc;
        C_P(Number,:) = meow;
        
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(bc(1),bc(2), '-m+')
        a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        position_xy(1,i)=[num1];
        position_xy(3,i)=[i];
        position_xy(4,i)=[bc(1)];
        position_xy(5,i)=[bc(2)];            
    end
      
    hold off
%      F = getframe;
% %      writeVideo(v,F);
%      imwrite(F.cdata,[int2str(i),'.jpg']);
        
     
%      img =  frame2im(F);
%     [img,cmap] = rgb2ind(img,256);
%     if i == 1384
%         imwrite(img,cmap,'sir879-08.gif','gif','LoopCount',Inf,'DelayTime',1);
%     else
%         imwrite(img,cmap,'sir879-08.gif','gif','WriteMode','append','DelayTime',1);
%     end
% OCR (Optical Character Recognition).
% Author: Ing. Diego Barrag嫕 Guerrero 
% e-mail: diego@matpic.com
% For more information, visit: www.matpic.com
%________________________________________
% PRINCIPAL PROGRAM
% Read image
imagen=data; %imread('11.jpg');
imagen = imcrop(imagen,[2, 1, 85, 14]);
% imagen = bwareaopen(imagen,1);
% Convert to gray scale
if size(imagen,3)==3 %RGB image
    imagen=rgb2gray(imagen);
end
% figure(2);
% imshow(imagen);
% use median filter
% imagen = medfilt2(imagen,[3 3]);
% figure(3);
load masknumber
imagen=roifill(imagen,mask);
imagen=roifill(imagen,mask1);
imagen=roifill(imagen,mask2);
% imshow(imagen);
% use adaptive histogram equalisation
imagen = adapthisteq(imagen);
% figure(4);
% imshow(imagen);
% contrast stretching
imagen = imadjust(imagen);
% Convert to BW                    
threshold = graythresh(imagen);
imagen =~im2bw(imagen,threshold);                                   
imagen = bwareaopen(imagen,10);
imagen =~im2bw(imagen,threshold);
%Storage matrix word from image
word=[ ];
re=imagen;
%Opens text.txt as file for write
fid = fopen('text.txt', 'a');
% Load templates
load templates
global templates
% Compute the number of letters in template file
num_letras=size(templates,2);
while 1
    %Fcn 'lines' separate lines in text
    [fl re]=lines(re);
    imgn=fl;
    %Uncomment line below to see lines one by one
    %imshow(fl);pause(0.5)    
    %-----------------------------------------------------------------     
    % Label and count connected components
    [L Ne] = bwlabel(imgn);    
    for n=1:Ne
        [r,c] = find(L==n);
        % Extract letter
        n1=imgn(min(r):max(r),min(c):max(c));  
        % Resize letter (same size of template)
        img_r=imresize(n1,[42 24]);
        %Uncomment line below to see letters one by one
         %imshow(img_r);pause(0.5)
        %-------------------------------------------------------------------
        % Call fcn to convert image to text
        letter=read_letter(img_r,num_letras);
        % Letter concatenation
        word=[word letter];
         val = str2double(word);
        time10=floor(val/100000)*60+(val/1000-floor(val/100000)*100);
        position_xy(2,i)=[time10];
    end
    %fprintf(fid,'%s\n',lower(word));%Write 'word' in text file (lower)
                %fprintf(fid,'%s\n',word);%Write 'word' in text file (upper)
%                 word
               word1 = 'SHARATH';
    % Clear 'word' variable
    word=[ ];
    %*When the sentences finish, breaks the loop
    if isempty(re)  %See variable 're' in Fcn 'lines'
        break
    end    
end
%%%%%%% to print in a text file 'text.txt'
%fclose(fid);
%Open 'text.txt' file
%winopen('text.txt')



% clear all

end

if isempty(C_P) == 1
    Camera_Position.(Trial) = zeros(11,2);
else
    Camera_Position.(Trial) = C_P;
end

end

position_xy1(1,:)=position_xy(1,i-10:i);
position_xy1(2,:)=position_xy(2,i-10:i);
position_xy1(3,:)=position_xy(3,i-10:i);
position_xy1(4,:)=position_xy(4,i-10:i);
position_xy1(5,:)=position_xy(5,i-10:i);
% close(v)

name = 'Camera_Position';
save(fullfile(Write,name),'Camera_Position');
