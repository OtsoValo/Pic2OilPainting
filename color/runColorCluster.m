% �����ͻ�����о����ȡģ����ɫ
% ���������colors.mat
% �������п��Ըı�ģ����ɫ
clc,clear,close all;
path='./ColorMapDB/';
KS=30;% �������
fs=dir(path);
fs=arrayfun(@(f){f.name},fs(3:end));
cs=cell(size(fs));
for k=1:length(fs)
    f=fs{k};
    if isempty(strfind(f,'.db'))
        fp=fullfile(path,f);
        disp(fp);
        im=im2double(imread(fp));
        im=reshape(im,[numel(im)/3,3]);
        cs{k}=im;
    end
end
fprintf('���ھ���...\n');
cs=cell2mat(cs);
[~,CS]=kmeans(cs,KS,'MaxIter',1000);
I=0.2989*CS(:,1)+0.5870*CS(:,2)+0.1140*CS(:,3);
[~,ind]=sort(I);
CS=CS(ind,:);
fh=figure;
hold on;
for k=1:KS
    fill([k,k+1,k+1,k],[0,0,1,1],CS(k,:));
end
axis tight;
save('../app/colors.mat','CS');
saveas(fh,'colormap.jpg');