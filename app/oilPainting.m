function canvas = oilPainting(imgName,imScale,minLen,m,n,LSS,WSS,drawThreshs,...
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

if ~isempty(handles)
    plotAxis=handles.oilAxis;
    cla(plotAxis);
    logHandle=getappdata(handles.figure,'hlog');
else
    figure;
    axis;
    plotAxis=get(gcf,'CurrentAxes');
    logHandle=[];
end

[~,name,ext]=fileparts(imgName);
myLog(logHandle,'%s%s\n',name,ext);
startTime=tic();
% ͼƬ׼��
im=im2double(imread(imgName));
im=imresize(im,imScale);
scaledImgName=strcat(imgName,'.jpg');
imwrite(im,scaledImgName);
gim=rgb2gray(im);
[M,N]=size(gim);

% ��ȡ��ֵ������
imagesc(gim,'Parent',plotAxis);
axis(plotAxis,'equal');
axis(plotAxis,'tight');
axis(plotAxis,'off');
colormap gray;
hold(plotAxis,'on');
title(plotAxis,'');
drawnow;
myLog(logHandle,'��ȡ������...\n');

% ���������߽�
myLog(logHandle,'���������߽�...\n');
tic
[cs1,rs1,ds1]=loadFromHoughEdge(im,minLen,plotAxis);
title(plotAxis,'���������߽�');
drawnow;
myLog(logHandle,'ʱ���ѹ� %f �롣\n',toc);

% ��������ʶ��
myLog(logHandle,'��������ʶ��...\n');
tic
if correctCode==2
    [cs2,rs2,ds2,edgeBW]=loadFromSTASM(scaledImgName,plotAxis,logHandle);
else
    [cs2,rs2,ds2]=loadFromSTASM(scaledImgName,plotAxis,logHandle);
end
title(plotAxis,'��������ʶ��');
drawnow;
myLog(logHandle,'ʱ���ѹ� %f �롣\n',toc);
cs=[cs1;cs2];
rs=[rs1;rs2];
ds=[ds1;ds2];

% ��ֵ���㷽��
tic
myLog(logHandle,'���㷽��...\n');
R=(m+n)/4;
indr=round(m/2):m:M;
indc=round(n/2):n:N;
[X,Y]=meshgrid(indc,indr);
FI=scatteredInterpolant(cs,rs,ds);
dis=FI(X(:),Y(:));
for k=1:numel(X)
    plot(plotAxis,[X(k)-R*cos(dis(k)),X(k)+R*cos(dis(k))],...
        [Y(k)-R*sin(dis(k)),Y(k)+R*sin(dis(k))],...
        '-g');
end
title(plotAxis,'��ˢ����');
axis(plotAxis,[1,N,1,M]);
drawnow;
myLog(logHandle,'ʱ���ѹ� %f �롣\n',toc);

% ���ر�ˢģ��
shapes=cell(NBS,1);
textures=cell(NBS,1);
for bs=1:NBS
    [shapes{bs},textures{bs}]=getBrushStoke(sprintf('../bs/bs%d.png',bs));
end

% �ֲ���Ʊ�ˢ
if ~isempty(handles)
    cla(plotAxis);
end
canvas=OilCanvas(im);
load colors CS;% ����ģ����ɫ
rotateAngles=-90:90;
NA=length(rotateAngles);
for layer=1:length(LSS)
    tic
    myLog(logHandle,'���Ƶ�%d���ˢ...\n',layer);
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
    if isempty(handles)
        figure;
        axis;
        plotAxis=get(gcf,'CurrentAxes');
    end
    canvas.showImg(lamda,CS,textureScale,plotAxis);
    title(plotAxis,sprintf('��%d���ˢ',layer));
    drawnow;
    myLog(logHandle,'ʱ���ѹ� %f �롣\n',toc);
end

% ����ͼ��
tic
myLog(logHandle,'����ͼ��...\n');
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
if isempty(handles)
    figure;
    axis;
    plotAxis=get(gcf,'CurrentAxes');
end
canvas.showImg(lamda,CS,textureScale,plotAxis);
title(plotAxis,'���ս��');
drawnow;
myLog(logHandle,'ʱ���ѹ� %f �롣\n',toc);

delete(scaledImgName);
myLog(logHandle,'��ʱ�䣺%f �롣\n',toc(startTime));
myLog(logHandle,'-------------------\n');
end