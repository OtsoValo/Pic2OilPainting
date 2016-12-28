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