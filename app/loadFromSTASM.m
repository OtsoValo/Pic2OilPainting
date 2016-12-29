function [cs,rs,ds,bw] = loadFromSTASM(imgName,plotAxis,logHandle)
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
    myLog(logHandle,'���棺%s',P);
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
    plot(plotAxis,[x1,x2],[y1,y2],'-b');
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