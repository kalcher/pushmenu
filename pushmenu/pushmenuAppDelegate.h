//
//  pushmenuAppDelegate.h
//  pushmenu
//
//  Created by Sebastian Kalcher on 29.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface pushmenuAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
