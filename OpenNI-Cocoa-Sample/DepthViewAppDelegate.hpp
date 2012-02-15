//
//  NiGLDepthViewAppDelegate.h
//  NiGLDepthView
//
//  Created by Daniel Shein on 10/7/11.
//  Copyright 2011 LoFT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenNI/OpenNI.h>

#import "NiDepthView.hpp"

@interface DepthViewAppDelegate : NSObject <NSApplicationDelegate, OpenNIDelegate> {
    NSWindow *window;
    NiDepthView *depthView;
    
    OpenNI *openNi;
    
    int clickCount, userCount;
    
    NSTextField *userCounterLabel, *currentHandIdLabel, *currentHandPositionLabel;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NiDepthView *depthView;

@property (assign) IBOutlet NSTextField *userCounterLabel, *currentHandIdLabel, *currentHandPositionLabel;

@end
