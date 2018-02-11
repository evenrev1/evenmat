function Y=bridge(X,shift,gaplimit,opt)
% BRIDGE	Advanced missing-data interpolation
%
% Fills in any holes (NaN), by following routine: Average pairs of data
% from points 'shift' before and after each point in the gap (including
% endpoints with data) to form a mean series segment (the bridge); find
% anomalies from a straight line between the bridge's endpoints; add
% these anomalies to a straight line over the gap. (When 'shift' is one
% year, this corresponds to forming anomalies from an empirical cycle
% based on previous and following year, and then adjusting the level
% according to the gap's endpoints.)
%
% Y = bridge(X,shift,gaplimit,opt)
%
% X	= input vector, or array with time along first dimension.
%         When X is inhomogeneously sampled, put onto homogeneous
%         grid first, to make the gaps show as NaNs.  
% shift	= how far away to collect basis-data for mean bridge (default is
%         lenght of gap). Recommended to specify a yaers length when
%         prominent and stationary periodicity is known (like
%         seasonality). 
% gaplimit = limit on length of gaps to be filled (default=inf) 
% opt	= string containing one of the following
%         'ends': fill ends as well as gaps.
%         'nin': no linear interpolation over gap, i.e. do NOT
%                 adjust the level of the filled data to the
%                 endpoints of the gap.
%         'lin' : Only do linear interpolations over the gaps.
%
% If gaps are too many and close for BRIDGE to find data to use, all
% holes might not be filled. Just run BRIDGE again, and again, and ...
%
% No output argument results in a plot of the original and the filled
% series together.  NOTE: Spurious peaks, or other effects, may occur on
% really sparse data, so make sure you visually check!
%
% See also ETREND ANOMALY INTERP1Q

if nargin<4|isempty(opt), opt=''; end
if nargin<3|isempty(gaplimit), gaplimit=inf; end
if nargin<2|isempty(shift), shift=[];	end

D=size(X);
if D(2)>1 & D(1)==1, X=X(:); D=fliplr(D); end

if length(D)>2 | any(D(3:end)>1)	% if array
  cols=prod(D(2:end));
  Y=reshape(X,D(1),cols);
  Y=matbridge(Y',shift,gaplimit,opt)';
  Y=reshape(Y,D);
else
  Y=matbridge(X',shift,gaplimit,opt)';
end

% Plotting:
if nargout==0 & length(D)==2 & D(2)==1
  fig bridge 4;clf;
  h=plot(1:D(1),Y,'k.--',1:D(1),X,'k-o');
  legend(...%h([0:2]*N+1),...
	 'interpolated series','data input',0);
  grid on; %zoom xon;
  scanplot;
  title('Interpolation by BRIDGE');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% KERNEL %%%%%%%%%%%%%%
function Y=matbridge(Y,shift,gaplimit,opt)	% PS! Works along ROWS!
ydr=isvec(Y);
if ydr==1, Y=Y'; end			% flip col-vector into row

cpx=~isreal(Y);
if cpx, Y=[real(Y);imag(Y)]; end	% fill components separately

[M,N]=size(Y);

for i=1:M				% LOOP THE ROWS
  jn=find(isnan(Y(i,:)));		% indices of nans
  if isempty(jn), break; end
  jh=[find(diff(jn)>1) length(jn)];	% indices of holes in jn (endpoints)
  for j=1:length(jh)			% LOOP THE HOLES
    if j==1				% first hole
      jj=(jn(1)-1):(jn(jh(1))+1);	% indices of hole in Y w/bridgeheads
    else				% the rest
      jj=(jn(jh(j-1)+1)-1):(jn(jh(j))+1);
    end
    if isempty(shift),	sh=length(jj)-1;% automatic shift is bridgelength-1
    else		sh=shift;
    end
    %
    if length(jj)-2>gaplimit,			% NEW: Limit on gap size 
      Y(i,jj(2:end-1))=nan;
    elseif any(jj>N) 				% Gap at end of Y
      if logical(findstr(opt,'ends'))  
	Y(i,jj(2:end-1))=Y(i,jj(2:end-1)-sh);	% copy series before
      else
	Y(i,jj(2:end-1))=nan;
      end
    elseif any(jj<1)				% Gap at start of Y
      if logical(findstr(opt,'ends'))
	Y(i,jj(2:end-1))=Y(i,jj(2:end-1)+sh);	% copy series after
      else
	Y(i,jj(2:end-1))=nan;
      end
    else					% Find mean-bridge:	
      left=jj-sh; right=jj+sh;
      if any(right>N)				% Not enough data after gap
	%[Y(i,jj(end):end) nans(1,sh)];		% add some nans
	%ym=nanmean([Y(i,left);ans(1:1+sh)]);	% nanmean uses data before
	[Y(i,:) nans(1,sh)];			% add enough nans
	ym=nanmean([Y(i,left);ans(right)]);	% nanmean uses data before
      elseif any(left<1)			% Not enough data before gap
	%[nans(1,sh) Y(i,1:jj(1))];		% ...
	%ym=nanmean([ans(end-sh:end);Y(i,right)]);	
	[nans(1,sh) Y(i,:)];			% ...
	ym=nanmean([ans(sh+1+left);Y(i,right)]);	
      else					% Away from ends of Y = OK
	ym=nanmean([Y(i,left);Y(i,right)]);	% The mean at each point
      end
      n=length(jj);
      if  logical(findstr(opt,'lin'))		% SIMPLE linear interpolation: 
	jbh=[jj(1) jj(end)];			% indices of bridgeheads
					% Y-bridge = only hole's line
	Yb=interp1q(jbh',Y(i,jbh)',jj(2:end-1)')';   
      elseif logical(findstr(opt,'nin'))	% ONLY use mean bridge:
	Yb=ym(2:end-1);
      else					% FULL adjustment:
	yml=interp1q([1;n],[ym(1);ym(n)],[1:n]')'; % mean-bridge's line
	yy=ym-yml;				   % deviation from it
	jbh=[jj(1) jj(end)];			   % indices of bridgeheads
					% Y-bridge = hole's line + deviation
	Yb=interp1q(jbh',Y(i,jbh)',jj(2:end-1)')'+yy(2:end-1);   
        %
	% Restrain variability (only applicable in normal case):
	neig=max(left(1)-4*sh,1):min(right(end)+4*sh,N);% Find neighbourhood ...
	2*nanstd(Y(i,neig));				% range of ...
	yr=nanmean(Y(i,neig))+[-ans ans];		% variability*
        %if any(find(Yb<yr(1)|Yb>yr(2))), keyboard;end %%%%TEST
	Yb(find(Yb<yr(1)))=yr(1);			% Restrain any ...
	Yb(find(Yb>yr(2)))=yr(2);			% generated spikes*
      end
      %
      Y(i,jj(2:end-1))=Yb;
    end
  end
end

if cpx, Y=complex(Y(1:M/2,:),Y((M/2+1):end,:));  end % into complex again

if ydr==1, Y=Y'; end		% flipback original vector-direction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ^^^KERNEL^^^ %%%%%%%%%%%


% test while in keyboard:
% global t
% cage([t(neig(1)) t(neig(end))],[yr(1) yr(2)]);
