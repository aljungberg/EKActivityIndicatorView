@implementation EKActivityIndicatorView : CPView
{
    BOOL        _isAnimating;
    int         _step;
    CPTimer     _timer;
    CPColor     leadColor @accessors;
    CPColor     tailColor @accessors;
    int         tailLength @accessors;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if(self) {
        _isAnimating = NO;

        // Go from white to 15% opacity by default in 9 steps. This matches the default spinner.gif roughly.
        leadColor = [CPColor colorWithCalibratedWhite:0.0 alpha:1.0];
        tailColor = [CPColor colorWithCalibratedWhite:0.0 alpha:0.15];
        tailLength = 9;
    }
    return self;
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

        CGContextSetFillColor(c, [CPColor blackColor]);

        for (i=1; i<=12; i++) {
            var tailness = MIN(tailLength, ((12 - i) + _step) % 12) / tailLength,
                leadness = 1-tailness,
                color = [CPColor colorWithCalibratedRed:[leadColor redComponent]*leadness + [tailColor redComponent]*tailness
                                                  green:[leadColor greenComponent]*leadness + [tailColor greenComponent]*tailness
                                                   blue:[leadColor blueComponent]*leadness + [tailColor blueComponent]*tailness
                                                  alpha:[leadColor alphaComponent]*leadness + [tailColor alphaComponent]*tailness];

            CGContextSetFillColor(c, color);

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

