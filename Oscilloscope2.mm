// http://maccoder.blogspot.com/2007/02/nssavepanel-in-objective-c.html

#import "Oscilloscope2.h"


@implementation Oscilloscope2;


NSMutableArray  *traceColors, *allTraces; // has maxChannels objects, each is a mutable array of samples


//#define max(x,y) ((x) > (y)) ? (x) : (y)
#define min(x,y) ((x) > (y)) ? (y) : (x)


@synthesize	numberOfPoints;
@synthesize	fullscale;
@synthesize width;
@synthesize height;
@synthesize backgroundColor;
@synthesize separatorColor;
@synthesize isShiftTraces;
@synthesize lineWidth;
@synthesize isTraceZeroTop;
@synthesize maxNumberOfTraces;


- (id) initWithFrame:(NSRect)frameRect {	//NSLog(@"Oscilloscope>init");
	if ((self = [super initWithFrame: frameRect]) != nil) {
		width = frameRect.size.width;  height = frameRect.size.height;
		[self setIsTraceZeroTop: YES];
		[self setFullscale: 3.0f];
		numberOfPoints = (NSUInteger) round(width);
		maxNumberOfTraces = kOscilloscope2MaxNumberOfTraces;
		[self setNumberOfTraces: 2];
		[self setIsShiftTraces: YES];
		[self setLineWidth: 1.0f];
		allTraces = [[NSMutableArray arrayWithCapacity: maxNumberOfTraces] retain];
		for (NSUInteger iTrace=0; iTrace<maxNumberOfTraces; ++iTrace) 
			[allTraces addObject: [NSMutableArray arrayWithCapacity: numberOfPoints]];
		for (NSMutableArray *aTrace in allTraces)	// initialise all traces to 0.0
			for (NSUInteger i=0; i<numberOfPoints; ++i) [aTrace addObject: [NSNumber numberWithFloat:0.0f]];
		[self setBackgroundColor: [NSColor colorWithDeviceWhite: 0.9f alpha: 1.0f]];
		[self setSeparatorColor: [NSColor grayColor]];
		traceColors = [[NSMutableArray arrayWithCapacity: maxNumberOfTraces] retain];
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.667 saturation: 1.0 brightness: 0.6 alpha: 1.0]];	// dunkles Blau
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.250 saturation: 1.0 brightness: 0.5 alpha: 1.0]];	// dunkles Grün
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.000 saturation: 1.0 brightness: 0.7 alpha: 1.0]];	// dunkles Rot
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.500 saturation: 1.0 brightness: 0.6 alpha: 1.0]];	// dunkles Cyan
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.833 saturation: 1.0 brightness: 0.6 alpha: 1.0]];	// dunkles Magenta
		[traceColors addObject: [NSColor colorWithDeviceHue: 0.125 saturation: 1.0 brightness: 0.6 alpha: 1.0]];	// dunkles Gelb
	}
	return self;
}


- (void) dealloc {	//	NSLog(@"Oscilloscope>dealloc\n");
	for (NSMutableArray *aTrace in allTraces) [aTrace release];  
	[allTraces release];
	for (NSColor *col in traceColors) [col release];  
	[traceColors release];
	[backgroundColor release];  
	[separatorColor release];  
	[super dealloc];
}


- (BOOL) isOpaque {return YES;}


- (void) drawRect:(NSRect)aRect {
	height = aRect.size.height; // so resizing works at least vertically

	[backgroundColor set];  NSRectFill(aRect);	// first fill the background
	NSUInteger numPnts = [[allTraces objectAtIndex: 0] count];
	for (NSUInteger iTrace = 1; iTrace < numberOfTraces; ++iTrace) { // draw trace separator lines
		NSBezierPath *path = [NSBezierPath bezierPath];
		CGFloat yTrace = ((isTraceZeroTop) ? (numberOfTraces-iTrace) : (iTrace)) * height / numberOfTraces;
		[path moveToPoint: NSMakePoint(0, yTrace)]; [path lineToPoint: NSMakePoint(numPnts, yTrace)];
		[separatorColor set];
		[path stroke];
	}

	for (NSUInteger iTrace = 0; iTrace < numberOfTraces; ++iTrace) { // now draw the traces
		NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path setLineWidth: [self lineWidth]];
		CGFloat yTrace = (isTraceZeroTop) ? (numberOfTraces-iTrace-0.5) : (iTrace+0.5);
		SEL lineToPointSel = @selector(lineToPoint:); // avoiding the method calling chain
		IMP lineToPointFunPtr = [path methodForSelector: lineToPointSel]; // speeds up a little
		for (NSUInteger iSample=0; iSample < numPnts; ++iSample) {
			NSPoint p = NSMakePoint(iSample, (yTrace + [[aTrace objectAtIndex: iSample] floatValue]/2.0/fullscale) * height / numberOfTraces);
			if (iSample == 0) [path moveToPoint: p]; else lineToPointFunPtr(path, lineToPointSel, p);//[path lineToPoint: p];
		}
		[((NSColor *)[traceColors objectAtIndex: (iTrace % [traceColors count])]) set];
		[path stroke];
	}
}


- (void) advanceWithSample: (CGFloat) sampleValue {	// single channel
	[self setNumberOfTraces: 1];
	[self advanceWithSamples: [NSArray arrayWithObject: [NSNumber numberWithFloat: sampleValue]]];
}

- (void) advanceWithSamples: (NSArray *) sampleArray {		// multichannel
	static NSUInteger sampleIndex = 0;  sampleIndex = (sampleIndex+1) % numberOfPoints;
	NSUInteger nTraces = min(maxNumberOfTraces, sampleArray.count);
	if (nTraces != numberOfTraces) numberOfTraces = nTraces;
	for (NSUInteger iTrace = 0; iTrace < nTraces; ++iTrace) {
		NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
		if (isShiftTraces) {
			[aTrace removeObjectAtIndex: 0];  [aTrace addObject: [sampleArray objectAtIndex: iTrace]];
		} else {
			[aTrace replaceObjectAtIndex: sampleIndex withObject: [sampleArray objectAtIndex: iTrace]];
		}
	}
	[self setNeedsDisplay: YES];
}


- (void) setTraceToSweep: (NSArray *) sweep {	// single channel
	[self setNumberOfTraces: 1];  [self setTrace: 0 toSweep: sweep];
}

- (void) setTrace: (NSUInteger) iTrace toSweep: (NSArray *) sweep {	// multichannel
	if (iTrace >= maxNumberOfTraces) return;
	if (iTrace >= numberOfTraces) [self setNumberOfTraces: iTrace+1];
	NSMutableArray *aTrace = [allTraces objectAtIndex: iTrace];
	while (sweep.count > numberOfPoints) {	// while the sweep is longer than the trace, we decimate by 2 until it fits
		NSMutableArray *a = [NSMutableArray arrayWithCapacity:sweep.count/2];
		for (NSUInteger i = 0; i<sweep.count/2; ++i) [a addObject:[NSNumber numberWithFloat: 0.5*([[sweep objectAtIndex:i*2] floatValue] + [[sweep objectAtIndex:i*2+1] floatValue])]];
		sweep = [NSArray arrayWithArray: a];
	}
	NSNumber *aNAN = [NSNumber numberWithFloat:NAN];
	for (NSUInteger iSmpl=0; iSmpl<numberOfPoints; ++iSmpl)
		[aTrace replaceObjectAtIndex:iSmpl withObject: ((iSmpl < sweep.count) ? [sweep objectAtIndex:iSmpl] : aNAN)];
	[self setNeedsDisplay:YES];
}


- (void) setColor: (NSColor *) color {
	numberOfTraces = 1;  [traceColors replaceObjectAtIndex: 0 withObject: color];
}
- (void) setColor: (NSColor *) color forTrace: (NSUInteger) iTrace {
	if (iTrace > maxNumberOfTraces) return;
	[traceColors replaceObjectAtIndex: iTrace withObject: color];
}


- (NSUInteger) numberOfTraces {return numberOfTraces;};
- (void) setNumberOfTraces:(NSUInteger) n {
	numberOfTraces = (n > maxNumberOfTraces) ? maxNumberOfTraces : n;
}


@end
