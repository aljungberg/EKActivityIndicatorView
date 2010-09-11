@implementation EKActivityIndicatorView : CPView
{
	BOOL		_isAnimating;
	int		    _step;
	CPTimer		_timer;
	CPColor		_color;
	float		_colorRed;
	float		_colorGreen;
	float		_colorBlue;
}

- (id)initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	if(self) {
		_isAnimating = NO;
		[self setColor:[CPColor blackColor]];
	}
	return self;
}

- (void)setColor:(CPColor)aColor
{
	_color = aColor;
	_colorRed = [aColor redComponent];
	_colorGreen = [aColor greenComponent];
	_colorBlue = [aColor blueComponent];
}

- (void)startAnimating
{
	if (!_isAnimating) {
		_isAnimating = YES;
		_step = 1;
		_timer = [CPTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerDidFire) userInfo:nil repeats:YES];
	}
}

- (void)stopAnimating
{
	if (_isAnimating) {
		_isAnimating = NO;
		[_timer invalidate];
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)isAnimating
{
	return _isAnimating;
}

- (CPColor)color
{
	return _color;
}

- (void)timerDidFire
{
	if (_step == 12)
		_step = 1;
	else
		_step++;

	[self setNeedsDisplay:YES];
}

- (void)drawRect:(CGrect)rect
{
	var bounds = [self bounds];
	var size = bounds.size.width;
	var c = [[CPGraphicsContext currentContext] graphicsPort];

	CGContextClearRect(c, rect);

	if (_isAnimating) {
		var thickness = bounds.size.width * 0.1;
		var length = bounds.size.width * 0.28;
		var radius = thickness / 2;
		var lineRect = CGRectMake(size / 2 - thickness / 2, 0, thickness, length);
		var minx = CGRectGetMinX(lineRect);
		var midx = CGRectGetMidX(lineRect);
		var maxx = CGRectGetMaxX(lineRect);
		var miny = CGRectGetMinY(lineRect);
		var midy = CGRectGetMidY(lineRect);
		var maxy = CGRectGetMaxY(lineRect);
		var delta = [];

		CGContextSetFillColor(c, [CPColor blackColor]);

		function fillWithOpacity(opacity) {
			CGContextSetFillColor(c, [CPColor colorWithRed:_colorRed green:_colorGreen blue:_colorBlue alpha:opacity]);
		}

		for (i=1; i<=12; i++) {

			for (j=1; j<=6; j++) {
				delta[j] = (_step <= j) ? 12-j : -j;
			}

			if (i==_step) CGContextSetFillColor(c, _color);
			else if (i==_step+delta[1]) fillWithOpacity(0.9);
			else if (i==_step+delta[2]) fillWithOpacity(0.8);
			else if (i==_step+delta[3]) fillWithOpacity(0.7);
			else if (i==_step+delta[4]) fillWithOpacity(0.6);
			else if (i==_step+delta[5]) fillWithOpacity(0.5);
			else if (i==_step+delta[6]) fillWithOpacity(0.4);
			else fillWithOpacity(0.3);

			CGContextBeginPath(c);
			CGContextMoveToPoint(c, minx, midy);
			CGContextAddArcToPoint(c, minx, miny, midx, miny, radius);
			CGContextAddArcToPoint(c, maxx, miny, maxx, midy, radius);
			CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, radius);
			CGContextAddArcToPoint(c, minx, maxy, minx, midy, radius);
			CGContextFillPath(c);
			CGContextClosePath(c);
			CGContextTranslateCTM(c, size/2, size/2);
			CGContextRotateCTM(c, 30*(Math.PI/180));
			CGContextTranslateCTM(c, -size/2, -size/2);
		}
	}
}

@end
