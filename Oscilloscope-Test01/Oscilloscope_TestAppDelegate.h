//
//  Oscilloscope_TestAppDelegate.h
//  Oscilloscope-Test
//
//  Created by bach on 21.03.10.
//  Copyright 2010 Universitäts-Augenklinik. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Oscilloscope2.h"

@interface Oscilloscope_TestAppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet Oscilloscope2 *osci;	
	IBOutlet NSPopUpButton *numberOfChannels_outlet;
	IBOutlet NSColorWell *colorBackg_outlet, *colorSeparators_outlet;
}


- (IBAction) numberOfChannels_action: (id) sender;
- (IBAction) movingCheckBox_action: (id) sender;
- (IBAction) colorBackg_action: (id) sender;
- (IBAction) colorSeparators_action: (id) sender;


@end
