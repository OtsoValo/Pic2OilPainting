classdef LineMarker < handle
    properties
        M
    end
    methods
        function obj = LineMarker(M)
            obj.M=M;
        end
        function drawLine(this,x0,x1,y0,y1,c)
            % �е㷨����ֱ��
            % ��֤ x0<x1
            if x0>x1
                temp=x0;
                x0=x1;
                x1=temp;
                temp=y0;
                y0=y1;
                y1=temp;
            end
            % һ����
            if x0==x1 && y0==y1
                this.putPixel(x0,y0,c);
                return;
            end
            % ����б�ʵĲ�ͬ��ͨ������������ 0<=m<=1 �� mainDraw �����ĵ��÷�ʽ��
            % �Լ��� mainDraw �� putPixel �ķ�ʽ����ɸ�������µĻ�ͼ��
            m=(y1-y0)/(x1-x0);
            if 0<=m && m<=1
                mainDraw(x0,x1,y0,y1,c,@(x,y,c)this.putPixel(x,y,c));
            elseif m>1
                mainDraw(y0,y1,x0,x1,c,@(x,y,c)this.putPixel(y,x,c));
            elseif -1<=m && m<0
                mainDraw(-x1,-x0,y1,y0,c,@(x,y,c)this.putPixel(-x,y,c));
            else
                mainDraw(-y0,-y1,x0,x1,c,@(x,y,c)this.putPixel(y,-x,c));
            end
        end        
        function putPixel(this,x,y,c)
            this.M(y,x)=c;
        end
    end
end
function mainDraw(x0,x1,y0,y1,c,putPixel)
% x0<x1 0<=m<=1 ʱ������ֱ�ߵĺ���
% ���� putPixel Ϊ�������
dx=x1-x0;
dy=y1-y0;
d=dx-2*dy;
iE=-2*dy;
iNE=-2*(dy-dx);
x=x0;y=y0;
putPixel(x,y,c);
while x<x1
    if d>0
        d=d+iE;
    else
        d=d+iNE;
        y=y+1;
    end
    x=x+1;
    putPixel(x,y,c);
end
end
