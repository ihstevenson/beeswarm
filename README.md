# beeswarm.m
matlab port of beeswarm-style dot plots. reproduces most of the functionality of [beeswarm in R](http://www.cbs.dtu.dk/~eklund/beeswarm/).

[![View beeswarm on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/70120-beeswarm)

Ian Stevenson, CC-BY, 2019

![beeswarm_dist.png](https://raw.githubusercontent.com/ihstevenson/beeswarm/master/beeswarm_dist.png)

## typical use cases

```matlab
beeswarm(x,y,...)
xbee = beeswarm(x,y,...)

% example
x = round(rand(80,1)*2);
y = randn(80,1);
beeswarm(x,y,'sort_style','up','dot_size',4)
```

### optional arguments
{sort_style, corral_style, dot_size, overlay_style, use_current_axes, colormap, MarkerFaceColor, MarkerFaceAlpha, MarkerEdgeColor}


### sort-styles

{'nosort' [default], 'up' ,'fan','down','rand','square','hex'}

![beeswarm_styles.png](https://raw.githubusercontent.com/ihstevenson/beeswarm/master/beeswarm_styles.png)

### corral-styles

{'none' [default], 'gutter', 'omit', 'random'}

![beeswarm_corrals.png](https://raw.githubusercontent.com/ihstevenson/beeswarm/master/beeswarm_corrals.png)

### overlay-styles

{'box' [default],'sd','ci'}

