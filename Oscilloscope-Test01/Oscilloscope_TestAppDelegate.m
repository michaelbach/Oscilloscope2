//
//  Oscilloscope_TestAppDelegate.m
//  Oscilloscope-Test
//
//  Created by bach on 21.03.10.
//  Copyright 2010 Universitäts-Augenklinik. All rights reserved.
//

#import "Oscilloscope_TestAppDelegate.h"


@implementation Oscilloscope_TestAppDelegate


dispatch_source_t timerGCDOsci;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	// set some properties of the oscilloscope
	osci.fullscale = 5.0;  osci.numberOfTraces = 5;

	// set up the demo GUI
	[numberOfChannels_outlet removeAllItems];
	for (NSUInteger	iTrace=0; iTrace < osci.maxNumberOfTraces; ++iTrace)
		[numberOfChannels_outlet addItemWithTitle: [NSString stringWithFormat:@"%D", iTrace+1]];
	[numberOfChannels_outlet selectItemAtIndex: osci.numberOfTraces-1];
	[colorBackg_outlet setColor: [osci backgroundColor]];
	[colorSeparators_outlet setColor: [osci separatorColor]];
	
	// set up a grand-central-dispatch based timer task 
	timerGCDOsci = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
	dispatch_source_set_timer(timerGCDOsci, dispatch_time(DISPATCH_TIME_NOW, 0), /*interv*/ 30000000ull , /*leeway*/ 10000000ull);
	// whose block advances the osciloscope trace(s) with random values
	dispatch_source_set_event_handler(timerGCDOsci, ^{
		static int counter1 = 0, counter2 = 0;  ++counter1;
		if ((counter1 % 10) == 0) ++counter2;
		NSMutableArray *voltages = [NSMutableArray arrayWithCapacity: osci.numberOfTraces];
		for (NSUInteger iTrace = 0; iTrace < osci.numberOfTraces; ++iTrace) {
			CGFloat rVoltage;
			// random
			rVoltage = (2.0 * random() / (CGFloat)RAND_MAX - 1.0) * osci.fullscale;
			// no, lets test whether the fullscale is ok
			switch (counter2 % 4) {
				case 1: rVoltage = osci.fullscale; break;
				case 3: rVoltage = -osci.fullscale; break;
				default: rVoltage = 0;
			}
			[voltages addObject: [NSNumber numberWithFloat: rVoltage]];
		}
		[osci advanceWithSamples: voltages];
	});
	dispatch_resume(timerGCDOsci);
}


- (IBAction) numberOfChannels_action: (id) sender {
	osci.numberOfTraces = [sender indexOfSelectedItem]+1;
}

- (IBAction) movingCheckBox_action: (id) sender {
	osci.isShiftTraces = [sender state] == NSOnState;
}

- (IBAction) colorBackg_action: (id) sender {
	[osci setBackgroundColor: [sender color]];
}
- (IBAction) colorSeparators_action: (id) sender {
	[osci setSeparatorColor: [sender color]];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}


@end
