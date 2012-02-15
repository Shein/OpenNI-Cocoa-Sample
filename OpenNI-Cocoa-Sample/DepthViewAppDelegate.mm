//
//  NiGLDepthViewAppDelegate.m
//  NiGLDepthView
//
//  Created by Daniel Shein on 10/7/11.
//  Copyright 2011 LoFT. All rights reserved.
//

#import "DepthViewAppDelegate.hpp"

#define MAX_DEPTH            10000

@implementation DepthViewAppDelegate

@synthesize window, depthView;
@synthesize userCounterLabel, currentHandIdLabel, currentHandPositionLabel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    depthView.viewState = NiViewDepth;
    
    // Get an instance of OpenNI
    openNi = [OpenNI instance];
    
    // Add self as a delegate
    [openNi addDelegate:self];
    
    clickCount = 0;
    userCount = 0;
    
    [userCounterLabel bind:@"stringValue" toObject:self withKeyPath:@"userCount" options:nil];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    // If we were recording - make sure to stop
    [openNi stopRecording];
}

-(void)openNiInitCompleteWithStatus:(NSNumber *)_status andError:(NSError*)_error
{
    // Test if OpenNI inited successfuly
    if ([_status intValue] == XN_STATUS_OK) {
        
        // Tell OpenNi to start detecting gesture type "Click"
        [openNi startDetectingGesture:GestureTypeClick];
    } else {
        // Failed - check status and display appropriate error message
        NSLog(@"Failed initing OpenNI with status: %@", _status);
    }
}


-(void)userDidEnterWithId:(NSNumber*)_nId
{
    // A user did enter the scene
    userCount++;
    
    [userCounterLabel setStringValue:[NSString stringWithFormat:@"%d", userCount]];
}


-(void)userDidLeaveWithId:(NSNumber *)_nId
{
    // A user left the scene
    userCount--;
    
    [userCounterLabel setStringValue:[NSString stringWithFormat:@"%d", userCount]];
}

-(void)handDidBeginAt:(NSDictionary *)_point forUserId:(NSNumber *)_nId
{
    
    // A hand was created at point for a user
    [currentHandIdLabel setStringValue:[NSString stringWithFormat:@"%d", [_nId intValue]]];
    
    // Start tracking the hand from point
    [openNi startTrackingHandAtPosition:[_point objectForKey:@"point"]];
    
    clickCount++;
    NSColor *color;
    
    switch (clickCount % 5) {
        case 0:
            color = [NSColor greenColor];
            break;
        
        case 1:
            color = [NSColor blueColor];
            break;
            
        case 2:
            color = [NSColor yellowColor];
            break;
            
        case 3:
            color = [NSColor redColor];            
            break;
            
        case 4:
            color = [NSColor purpleColor];            
            break;
        default:
            color = [NSColor yellowColor];
            break;
            
    }

    [depthView setColor:color];
}


-(void)handDidMoveAt:(NSDictionary *)_point forUserId:(NSNumber *)_nId
{
    // An existing hand moved
    [currentHandPositionLabel setStringValue:[NSString stringWithFormat:@"%@", [_point objectForKey:@"point"]]];
}


-(void)handDidStopForUserId:(NSNumber *)_nId
{
    // A hand was lost
}

-(void)gestureRecognizedAt:(NSDictionary *)_point withName:(NSString *)_gestureName
{
    // A Gesture was recognized 
}

@end
