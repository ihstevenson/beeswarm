function x = beeswarm(x,y,dsize,style,doPlot,corral)

if nargin<3, dsize=1; end
if nargin<4, style='up'; end
if nargin<5, doPlot=false; end
if nargin<6, corral='none'; end

% extra parameters
rwid = .05; % width of overlay box/dash
marker_alpha=0.5; % transparency of dots

dcut=0.12; % spacing factor
nxloc=256; % resolution for optimization
chanwid = .9; % percent width of channel to use

if doPlot
    s=scatter(x,y);
    xlim([min(x)-.5 max(x)+.5])
    yl=ylim();
    pasp_rat = get(gca,'PlotBoxAspectRatio');
    asp_rat = get(gca,'DataAspectRatio');
%     asp_rat=asp_rat(1)/asp_rat(2)*pasp_rat(1)/pasp_rat(2);
    asp_rat=pasp_rat(1)/pasp_rat(2);
end
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
        [~,e,b]=histcounts(y,edges);
        y=e(b)'+mean(diff(e))/2;
        [y,sid]=sort(y);
        b=b(sid);
    otherwise
        sid=1:length(y);
end
x=x(sid);
yorig=yorig(sid);


[ux,~,ic] = unique(x);
T=tabulate(ic);
nmax=max(T(:,2));
et=[];

k=1;

for i=1:length(ux)
    fid = find(ic==i);
    
    rmult=range(ux)*2;
    xi = linspace(-chanwid/2*rmult,chanwid/2*rmult,nxloc*rmult)'+ux(i);
    
%     zy=(y(fid)-min(y))/(max(y)-min(y))/asp_rat;
    zy=(y(fid)-min(yl))/(max(yl)-min(yl))/asp_rat*(range(ux)+1)*chanwid;
    D0=squareform(pdist(zy))<dcut*2;
    
    for j=1:length(fid)
        if strcmp(lower(style),'hex')
            if mod(b(fid(j)),2)==0
                xi = linspace(-chanwid/2*rmult,chanwid/2*rmult,nxloc*rmult)'+ux(i)+mean(diff(xi))/2;
            else
                xi = linspace(-chanwid/2*rmult,chanwid/2*rmult,nxloc*rmult)'+ux(i);
            end
        end
        zid = D0(j,1:j-1);
        e = k*(xi-ux(i)).^2;
        if ~strcmp(lower(style),'hex') && ~strcmp(lower(style),'square')
            if sum(zid)>0
                D = pdist2([xi ones(length(xi),1)*zy(j)], [x(fid(zid)) zy(zid)]);
                D(D>dcut)=Inf;
                D(D<dcut)=0;
                e = e + sum(1./D,2) + randn(1)*10e-6;
            end
        else
            if sum(zid)>0
                D = pdist2([xi ones(length(xi),1)*zy(j)], [x(fid(zid)) zy(zid)]);
                D(D==0)=Inf;
                e = e + sum(D,2);
            end
        end
        if strcmp(lower(style),'one')
            e(xi<ux(i))=Inf;
        end
        [~,mini] = min(e);
        if mini==1 && rand(1)>.5, mini=length(xi); end
        x(fid(j)) = xi(mini);
        
%         keyboard
    end
    x(fid)=x(fid)-median(x(fid))+ux(i);
    rx(i)=range(x(fid));
end
for i=1:length(ux)
    if strcmp(lower(corral),'norm')
        x(ic==i)=(x(ic==i)-ux(i))/max(rx)*.9+ux(i);
    end
end

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

if doPlot
    cmap = lines(length(ux));
    for i=1:length(ux)
        scatter(x(ic==i),y(ic==i),dsize*36,'filled','MarkerFaceAlpha',marker_alpha,'MarkerEdgeColor','none','MarkerFaceColor',cmap(i,:))
        hold on
        iqr = prctile(yorig(ic==i),[25 75]);
        switch lower(doPlot)
            case 'box'
%                 rectangle('Position',[ux(i)-rwid iqr(1) 2*rwid iqr(2)-iqr(1)],'EdgeColor',cmap(i,:),'LineWidth',2)
                rectangle('Position',[ux(i)-rwid iqr(1) 2*rwid iqr(2)-iqr(1)],'EdgeColor','k','LineWidth',2)
                line([ux(i)-rwid ux(i)+rwid],[1 1]*median(yorig(ic==i)),'LineWidth',3,'Color',cmap(i,:))
            case 'sd'
                line([1 1]*ux(i),mean(yorig(ic==i))+[-1 1]*std(yorig(ic==i)),'Color',cmap(i,:),'LineWidth',2)
                line([ux(i)-2*rwid ux(i)+2*rwid],[1 1]*mean(yorig(ic==i)),'LineWidth',3,'Color',cmap(i,:))
            case 'ci'
                line([1 1]*ux(i),mean(yorig(ic==i))+[-1 1]*std(yorig(ic==i))/sqrt(sum(ic==i))*tinv(0.975,sum(ic==i)),'Color',cmap(i,:),'LineWidth',2)
                line([ux(i)-2*rwid ux(i)+2*rwid],[1 1]*mean(yorig(ic==i)),'LineWidth',3,'Color',cmap(i,:))
        end
        
    end
    hold off
    xlim([min(ux)-.5 max(ux)+.5])
end

x(sid)=x;