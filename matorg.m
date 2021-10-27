function [X,Y,ii,BM,ix,iy] = matorg(x,y)
% MATORG	Organise vectordata into matrices by the unique content
%		of two of the variables.
% 
% This function sorts the content of the two first input vectors into
% two vectors of their unique values to be used as coordinates of matrix
% representations of any corresponding data vectors you might have. 
%
%   [X,Y,ii,BM,ix,iy] = matorg(x,y)
% 
% x	= vector of data you want to organise your rows in (i.e., the
%	  1st dimension). 
% y	= vector of data you want to organise your columns in (i.e., the
%	  2nd dimension). 
%
% X,Y	= the unique and sorted versions of x and y which will be
%         your coordinates for 
% ii	= The index to the matrix of any other data organised as the
%	  input x and y.
% BM	= A base matrix of NaNs (tabula rasa) that you can populate
%	  your data into, using ii. See example below.
% ix,iy = indices such that X = x(ix) and Y=y(iy). Can be used
%	  into other corresponding data vectors to make these
%	  correspond to X and Y.
%
% Input can be any type that UNIQUE can take.
% Currently only 2D functionality.
%
% Example (using some unrealistic short vectors):	
%	x={'A','B','G','C','D','F','E'};% Your data
%	y=[2 4 6 8 3 3 5];		% Your data
%	a=[10 12 14 18 16 20 30];	% Your data
%	% All vectors have same length.	
%	% You want x and y to be the coordinates of matrix
%	% representation (i.e., a table) of your data. 
%	[X,Y,ii,BM] = matorg(x,y);
%	A=BM; A(ii)=a;
%	% And if your dataset have other variables in corresponding
%	% vectors, you can do the last line again on these.
% 
% See also SUB2IND UNIQUE GRIDSORT 

[X,ix,i] = unique(x); 
[Y,iy,j] = unique(y);
X=X(:); Y=Y(:)';
BM=nan(length(X),length(Y));
ii=sub2ind(size(BM),i,j);
