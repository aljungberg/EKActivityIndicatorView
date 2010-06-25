var SharedEKActivityIndicatorViewAnimation = nil;

@implementation EKActivityIndicatorView : CPView
{
    CPAnimation _animation;
    CPColor     leadColor @accessors;
    CPArray     _leadComponents;
    CPColor     tailColor @accessors;
    CPArray     _tailComponents;
    CPArray     _stepColors;
    int         tailLength @accessors;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if(self) {
        _animation = [_EKActivityIndicatorViewAnimation sharedIndicatorViewAnimation];

        // Go from black to 15% opacity by default in 9 steps. This matches the default spinner.gif roughly.
        [self setLeadColor:[CPColor colorWithCalibratedWhite:0.0 alpha:1.0]];
        [self setTailColor:[CPColor colorWithCalibratedWhite:0.0 alpha:0.15]];
        [self setTailLength:9];

        [self startAnimation];
    }
    return self;
}

- (void)startAnimation
{
    [_animation startActivityIndicatorAnimation:self];
}

- (void)stopAnimation
{
    [_animation stopActivityIndicatorAnimation:self];
}

- (BOOL)isAnimating
{
    return [_animation isAnimatingActivityIndicator:self];
}

- (void)setLeadColor:(CPColor)aColor
{
    leadColor = aColor;
    _leadComponents = [self _colorAsComponents:aColor];
    [self _precalculateStepColors];
}

- (void)setTailColor:(CPColor)aColor
{
    tailColor = aColor;
    _tailComponents = [self _colorAsComponents:aColor];
    [self _precalculateStepColors];
}

- (void)setTailLength:(int)aLength
{
    tailLength = aLength;
    [self _precalculateStepColors];
}

- (CPArray)_colorAsComponents:(CPColor)aColor
{
    r = [];
    r[0] = [aColor redComponent];
    r[1] = [aColor greenComponent];
    r[2] = [aColor blueComponent];
    r[3] = [aColor alphaComponent];
    return r;
}

- (void)_precalculateStepColors
{
    if (leadColor === nil || tailColor === nil || tailLength === nil)
        return;

    _stepColors = [];
    for (var i=1; i<=12; i++)
    {
        var tailness = MIN(tailLength, (11 - i) % 12) / tailLength,
            leadness = 1-tailness;

        _stepColors[i] = [CPColor colorWithCalibratedRed:_leadComponents[0]*leadness + _tailComponents[0]*tailness
                                                   green:_leadComponents[1]*leadness + _tailComponents[1]*tailness
                                                    blue:_leadComponents[2]*leadness + _tailComponents[2]*tailness
                                                   alpha:_leadComponents[3]*leadness + _tailComponents[3]*tailness];
    }
}

- (void)drawRect:(CGrect)rect
{
    var c = [[CPGraphicsContext currentContext] graphicsPort];

    CGContextClearRect(c, rect);

    if (!_stepColors)
        return;

    var bounds = [self bounds],
        size = bounds.size.width,
        thickness = bounds.size.width * 0.1,
        length = bounds.size.width * 0.28,
        radius = thickness / 2,
        lineRect = CGRectMake(size / 2 - thickness / 2, 0, thickness, length),
        minx = CGRectGetMinX(lineRect),
        midx = CGRectGetMidX(lineRect),
        maxx = CGRectGetMaxX(lineRect),
        miny = CGRectGetMinY(lineRect),
        midy = CGRectGetMidY(lineRect),
        maxy = CGRectGetMaxY(lineRect),
        _step = 1;

    CGContextTranslateCTM(c, size/2, size/2);
    CGContextRotateCTM(c, [_animation currentValue] * (Math.PI*2));
    CGContextTranslateCTM(c, -size/2, -size/2);

    for (var i=1; i<=12; i++)
    {
        CGContextSetFillColor(c, _stepColors[i]);

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

@end

@implementation _EKActivityIndicatorViewAnimation : CPAnimation
{
    CPArray activityIndicators;
}

+ (_EKActivityIndicatorViewAnimation)sharedIndicatorViewAnimation
{
    if (SharedEKActivityIndicatorViewAnimation === nil)
        SharedEKActivityIndicatorViewAnimation = [_EKActivityIndicatorViewAnimation new];
    return SharedEKActivityIndicatorViewAnimation;
}

- (id)init
{
    if (self = [super initWithDuration:1.4 animationCurve:CPAnimationLinear])
    {
        [self setFrameRate:24];
        activityIndicators = [];
    }
    return self;
}

- (void)startActivityIndicatorAnimation:(EKActivityIndicatorView)anActivityIndicator
{
    if ([activityIndicators containsObject:anActivityIndicator])
        return;

    [activityIndicators addObject:anActivityIndicator];

    if (activityIndicators.length == 1)
        [self startAnimation];
}

- (void)stopActivityIndicatorAnimation:(EKActivityIndicatorView)anActivityIndicator
{
    [activityIndicators removeObject:anActivityIndicator];

    if (activityIndicators.length == 0)
        [self stopAnimation];
}

- (void)isAnimatingActivityIndicator:(EKActivityIndicatorView)anActivityIndicator
{
    return [activityIndicators containsObject:anActivityIndicator];
}

- (void)setCurrentProgress:(float)aProgress
{
    _progress = aProgress;

    var count = activityIndicators.length;
    while (count-- >= 0)
        [activityIndicators[count] setNeedsDisplay:YES];
}

- (void)animationTimerDidFire:(CPTimer)aTimer
{
    var currentTime = new Date(),
        progress = ([self currentProgress] + (currentTime - _lastTime) / (_duration * 1000.0)) % 1.0;

    _lastTime = currentTime;

    ++ACTUAL_FRAME_RATE;

    [self setCurrentProgress:progress];

    // Never end.
}

@end
