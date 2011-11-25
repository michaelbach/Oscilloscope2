/* Oscilloscope2 */

#import <Cocoa/Cocoa.h>

#define kOscilloscope2MaxNumberOfTraces 8

//	History
//	=======
//
//	2011-11-25	a little cleanup to more modern obj-c
//	2011-01-26	added lineWidth
//	2010-03-21	renamed and extended "fullscale", general code cleanup
//	2010-03-03	in "advanceWithSamples:" test if "numberOfTraces" is correct, else set. Same for "setTrace:"
//	2010-02-24	added gray dividing lines between traces
//	2010-02-23	lots of recent changes, today added decimation in "setTrace"
//	2009-12-30	added @property
/*
This oscilloscope can have one or up to kOscilloscopeMaxNumberOfTraces traces.
Most calls are availabe in both single- and multichannel mode.
 
The oscilloscope advances 1 point in device space per call (advanceWithSample(s))
Entire sweeps can also be displayed with setTrace:toSweep: / setSingleTraceToSweep:
0 is in the center, the vertical scaling is addressed by calling setMaxPositiveValue:.
 
To insert in your program:
In your controller class: create an Oscilloscope2* IBOutlet.
In Interface Builder: instantiate a Custom View, set it's class to Oscilloscope2, then connect it with the IBOutlet.
*/


@interface Oscilloscope2 : NSView {
	NSUInteger numberOfPoints, numberOfTraces, maxNumberOfTraces;
	CGFloat width, height, fullscale, lineWidth;
	NSColor *backgroundColor, *separatorColor;
	BOOL isTraceZeroTop, isShiftTraces;
}


- (void) advanceWithSample: (CGFloat) sampleValue;				// switches to single channel mode
- (void) advanceWithSamples: (NSArray *) sampleArrayOfNumbers;	// switches multichannel mode with the correct number of traces
- (void) setTraceToSweep: (NSArray *) sweep;					// switches to single channel mode
- (void) setTrace:(NSUInteger)iTrace toSweep:(NSArray*)sweep;	// switches multichannel mode; adjusts numberOfTraces if necessary

@property	(readwrite)	CGFloat fullscale;						// since we're bipolar: ± this value
@property	(readonly)	NSUInteger numberOfPoints;				// width of the corresponding view in device points
@property	(readwrite)	NSUInteger numberOfTraces;				// multichannel; number of traces
@property	(readonly)	NSUInteger maxNumberOfTraces;			// multichannel; maximal possible number of traces

@property	(readonly)	CGFloat width, height;					// view dimensions
- (void)	setColor: (NSColor *) color;						// switches to single channel mode. Default: dark blue.
- (void)	setColor: (NSColor *) color forTrace: (NSUInteger) iTrace;// multichannel; there are 7 predefined colors
@property	(retain)	NSColor *backgroundColor;				// default: very light grey
@property	(retain)	NSColor *separatorColor;				// default: grey
@property	(readwrite) CGFloat lineWidth;						// the pensize for the traces
@property	(readwrite) BOOL isTraceZeroTop;					// trace ordering: trace zero is on top, or on bottom
@property	(readwrite)	BOOL isShiftTraces;						// if YES: traces are moving, new values at right. Else just replacing


@end
