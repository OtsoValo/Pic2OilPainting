function canvas = oilPaintingForUI(imgName,imScale,minLen,m,n,LSS,WSS,drawThreshs,...
    textureScale,lamda,correctCode,correctR,NBS,handles)
% �ͻ���񻯻���
% ���룺
%   imgName ͼƬ·��
%   imScale ͼƬ���ű�����ͼƬԽ�󣬱�ˢ����Խ������������ʱ��Խ����
%   minLen ���ڱ߽���ȡ��������ʱ�����ֱ�߳���
%   m,n ���Ƶ�һ��ڶ����ˢ�������С
%   LSS,WSS �����ˢ�Ŀ�Ⱥͳ���
%   drawTrreshs �����ˢ�������ֵ����[0,1]֮�䣬��Ϊ�����ͼƬ��ɫ��0,1֮���
%               ��������ʾ
%   textureScale ��ģ���ȡ��ˢ����������ϵ����ϵ��Խ������Խ���ԣ����п��ܹ���
%   lamda ͼƬ��ɫ��ģ����ɫ�ļ�Ȩϵ��,0,1֮�䣬ԽСԽ�ӽ�ģ����ɫ
%   correctCode �����������룺
%               1 ��ʾ��������������������
%               2 ��ʾ����ͼ��߽��������
%               ���޷�ʶ������ʱĬ�ϵ��÷���1
%   correctR �����뾶
%   NBS ��ˢģ��������bs�ļ�����bs%d.png���ļ���������ˢģ����png��ʽ�洢��
%       Ĭ�������Ǻ���ġ�
%   handles OilGUI�ľ��
% �����
%   canvas ���ƽ��

[~,name,ext]=fileparts(imgName);
myLog(handles,'%s%s\n',name,ext);
startTime=tic();
% ͼƬ׼��
im=im2double(imread(imgName));
im=imresize(im,imScale);
scaledImgName=strcat(imgName,'.jpg');
imwrite(im,scaledImgName);
gim=rgb2gray(im);
[M,N]=size(gim);

% ��ȡ��ֵ������

cla(handles.oilAxis);
imagesc(gim,'Parent',handles.oilAxis);
axis(handles.oilAxis,'equal');
axis(handles.oilAxis,'tight');
axis(handles.oilAxis,'off');
colormap gray;
hold(handles.oilAxis,'on');
title(handles.oilAxis,'');
drawnow;

myLog(handles,'��ȡ������...\n');
myLog(handles,'���������߽�...\n');
tic
[cs1,rs1,ds1]=loadFromHoughEdge(im,minLen,handles);
title(handles.oilAxis,'���������߽�');
drawnow;
myLog(handles,'ʱ���ѹ� %f �롣\n',toc);
myLog(handles,'��������ʶ��...\n');
tic
if correctCode==2
    [cs2,rs2,ds2,edgeBW]=loadFromSTASM(scaledImgName,handles);
else
    [cs2,rs2,ds2]=loadFromSTASM(scaledImgName,handles);
end
title(handles.oilAxis,'��������ʶ��');
drawnow;
myLog(handles,'ʱ���ѹ� %f �롣\n',toc);
cs=[cs1;cs2];
rs=[rs1;rs2];
ds=[ds1;ds2];

% ��ֵ���㷽��
tic
myLog(handles,'���㷽��...\n');
R=(m+n)/4;
indr=round(m/2):m:M;
indc=round(n/2):n:N;
[X,Y]=meshgrid(indc,indr);
FI=scatteredInterpolant(cs,rs,ds);
dis=FI(X(:),Y(:));
for k=1:numel(X)
    plot(handles.oilAxis,[X(k)-R*cos(dis(k)),X(k)+R*cos(dis(k))],...
        [Y(k)-R*sin(dis(k)),Y(k)+R*sin(dis(k))],...
        '-g');
end
title(handles.oilAxis,'��ˢ����');
axis(handles.oilAxis,[1,N,1,M]);
drawnow;
myLog(handles,'ʱ���ѹ� %f �롣\n',toc);

% ���ر�ˢģ��
shapes=cell(NBS,1);
textures=cell(NBS,1);
for bs=1:NBS
    [shapes{bs},textures{bs}]=getBrushStoke(sprintf('../bs/bs%d.png',bs));
end

% �ֲ���Ʊ�ˢ
cla(handles.oilAxis);
canvas=OilCanvas(im);
load colors CS;% ����ģ����ɫ
rotateAngles=-90:90;
NA=length(rotateAngles);
for layer=1:length(LSS)
    tic
    myLog(handles,'���Ƶ�%d���ˢ...\n',layer);
    lss=LSS(layer);
    wss=WSS(layer);
    drawThresh=drawThreshs(layer);
    % Ԥ������ת�����ŵ���״�������ӿ��ٶ�
    resizedShapes=cellfun(@(s){imresize(s,[wss,lss])},shapes);
    resizedTextures=cellfun(@(s){imresize(s,[wss,lss])},textures);
    shapeMap=cell(NBS,NA);
    for i=1:NBS
        for j=1:NA
            % logical��imresize��double���ܶ�
            shapeMap{i,j}=logical((imrotate((uint8(resizedShapes{i})),...
                rotateAngles(j))));
        end
    end
    textureMap=cell(NBS,NA);
    for i=1:NBS
        for j=1:NA
            textureMap{i,j}=((imrotate(((resizedTextures{i})),rotateAngles(j))));
            textureMap{i,j}(~shapeMap{i,j})=1;
        end
    end
    % ���һ��ϸ����������
    if layer==length(LSS)
        [Y,X]=find(~canvas.isPloted);
        dis=FI(X(:),Y(:));
    end
    % ���Ʊ�ˢ
    for k=1:numel(X)
        if ~canvas.isPloted(Y(k),X(k))
            mapi=unidrnd(NBS);
            mapj=-round(radtodeg(dis(k)))+91;
            canvas.drawBrush(shapeMap{mapi,mapj},textureMap{mapi,mapj},...
                X(k),Y(k),drawThresh);
        end
    end
    % չʾ���ƽ��
    canvas.showImg(lamda,CS,textureScale,handles.oilAxis);
    title(handles.oilAxis,sprintf('��%d���ˢ',layer));
    drawnow;
    myLog(handles,'ʱ���ѹ� %f �롣\n',toc);
end

% ����ͼ��
tic
myLog(handles,'����ͼ��...\n');
% ������������
if correctCode>0
    if correctCode==1
        edgeBW=edge(gim,'canny');
    end
    edgeBW=imdilate(edgeBW,strel('disk',correctR));
    canvas.isPloted=canvas.isPloted&~edgeBW;
end
% ����ͼ��
ind=bsxfun(@plus,find(~canvas.isPloted),(0:2)*M*N);
canvas.canvas(ind)=canvas.im(ind);
canvas.texture(~canvas.isPloted)=1;
canvas.isPloted=true(M,N);
canvas.showImg(lamda,CS,textureScale,handles.oilAxis);
title(handles.oilAxis,'���ս��');
drawnow;
myLog(handles,'ʱ���ѹ� %f �롣\n',toc);

delete(scaledImgName);
myLog(handles,'��ʱ�䣺%f �롣\n',toc(startTime));
myLog(handles,'-------------------\n');
end
%--------------------------------------------------------------------------
function [shape,texture] = getBrushStoke(fname)
% ��ȡ��ˢ
% ���룺
%   fname ��ˢͼ���ļ���
%   textureScale ��������ϵ��
% �����
%   shape ��ˢ��״����
%   texture ��ˢ��ɫ�ı���ϵ��

% ��ȡ��״
im=imread(fname);
im=im2double(im);
gim=rgb2gray(im);
shape=~im2bw(gim,graythresh(gim));
shape=imerode(shape,strel('disk',9));
% ��״�ü�
rsum=sum(shape,2);
sr=find(rsum>0,1,'first');
er=find(rsum>0,1,'last');
csum=sum(shape,1);
sc=find(csum>0,1,'first');
ec=find(csum>0,1,'last');
shape=shape(sr:er,sc:ec);
gim=gim(sr:er,sc:ec);
% ��ȡ����
gim(~shape)=0;
texture=gim/mean(gim(shape));
texture(~shape)=1;
end
%--------------------------------------------------------------------------
function [cs,rs,ds] = loadFromHoughEdge(im,minLen,handles)
% ���߽�ֽ����ͨ����
% ����ÿ����ͨ�������û���任��ֱ��
% ���ػ��ڱ߽���Ϣ�ķ�������

gim=rgb2gray(im);
bw=edge(gim,'canny');
% Ѱ�ұ߽�
list=java.util.ArrayList();
while any(bw(:))
    stats=regionprops(bw,'Area','BoundingBox','Image');
    for k=1:length(stats)
        sbw=stats(k).Image;
        bx=stats(k).BoundingBox;
        bx=ceil(bx);
        indr=bx(2):(bx(2)+bx(4)-1);
        indc=bx(1):(bx(1)+bx(3)-1);
        if stats(k).Area<minLen
            mbw=false(size(sbw));
        else
            [H,T,R]=hough(sbw);
            P=houghpeaks(H,1);
            lines=houghlines(sbw,T,R,P,'MinLength',minLen);
            if isempty(lines)
                mbw=false(size(sbw));
            else
                line=lines(1);
                x1=line.point1(1);y1=line.point1(2);
                x2=line.point2(1);y2=line.point2(2);
                mbw=markLinePrivate(sbw,x1,x2,y1,y2);
                xy=[line.point1+bx([1,2])-1;line.point2+bx([1,2])-1];
                list.add(xy);
            end
        end
        bw(indr,indc)=mbw;
    end
end
% ��׼������
NL=list.size();
rs=zeros(NL,1);
cs=zeros(NL,1);
ds=zeros(NL,1);
for i=1:list.size()
    xy=list.get(i-1);
    x1=xy(1,1);y1=xy(1,2);
    x2=xy(2,1);y2=xy(2,2);
    rs(i)=(y1+y2)/2;
    cs(i)=(x1+x2)/2;
    ds(i)=atan((y2-y1)/(x2-x1));
end
for i=1:list.size()
    xy=list.get(i-1);
    x1=xy(1,1);y1=xy(1,2);
    x2=xy(2,1);y2=xy(2,2);
    plot(handles.oilAxis,[x1,x2],[y1,y2],'-r');
end
% ���ӱ߽�ο�
[M,N]=size(gim);
BS=[1,1,pi/2;
    N,1,pi/2;
    1,M,pi/2;
    N,M,pi/2;];
% ���ǻ�����������һ���Ǳ��ضϵ�
% ������ı仯��ʵ������ֱ��
% ���ɾ��ˮƽ�ߣ������������˵Ļ�������ֱ��
%     2,1,0;
%     N-1,1,0;
%     2,M,0;
%     N-1,M,0;];
cs=[cs;BS(:,1)];
rs=[rs;BS(:,2)];
ds=[ds;BS(:,3)];
end
%--------------------------------------------------------------------------
function bw = markLinePrivate(bw,x1,x2,y1,y2)
% ���ֱ�ߣ������飬Сͼ�ô��㷨�ȽϿ죬��ͼ������ֱ�ߵ��е��㷨�ȽϿ�
A=y1-y2;
B=-(x1-x2);
C=x1*y2-x2*y1;
[Y,X]=find(bw);
ind= X>=min(x1,x2) & X<=max(x1,x2) & Y>=min(y1,y2) & Y<=max(y1,y2);
X=X(ind);
Y=Y(ind);
d=abs(A*X+B*Y+C)/sqrt(A^2+B^2);
ind=d<sqrt(2);
bw(Y(ind),X(ind))=false;
end
%--------------------------------------------------------------------------
function [cs,rs,ds,bw] = loadFromSTASM(imgName,handles)
% �� stasm.txt ��ȡԤ���������
% ���� stasm.exe ��ȡ����������
% ���ػ��������㹹��ķ�������

% ��ȡ�����±����
fid=fopen('stasm.txt');
C=textscan(fid,'%[^\n]');
fclose(fid);
C=C{1};
list=java.util.ArrayList();
for i=1:length(C)
    str=C{i};
    inds=sscanf(str,'%d');
    for k=1:length(inds)-1
        list.add([inds(k),inds(k+1)]);
    end
end
NV=list.size();
IND=zeros(NV,2);
for k=1:NV
    IND(k,:)=(list.get(k-1))';
end
% ��ȡ�����
P=stasm(imgName);
if ischar(P)
    myLog(handles,'���棺%s',P);
    cs=[];
    rs=[];
    ds=[];
    if nargout>3
        im=imread(imgName);
        bw=false(size(im(:,:,1)));
    end
    return;
end
% ��������
cs=zeros(NV,1);
rs=zeros(NV,1);
ds=zeros(NV,1);
for k=1:NV
    x1=P(IND(k,1),1);y1=P(IND(k,1),2);
    x2=P(IND(k,2),1);y2=P(IND(k,2),2);
    rs(k)=(y1+y2)/2;
    cs(k)=(x1+x2)/2;
    ds(k)=atan((y2-y1)/(x2-x1));
end
for k=1:NV
    x1=P(IND(k,1),1);y1=P(IND(k,1),2);
    x2=P(IND(k,2),1);y2=P(IND(k,2),2);
    plot(handles.oilAxis,[x1,x2],[y1,y2],'-b');
end
if nargout>3
    im=imread(imgName);
    [m,n,~]=size(im);
    bw=false(m,n);
    marker=LineMarker(bw);
    for k=1:NV
        x1=P(IND(k,1),1);y1=P(IND(k,1),2);
        x2=P(IND(k,2),1);y2=P(IND(k,2),2);
        marker.drawLine(x1,x2,y1,y2,true);
    end
    bw=marker.M;
end
end
%--------------------------------------------------------------------------
function myLog(handles,varargin)
hlog=getappdata(handles.figure,'hlog');
str=sprintf(varargin{:});
hlog.append(str);
end
