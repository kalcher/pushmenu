//
//  pushmenuAppDelegate.h
//  pushmenu
//
//  Created by Sebastian Kalcher on 29.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface pushmenuAppDelegate : NSObject < NSApplicationDelegate,
                                            NSXMLParserDelegate, 
                                            NSTextFieldDelegate> {
    NSWindow                *window;
    NSStatusItem			*pmItem;
    
    NSImage					*pmImage;
	NSImage					*pmActive;
    
    IBOutlet NSMenu			*pmMenu;
    IBOutlet NSTextView		*credits;

    // Prowl
    IBOutlet NSTextField	*ProwlApikey;
    BOOL                    ProwlActive;
    NSString				*ProwlStatusCode;

                                               
    // Notifo
    IBOutlet NSTextField    *NotifoUser; 
    IBOutlet NSTextField    *NotifoSecret; 
    BOOL                    NotifoActive;
                                               
    // Boxcar
    IBOutlet NSTextField    *BoxcarUser; 
    IBOutlet NSTextField    *BoxcarPassword; 
    BOOL                    BoxcarActive;

}

- (IBAction)handleLoginItem:(id)sender;
- (IBAction)clipboard2iPhone:(id)sender;

- (void)prowlSendMessage:(NSString *)message;
- (void)notifoSendMessage:(NSString *)message;
- (void)boxcarSendMessage:(NSString *)message;


- (NSString *)urlEncodeString:(NSString *)str;


@property (assign) IBOutlet NSWindow *window;

@end
