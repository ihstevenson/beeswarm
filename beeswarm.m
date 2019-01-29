function x = beeswarm(x,y,dsize,style,doPlot,corral)
%function xbee = beeswarm(x,y,dot_size,plot_style,overlay_style,corral_style)
%
% Input arguments:
%   x               column vector of groups (only tested for integer)
%   y               column vector of data
%   dot_size        relative. default=1
%   plot_style      {'up' default, 'down', 'fan', 'rand', 'square', 'hex'}
%   overlay_style   {false default, 'box', 'sd', 'ci'}
%   corral_style    {'none' default, 'gutter', 'omit', 'rand'}
%
% Output arguments:
%   xbee            optimized layout positions
%
% Known Issues:
%       x locations depend on figure aspect ratio. resizing the figure window and rerunning may give different results
%
% Usage example:
% 	x = round(rand(150,1)*5);
%   y = randn(150,1);
%   beeswarm(x,y,3,'up','ci')
%
% % Ian Stevenson, CC-BY 2019

if nargin<3, dsize=1; end
if nargin<4, style='up'; end
if nargin<5, doPlot=false; end
if nargin<6, corral='none'; end

% extra parameters
rwid = .05; % width of overlay box/dash
marker_alpha=0.3; % transparency of dots

dcut=0.12; % spacing factor
nxloc=256; % resolution for optimization
chanwid = .9; % percent width of channel to use

% get aspect ratio for figure window
if doPlot
    s=scatter(x,y);
    xlim([min(x)-.5 max(x)+.5])
    yl=ylim();
    pasp_rat = get(gca,'PlotBoxAspectRatio');
    asp_rat = get(gca,'DataAspectRatio');
    asp_rat=pasp_rat(1)/pasp_rat(2);
end

% sort/round y for different plot styles
yorig=y;
switch lower(style)
    case 'up'
        [y,sid]=sort(y);
    case 'fan'
        [~,sid]=sort(abs(y-mean(y)));
        sid=[sid(1:2:end); sid(2:2:end)];
        y=y(sid);
    case 'down'
        [y,sid]=sort(y,'descend');
    case 'rand'
        sid=randperm(length(y));
        y=y(sid);
    case 'square'
        nxloc=7;
%         [~,e,b]=histcounts(y,ceil((range(x)+1)*chanwid*nxloc/2/asp_rat));
        edges = linspace(min(yl),max(yl),ceil((range(x)+1)*chanwid*nxloc/asp_rat));
        [~,e,b]=histcounts(y,edges);
        y=e(b)'+mean(diff(e))/2;
        [y,sid]=sort(y);
    case 'hex'
        nxloc=7;
%         [~,e,b]=histcounts(y,ceil((range(x)+1)*chanwid*nxloc/2/sqrt(1-.5.^2)/asp_rat));
        edges = linspace(min(yl),max(yl),ceil((range(x)+1)*chanwid*nxloc/sqrt(1-.5.^2)/asp_rat));
        [n,e,b]=histcounts(y,edges);
        oddmaj=0;
        if sum(mod(n(1:2:end),2)==1)>sum(mod(n(2:2:end),2)==1),
            oddmaj=1;
        end
        y=e(b)'+mean(diff(e))/2;
        [y,sid]=sort(y);
        b=b(sid);
    otherwise
        sid=1:length(y);
end
x=x(sid);
yorig=yorig(sid);
[ux,~,ic] = unique(x);
rmult=range(ux)*2;

% for each group...
for i=1:length(ux)
    fid = find(ic==i);   
    
    % set of possible x locations
    xi = linspace(-chanwid/2*rmult,chanwid/2*rmult,nxloc*rmult+(mod(nxloc*rmult,2)==0))'+ux(i);

    % rescale y to that things are square visually
    zy=(y(fid)-min(yl))/(max(yl)-min(yl))/asp_rat*(range(ux)+1)*chanwid;
    
    % precalculate y distances so that we only worry about nearby points
    D0=squareform(pdist(zy))<dcut*2;    
    
    % for each data point in the group sequentially...
    for j=1:length(fid)
        if strcmp(lower(style),'hex')
            if mod(b(fid(j)),2)==oddmaj
                xi = linspace(-chanwid/2*rmult,chanwid/2*rmult,nxloc*rmult+(mod(nxloc*rmult,2)==0))'+ux(i)+mean(diff(xi))/2;
            else
                xi = linspace(-chanwid/2*rmult,chanwid/2*rmult,nxloc*rmult+(mod(nxloc*rmult,2)==0))'+ux(i);
            end
        end
        zid = D0(j,1:j-1);
        e = (xi-ux(i)).^2; % cost function
        if ~strcmp(lower(style),'hex') && ~strcmp(lower(style),'square')
            if sum(zid)>0
                D = pdist2([xi ones(length(xi),1)*zy(j)], [x(fid(zid)) zy(zid)]);
                D(D<=dcut)=Inf;
                D(D>dcut & isfinite(D))=0;
                e = e + sum(D,2) + randn(1)*10e-6; % noise to tie-break
            end
        else
            if sum(zid)>0
                D = pdist2([xi ones(length(xi),1)*zy(j)], [x(fid(zid)) zy(zid)]);
                D(D==0)=Inf;
                D(D>dcut & isfinite(D))=0;
                e = e + sum(D,2) + randn(1)*10e-6; % noise to tie-break
            end
        end
        
        if strcmp(lower(style),'one')
            e(xi<ux(i))=Inf;
        end
        [~,mini] = min(e);
        if mini==1 && rand(1)>.5, mini=length(xi); end
        x(fid(j)) = xi(mini);
    end
%     x(fid)=x(fid)-median(x(fid))+ux(i); % center x locations by median
end

if strcmp(lower(style),'randn')
    x=ux(ic)+randn(size(ic))/4;
end

% corral any points outside of the channel
out_of_range = abs(x-ux(ic))>chanwid/2;
switch lower(corral)
    case 'gutter'
        id = (x-ux(ic))>chanwid/2;
        x(id)=chanwid/2+ux(ic(id));
        id = (x-ux(ic))<-chanwid/2;
        x(id)=-chanwid/2+ux(ic(id));
    case 'omit'
        x(out_of_range)=NaN;
    case 'random'
        x(out_of_range)=ux(ic(out_of_range))+rand(sum(out_of_range),1)*chanwid-chanwid/2;
end

% plot groups and add overlay
if doPlot
    cmap = lines(length(ux));
    for i=1:length(ux)
        scatter(x(ic==i),y(ic==i),dsize*36,'filled','MarkerFaceAlpha',marker_alpha,'MarkerEdgeColor','none','MarkerFaceColor',cmap(i,:))
        hold on
        iqr = prctile(yorig(ic==i),[25 75]);
        switch lower(doPlot)
            case 'box'
                rectangle('Position',[ux(i)-rwid iqr(1) 2*rwid iqr(2)-iqr(1)],'EdgeColor','k','LineWidth',2)
                line([ux(i)-rwid ux(i)+rwid],[1 1]*median(yorig(ic==i)),'LineWidth',3,'Color',cmap(i,:))
            case 'sd'
                line([1 1]*ux(i),mean(yorig(ic==i))+[-1 1]*std(yorig(ic==i)),'Color',cmap(i,:),'LineWidth',2)
                line([ux(i)-2*rwid ux(i)+2*rwid],[1 1]*mean(yorig(ic==i)),'LineWidth',3,'Color',cmap(i,:))
            case 'ci'
                line([1 1]*ux(i),mean(yorig(ic==i))+[-1 1]*std(yorig(ic==i))/sqrt(sum(ic==i))*tinv(0.975,sum(ic==i)-1),'Color',cmap(i,:),'LineWidth',2)
                line([ux(i)-2*rwid ux(i)+2*rwid],[1 1]*mean(yorig(ic==i)),'LineWidth',3,'Color',cmap(i,:))
        end
        
    end
    hold off
    xlim([min(ux)-.5 max(ux)+.5])
end

% unsort so that output matches the original y data
x(sid)=x;