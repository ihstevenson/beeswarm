# beeswarm.m
matlab port of beeswarm-style dot plots (e.g. [in R](http://www.cbs.dtu.dk/~eklund/beeswarm/))

Ian Stevenson, CC-BY, 2019

![beeswarm.png](https://raw.githubusercontent.com/ihstevenson/beeswarm/master/beeswarm.png)

## typical use cases

beeswarm(x,y,dot_size,layout_style,overlay_style,corral_style)

xbee = beeswarm(x,y,1,layout_style,false,corral_style)

### layout-styles

{'up' [default],'fan','down','rand','square','hex'}

### overlay-styles

{'box' [default],'sd','ci'}

### corral-styles

{'none' [default], 'gutter', 'omit', 'random'}

![beeswarm_corrals.png](https://raw.githubusercontent.com/ihstevenson/beeswarm/master/beeswarm_corrals.png)