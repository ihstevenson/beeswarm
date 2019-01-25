# beeswarm.m
matlab port of beeswarm-style dot plots. reproduces most of the functionality of [beeswarm in R](http://www.cbs.dtu.dk/~eklund/beeswarm/).

Ian Stevenson, CC-BY, 2019

![beeswarm_dist.png](https://raw.githubusercontent.com/ihstevenson/beeswarm/master/beeswarm_dist.png)

## typical use cases

beeswarm(x,y,dot_size,layout_style,overlay_style,corral_style)

xbee = beeswarm(x,y,1,layout_style,false,corral_style)

### layout-styles

{'up' [default],'fan','down','rand','square','hex'}

![beeswarm_styles.png](https://raw.githubusercontent.com/ihstevenson/beeswarm/master/beeswarm_styles.png)

### overlay-styles

{'box' [default],'sd','ci'}

### corral-styles

{'none' [default], 'gutter', 'omit', 'random'}

![beeswarm_corrals.png](https://raw.githubusercontent.com/ihstevenson/beeswarm/master/beeswarm_corrals.png)