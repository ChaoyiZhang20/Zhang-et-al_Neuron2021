function [Y,b] = baselineEst(X,Y,varargin)

% modified from MSBACKADJ.m for baseline output
% References: 
% [1] Lucio Andrade and Elias Manolakos, "Signal Background Estimation and
%     Baseline Correction Algorithms for Accurate DNA Sequencing" Journal
%     of VLSI, special issue on Bioinformatics 35:3 pp 229-243 (2003)

% check inputs
bioinfochecknargin(nargin,2,mfilename);
% set defaults
stepSize = 200;
windowSize = 200;
regressionMethod = 'pchip';
estimationMethod = 'quantile';
smoothMethod = 'none';
quantileValue = 0.1;
preserveHeights = false;
maxNumWindows = 1000;
if nargout == 1
    plotId = 0; 
else
    plotId = 1;
end

if  nargin > 2
    if rem(nargin,2) == 1
        error(message('bioinfo:msbackadj:IncorrectNumberOfArguments', mfilename));
    end
    okargs = {'stepsize','windowsize','regressionmethod',...
              'estimationmethod','quantilevalue','preserveheights',...
              'smoothmethod','showplot'};
    for j=1:2:nargin-2
        pname = varargin{j};
        pval = varargin{j+1};
        k = find(strncmpi(pname, okargs,length(pname)));
        if isempty(k)
            error(message('bioinfo:msbackadj:UnknownParameterName', pname));
        elseif length(k)>1
            error(message('bioinfo:msbackadj:AmbiguousParameterName', pname));
        else
            switch(k)
				case 1  % step size
					if ~(isscalar(pval)&&isnumeric(pval)) && ~isa(pval,'function_handle')
						error(message('bioinfo:msbackadj:NotValidStepSize'))
					end
					stepSize = pval;
				case 2 % window size
					if ~(isscalar(pval)&&isnumeric(pval)) && ~isa(pval,'function_handle')
						error(message('bioinfo:msbackadj:NotValidWindowSize'))
					end
					windowSize = pval;
                case 3 % regression method
                    regressionMethods = {'cubic','pchip','spline','linear'};
                    regressionMethod = strmatch(lower(pval),regressionMethods); 
                    if isempty(regressionMethod) 
                        error(message('bioinfo:msbackadj:NotValidRegressionMethod'))
                    end
                    regressionMethod = regressionMethods{max(2,regressionMethod)};
                case 4 % estimation method
                    estimationMethods = {'quantile','em'};
                    estimationMethod = strmatch(lower(pval),estimationMethods); 
                    if isempty(estimationMethod) 
                        error(message('bioinfo:msbackadj:NotValidEstimationMethod'))
                    end
                    estimationMethod = estimationMethods{estimationMethod};
                case 5 % quantile value
					if ~(isscalar(pval)&&isnumeric(pval))
						 error(message('bioinfo:msbackadj:NotValidQuantileValue'))
					end
                    quantileValue = pval;
                case 6 % preserve heights
                    preserveHeights = bioinfoprivate.opttf(pval,okargs{k},mfilename);
                case 7 % smoothing method
                    smoothMethods = {'none','lowess','loess','rlowess','rloess'};
                    smoothMethod = strmatch(lower(pval),smoothMethods); 
                    if isempty(smoothMethod) 
                        error(message('bioinfo:msbackadj:NotValidSmoothMethod'))
                    elseif length(smoothMethod)>1
                        error(message('bioinfo:msbackadj:AmbiguousSmoothMethod', pval));
                    end
                    smoothMethod = smoothMethods{smoothMethod};
                case 8 % show
                    if bioinfoprivate.opttf(pval) 
                        if isnumeric(pval)
                            if isscalar(pval)
                                plotId = double(pval); 
                            else
                                plotId = 1;
                                warning(message('bioinfo:msbackadj:SPNoScalar'))
                            end 
                        else
                            plotId = 1;
                        end
                    else
                        plotId = 0;
                    end
            end
        end
    end
end

% validate X and Y
X = X';
Y = Y';


if ~isnumeric(Y) || ~isreal(Y)
   error(message('bioinfo:msbackadj:IntensityNotNumericAndReal')) 
end

if ~isnumeric(X) || ~isreal(X)
   error(message('bioinfo:msbackadj:XNotNumericAndReal')) 
end

if size(X,1) ~= size(Y,1)
   error(message('bioinfo:msbackadj:NotEqualNumberOfSamples'))
end
 
numSignals = size(Y,2);

if (plotId~=0) && ~any((1:numSignals)==plotId)
    warning(message('bioinfo:msbackadj:InvalidPlotIndex'))
end

multiple_X = false;
if size(X,2)>1
    multiple_X = true;
    if size(X,2) ~= numSignals
        error(message('bioinfo:msbackadj:NotEqualNumberOfXScales'))
    end
end

% change scalars to function handlers
if isnumeric(stepSize)   
    stepSize   = @(x) repmat(stepSize,size(x));   
end
if isnumeric(windowSize) 
    windowSize = @(x) repmat(windowSize,size(x)); 
end

% allocate space for Xp and WE
Xp = zeros(maxNumWindows,1);
WE = nan(maxNumWindows,1);

% calculates the location of the windows (when it is the same for all the
% signals)
if ~multiple_X
	Xpid = max(0,X(1));
	Xend = X(end);
	id = 1;
	while Xpid <= Xend
		Xp(id) = Xpid;
		Xpid = Xpid + stepSize(Xpid);
		id = id + 1;
		if id > maxNumWindows
			error(message('bioinfo:msbackadj:MaxNumWindowsExceeded'))
		end
	end
	numWindows = id-1;
	if numWindows==1
		warning(message('bioinfo:msbackadj:NotSufficientWindows'))
	end
end



% iterate for every signal
for ns = 1:numSignals 
if nargout>0 || (ns == plotId)
    % find the location of the windows (when it is different for every
    % signal, otherwise this was done out of the loop)
	if multiple_X
		Xpid = max(0,X(1,ns));
		Xend = X(end,ns);
		id = 1; Xp = zeros(1,maxNumWindows);
		while Xpid <= Xend
			Xp(id) = Xpid;
			Xpid = Xpid + stepSize(Xpid);
			id = id + 1;
			if id > maxNumWindows
				error(message('bioinfo:msbackadj:MaxNumWindowsExceeded'))
			end
		end
		Xp(id:end)=[];
		numWindows = id-1;
		if numWindows==1
			warning(message('bioinfo:msbackadj:NotSufficientWindows'))
		end
		nnss = ns;
	else
		nnss = 1;
	end
    Xpt = Xp(1:numWindows); 
    Xw = windowSize(Xpt);
    
    % find the estimated baseline for every window
    for nw = 1:numWindows
        subw = Y(X(:,nnss)>=Xpt(nw) & X(:,nnss)<= (Xpt(nw)+Xw(nw)),ns);
        switch estimationMethod
            case 'quantile'
                WE(nw) = quantile(subw,quantileValue);
            case 'em'
                WE(nw) = em2c1d(subw);
        end
    end % for nw = 1:numWindows
    
    % smooth the estimated points
    if ~isequal('none',smoothMethod)
        WE(1:numWindows) = ...
            bioinfoprivate.masmooth(Xpt+Xw/2,WE(1:numWindows),10,smoothMethod,2);
    end
            
    % regress the estimated points
	if numWindows==1
		b(:,ns) = repmat(WE(1),size(X,1),1);
	else
        b(:,ns) = interp1(Xpt+Xw/2,WE(1:numWindows),X(:,nnss),regressionMethod);
	end
    
%     if (ns == plotId)
%        figure('Tag', 'msbackadj')
%        plot(X(:,nnss),Y(:,ns))
%        hold on
%        plot(X(:,nnss),b(:,ns),'r','linewidth',2)
%        plot(Xpt+Xw/2,WE(1:numWindows),'kx')
%        title(sprintf('Signal ID: %d',ns));
%        xlabel('Separation Units')
%        ylabel('Relative Intensity')
%        legend('Original Signal','Regressed baseline','Estimated baseline points')
%        axis([min(X(:,nnss)) max(X(:,nnss)) min(Y(:,ns)) max(Y(:,ns))])
%        grid on
%        hold off
%        setAllowAxesRotate(rotate3d(gcf),gca,false)
%     end
    
    % apply the correction
    if preserveHeights
        K = 1 - b(:,ns)/max(Y(:,ns));
        Y(:,ns) = (Y(:,ns) - b(:,ns)) ./ K;
        %[YMax,locMax] = max(Y(:,ns));
        %K = 1 - b(locMax)/YMax;
        %Y(:,ns) = (Y(:,ns) - b) / K;
    else
        Y(:,ns) = (Y(:,ns) - b(:,ns));
    end 

end % if nargout>0 || (ns == plotId)    
end % for ns = 1:numSignals 

Y = Y';
b = b';

if nargout == 0 
    clear Y
end



    
    
