#include<stdio.h>
#include<stdlib.h>
#include<opencv\highgui.h>
#include<stasm_lib.h>
#include<mex.h>

char err_str[1024];

int findFacePoints(char* path, char* dataPath, float landmarks[]){
	cv::Mat_<unsigned char> img(cv::imread(path, CV_LOAD_IMAGE_GRAYSCALE));
	if (!img.data){
		sprintf(err_str, "Cannot load %s\n", path);
		return 0;
	}
	int foundface;
	if (!stasm_search_single(&foundface, landmarks,
		(const char*)img.data, img.cols, img.rows, path, dataPath)){
		sprintf(err_str, "Error in stasm_search_single: %s\n", stasm_lasterr());
		return 0;
	}
	if (!foundface){
		sprintf(err_str, "No face found in %s\n", path);
		return 0;
	}
	return 1;
}

/*�ܹ�����77�������㣬����0-15ȷ������������16-21��22-27�ֱ�������üë��
28 ��29Ϊ�����۾��Ϸ���Ƥ���壨˫��Ƥ����30-37��Ϊ���ۣ�38Ϊ��ͫ�ף�39Ϊ��ͫ�ף�
40-47Ϊ���ۣ�47-58Ϊ��ͷ��59-68Ϊ�ϴ���69-76Ϊ�´���*/

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, mxArray* prhs[]){
	char* path = mxArrayToString(prhs[0]);
	char* data = mxArrayToString(prhs[1]);
	float landmarks[2 * stasm_NLANDMARKS]; // x,y coords (note the 2)
	int foundface = findFacePoints(path, data, landmarks);
	mxArray* mxP;
	if (foundface){
		mxP = mxCreateDoubleMatrix(2, stasm_NLANDMARKS, mxREAL);
		double* p = mxGetPr(mxP);
		for (int k = 0; k < 2 * stasm_NLANDMARKS; k++) p[k] = landmarks[k];
	}
	else{
		mxP = mxCreateString(err_str);
	}
	plhs[0] = mxP;
}