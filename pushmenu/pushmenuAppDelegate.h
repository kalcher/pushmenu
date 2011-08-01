//
//  pushmenuAppDelegate.h
//  pushmenu
//
// Copyright (c) 2011, Sebastian Kalcher. 
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
// * Neither the name of Sebastian Kalcher nor the names of the contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL SEBASTIAN KALCHER BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Cocoa/Cocoa.h>

@interface pushmenuAppDelegate : NSScriptCommand <  NSApplicationDelegate,
                                                    NSXMLParserDelegate, 
                                                    NSTextFieldDelegate> {
    NSWindow                *window;
    NSStatusItem			*pmItem;
    
    NSImage					*pmImage;
	NSImage					*pmActive;
    
    IBOutlet NSMenu			*pmMenu;
    IBOutlet NSTextView		*credits;
    IBOutlet NSWindow		*prefWindow;
    IBOutlet NSWindow		*aboutWindow;
    IBOutlet NSButtonCell   *installService;

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
- (IBAction)display3rdPartyLicenses:(id)sender;
- (IBAction)installService:(id)sender;


- (void)prowlSendMessage:(NSString *)message;
- (void)notifoSendMessage:(NSString *)message;
- (void)boxcarSendMessage:(NSString *)message;

// Applescript
- (id)performDefaultImplementation;


- (NSString *)urlEncodeString:(NSString *)str;


@property (assign) IBOutlet NSWindow *window;

@end
