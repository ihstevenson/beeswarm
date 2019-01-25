
%% dot size

x = round(rand(50,1)*2);
y = randn(50,1);
y(x==0)=y(x==0)+5;

figure(4)
dvec = [0.25 0.5 0.75 1]*2;
for i=1:length(dvec)
    subplot(1,length(dvec),i)
    beeswarm(x,y,dvec(i),'hex','ci');
    title(num2str(dvec(i)))
end

%% sort method

x = round(rand(80,1)*2);
y = randn(80,1);
y(x==0)=y(x==0)+2;
y(x==2)=y(x==2)-2;

figure(1);
styles={'up','fan','down','rand','square','hex'};
for i=1:length(styles)
    subtightplot(2,3,i,[0.1 0.01])
    beeswarm(x,y,2.5,styles{i},'sd','');
    title(styles{i})
    set(gca,'TitleFontSizeMultiplier',1.75)
    if i==1
        yl=ylim();
    else
        ylim(yl);
    end
	axis off
end



%% overlay

x = round(rand(100,1)*2);
y = randn(100,1);
y(x==0)=y(x==0)+5;
figure(2)
plotstyles={'box','sd','ci'};
for i=1:length(styles)
    subplot(1,length(plotstyles),i)
    beeswarm(x,y,2.5,'',plotstyles{i});
    title(plotstyles{i})
end

%% corral

x = round(rand(800,1)*2);
y = randn(800,1);
y(x==0)=y(x==0)+2;
figure(3)
corralstyles = {'none','gutter','omit','random'};
for i=1:length(corralstyles)
    subplot(1,length(corralstyles),i)
    beeswarm(x,y,1,'up','ci',corralstyles{i});
    title(corralstyles{i})
end