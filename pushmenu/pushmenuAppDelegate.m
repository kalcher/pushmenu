//
//  pushmenuAppDelegate.m
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


#import "pushmenuAppDelegate.h"
#import "EMKeychain/EMKeychainItem.h"
#import "JSONKit/JSONKit.h"
#import "DDHotKey/DDHotKeyCenter.h"

@implementation pushmenuAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib{
    // setup images
	pmImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] 
                                                        pathForResource:@"pushmenu_menu" 
                                                        ofType:@"png"]];
    
	// setup status item 
	pmItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[pmItem setMenu:pmMenu];
	[pmItem setImage:pmImage];
	[pmItem setHighlightMode:YES];
    
    // setup about box
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *creditsString = [[[NSString alloc] initWithContentsOfFile:
                                [bundle pathForResource:@"credits" ofType:@"html"]] autorelease];
    
	NSAttributedString* creditsHTML = [[[NSAttributedString alloc] initWithHTML:
                                        [creditsString dataUsingEncoding:NSUTF8StringEncoding] 
                                        documentAttributes:nil] autorelease];
    // the only way to change the link color
	[credits setLinkTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName,nil]];
    [credits insertText:creditsHTML];
	[credits setEditable:NO];
    
    // to catch changes to the credentials fields,
	// a change will call controlTextDidChange	
	[ProwlApikey setDelegate:self];
    [NotifoUser setDelegate:self];
    [NotifoSecret setDelegate:self];
    [BoxcarUser setDelegate:self];
    [BoxcarPassword setDelegate:self];

    // postponed setup
    [self performSelector: @selector(postponedSetup)
               withObject: nil
               afterDelay: 0.2];
}

- (void) postponedSetup
{
    EMGenericKeychainItem *PKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Prowl" 
                                                                                   withUsername: @"prowlApiKey"]; 
    if (PKeychainItem != nil) {
        [ProwlApikey setStringValue: PKeychainItem.password];
    }

    NSString *NName = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"NotifoUser"];
    EMGenericKeychainItem *NKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Notifo" 
                                                                                   withUsername: NName]; 
    if (NKeychainItem != nil) {
        [NotifoSecret setStringValue: PKeychainItem.password];
    }

    NSString *BName = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"BoxcarUser"];
    EMGenericKeychainItem *BKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Boxcar" 
                                                                                   withUsername: BName]; 
    if (BKeychainItem != nil) {
        [BoxcarPassword setStringValue: BKeychainItem.password];
    }

    if ([[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"systemstartup"] == Nil) {
		[prefWindow makeKeyAndOrderFront:self];
		[aboutWindow makeKeyAndOrderFront:self];
	}
    
    // check whether pushmenu service is installed
    // and set the checkbox appropriately 
    NSFileManager *FM = [NSFileManager defaultManager];
    NSString *pServiceFile = [@"~/Library/Services/SendtoiPhone.workflow" stringByExpandingTildeInPath];
    if ([FM fileExistsAtPath:pServiceFile]){
        [installService setState:NSOnState];
    } else {
        [installService setState:NSOffState];
    }

    // Register the hot key, if active in preferences
    [self hotKey:self];
}

- (void)display3rdPartyLicenses:(id)sender{
	NSString *FilePath = [[NSBundle mainBundle] pathForResource:@"3rd-party-licenses" ofType:@"txt"];
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	[workspace openFile:FilePath];
	
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    id senderInfo = [aNotification object];

    // Prowl
    if(senderInfo == ProwlApikey)
    {
        EMGenericKeychainItem *PKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Prowl" 
                                                                                       withUsername: @"prowlApiKey"]; 
        if (PKeychainItem != nil) {
            [PKeychainItem removeFromKeychain];
        }
        PKeychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"pushmenu_Prowl"   
                                                                   withUsername:@"prowlApiKey"
                                                                       password:[ProwlApikey stringValue]];
        }
    
    // Notifo
    if( senderInfo == NotifoSecret )
    {
        NSString *NName = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"NotifoUser"];
        EMGenericKeychainItem *NKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Notifo" 
                                                                                       withUsername: NName]; 
        if (NKeychainItem != nil) {
            [NKeychainItem removeFromKeychain];
        }
            
        NKeychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"pushmenu_Notifo"   
                                                                   withUsername:[NotifoUser stringValue]
                                                                       password:[NotifoSecret stringValue]];
    }
    if( senderInfo == NotifoUser ){
        NSString *NName = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"NotifoUser"];
        EMGenericKeychainItem *NKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Notifo" 
                                                                                       withUsername: NName];
        if (NKeychainItem != nil) {
            [NKeychainItem removeFromKeychain];
        }
        [NotifoSecret setStringValue:@""];
    }
    
    // Boxcar
    if( senderInfo == BoxcarPassword )
    {
        NSString *BName = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"BoxcarUser"];
        EMGenericKeychainItem *BKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Boxcar" 
                                                                                       withUsername: BName];
        if (BKeychainItem != nil) {
            [BKeychainItem removeFromKeychain];
        }    

        BKeychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"pushmenu_Boxcar"   
                                                                       withUsername:[BoxcarUser stringValue]
                                                                           password:[BoxcarPassword stringValue]];
    }
    if( senderInfo == BoxcarUser ){
        NSString *BName = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"BoxcarUser"];
        EMGenericKeychainItem *BKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Boxcar" 
                                                                                       withUsername: BName];
        if (BKeychainItem != nil) {
            [BKeychainItem removeFromKeychain];
        }
        [BoxcarPassword setStringValue:@""];
    }
}

- (void)handleLoginItem:(id)sender {
    
	/*
     Responsible for creating or destroying a 
     login item for pushmenu
	 */
	
	BOOL startup = [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"systemstartup"] boolValue];
	NSString *programPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef programUrl = (CFURLRef)[NSURL fileURLWithPath:programPath];
    LSSharedFileListItemRef existingLoginItem = NULL;
	
	// get login items for the user (not the global ones)
    LSSharedFileListRef loginItemsList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsList) {
        UInt32 seed = 0;
        NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItemsList, &seed)) autorelease];
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
			
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, NULL);
            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, programUrl);
                CFRelease(URL);
				
                if (foundIt) {
                    existingLoginItem = item;
                    break;
                }
            }
        }
		
        if (startup && (existingLoginItem == NULL)) {
            LSSharedFileListItemRef newLoginItem = LSSharedFileListInsertItemURL(loginItemsList, kLSSharedFileListItemBeforeFirst,NULL, NULL, programUrl, NULL, NULL);
			// we definitely have to release myitem
			if (newLoginItem != NULL)
				CFRelease(newLoginItem);
			
        } else if (!startup && (existingLoginItem != NULL))
            LSSharedFileListItemRemove(loginItemsList, existingLoginItem);
		
        CFRelease(loginItemsList);
    }       
}

//////////////////////////////////////////////////
// Clipboard to Phone 
//////////////////////////////////////////////////
- (void)clipboard2iPhone:(id) sender {
	
	NSString *description;
    
	// get pasteboard contents
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];; 
	NSArray *classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
	NSDictionary *options = [NSDictionary dictionary];
	NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
	[classes release];
    
	description = [copiedItems objectAtIndex:0];

    // check which services are active
    ProwlActive = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
                    valueForKey:@"ProwlActive"]boolValue];
    NotifoActive = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
                    valueForKey:@"NotifoActive"]boolValue];
    BoxcarActive = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
                    valueForKey:@"BoxcarActive"]boolValue];

	if (ProwlActive) {
        [self prowlSendMessage: description];
    }
    if (NotifoActive) {
        [self notifoSendMessage: description];
	}
    if (BoxcarActive) {
        [self boxcarSendMessage: description];
    }
}

//////////////////////////////////////////////////
// Prowl
//////////////////////////////////////////////////
- (void)prowlSendMessage:(NSString *)message {
	
	// shorten the description string
	if ([message length] > 1000) {
		message = [message substringToIndex:1000];
	}
	
    EMGenericKeychainItem *PKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Prowl" 
                                                                                   withUsername: @"prowlApiKey"]; 
    if (PKeychainItem == nil) {
        NSLog(@"Not configured");
    }
    
	// assemble the paramter array ...
	NSMutableArray *params = [ NSMutableArray arrayWithObjects:@"apikey=", PKeychainItem.password,
                              @"&application=prowlMenu",
                              @"&event=Info",
                              @"&description=",[self urlEncodeString:message], 
                              @"&priority=",[[[NSUserDefaultsController sharedUserDefaultsController] values]   valueForKey:@"prowlPriority"], 
                              nil ];
    
    // check whether message starts with http
	// a rather crude check for a valid url
	NSRange foundRange = [[self urlEncodeString:message] rangeOfString:@"http"];
	
	if (foundRange.location == 0) {
		NSURL *url = [NSURL URLWithString:[self urlEncodeString:message]];
		if(url!=nil) {
			[params addObject:@"&url="];
			[params addObject:url];
		}
	}
    
	// ... and convert it into a string
	NSString *post = [params componentsJoinedByString:@"" ];
	
	// NSLog(@"%@",post);
	
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:@"https://api.prowlapp.com/publicapi/add"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
    
	NSHTTPURLResponse *response;
	NSData *answerData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: nil];
	
	ProwlStatusCode=nil;
    
	NSXMLParser *addressParser = [[NSXMLParser alloc] initWithData:answerData];
    [addressParser setDelegate:self];
    [addressParser parse]; 
	[addressParser release];
	
	if ([ProwlStatusCode isEqualToString:@"200"]) {
		/*
		[GrowlApplicationBridge notifyWithTitle:@"prowlmenu Message sent"
									description:(NSString *)message
							   notificationName:@"prowlmenuSent"
									   iconData:[NSData data]
									   priority:0
									   isSticky:NO
								   clickContext:nil];
        */
	} else {
        
		NSString *errormessage = @"Unkown error, most probably a connection problem";
		
		if ([ProwlStatusCode isEqualToString:@"400"]) {
			errormessage = @"Bad request";
		} 
		if ([ProwlStatusCode isEqualToString:@"401"]) {
			errormessage = @"Not authorized, the API key given is not valid";
		} 
		if ([ProwlStatusCode isEqualToString:@"405"]) {
			errormessage = @"Method not allowed, you attempted to use a non-SSL connection to Prowl";
		} 
		if ([ProwlStatusCode isEqualToString:@"406"]) {
			errormessage = @"Not acceptable, your IP address has exceeded the API limit";
		} 
		if ([ProwlStatusCode isEqualToString:@"500"]) {
			errormessage = @"Internal server error, check again later";
		} 		

		/*
		[GrowlApplicationBridge notifyWithTitle:@"prowlmenu Error"
									description:errormessage
							   notificationName:@"prowlmenuError"
									   iconData:[NSData data]
									   priority:0
									   isSticky:NO
								   clickContext:nil];	
        */
		NSLog(@"ERROR: %@", errormessage);
		
		// should we do an alert modal in case there is no Growl on the system?
		/*
         NSAlert *alert = [[[NSAlert alloc] init] autorelease];
         [alert addButtonWithTitle:@"OK"];
         [alert setMessageText:@"prowlmenu problem"];
         [alert setInformativeText:errormessage];
         [alert setAlertStyle:NSWarningAlertStyle];
         [alert runModal];
         */
	}
}

- (NSString *)urlEncodeString:(NSString *)str {
	// method to create url encoded strings 
    
	NSString *enc = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																		 (CFStringRef)str, NULL, CFSTR("?=&+"), 
																		 kCFStringEncodingUTF8);
	return [enc autorelease];
}




- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
    if ([elementName isEqualToString:@"error"]) {
        NSString *code = [attributeDict objectForKey:@"code"];
        if (code){
            NSLog(@"API error code: %@",code);
			ProwlStatusCode=[code copy];
		}
	}
	
	if ([elementName isEqualToString:@"success"]) {
        NSString *code = [attributeDict objectForKey:@"code"];
        if (code){
			ProwlStatusCode=[code copy];
		}
	}
	
}

// Not used
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
}

//////////////////////////////////////////////////
// Notifo
//////////////////////////////////////////////////
- (void)notifoSendMessage:(NSString *)message {

	// shorten the description string
	if ([message length] > 1000) {
		message = [message substringToIndex:1000];
	}
    
    NSString *NName = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"NotifoUser"];
    EMGenericKeychainItem *NKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Notifo" 
                                                                                   withUsername: NName]; 
    
    if (NKeychainItem == nil) {
        NSLog(@"Notifo not configured");
        return;
    }

    NSString *credentials = [NSString stringWithFormat:@"user = %@:%@\n", 
                             NKeychainItem.username, 
                             NKeychainItem.password];
    
    // check whether message starts with http
	// a rather crude check for a valid url
	NSRange foundRange = [[self urlEncodeString:message] rangeOfString:@"http"];
    
    NSString *payload = Nil;
	
	if (foundRange.location == 0) {
		NSURL *url = [NSURL URLWithString:[self urlEncodeString:message]];
		if(url!=nil) {
            payload = [NSString stringWithFormat:@"to=%@&msg=%@%@&uri=%@", 
                                                NKeychainItem.username,
                                                [self urlEncodeString:@"URL-double tap! "],
                                                [self urlEncodeString:message],
                                                url];
		}
	} else {
        payload = [NSString stringWithFormat:@"to=%@&msg=%@", 
                                            NKeychainItem.username, 
                                            [self urlEncodeString:message]];
    }
    // We call curl on the command line to do
    // the heavy lifting for us
    
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/bin/curl"];
    [task setArguments:[NSArray arrayWithObjects:@"-K-", 
                                                 @"-d", payload, 
                                                 @"https://api.notifo.com/v1/send_notification", 
                                                 nil]];
    
    // NSLog(@"%@",[[task arguments]description]);
    
    NSPipe *outpipe = [NSPipe pipe];
    NSPipe *inpipe = [NSPipe pipe];
    NSFileHandle *devnull = [NSFileHandle fileHandleForWritingAtPath:@"/dev/null"];


    [task setStandardOutput:outpipe];
    [task setStandardInput:inpipe];
    [task setStandardError:devnull];
        
    [task launch];
    [[inpipe fileHandleForWriting] writeData: [credentials dataUsingEncoding: NSUTF8StringEncoding]];
    [[inpipe fileHandleForWriting] closeFile];
    
    NSData *data = [[outpipe fileHandleForReading] readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString *answer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *deserializedData = [answer objectFromJSONString];

    // Notifo JSON answer looks like this:
    // {"status":"success","response_code":2201,"response_message":"OK"}
    
    if (![[deserializedData valueForKey:@"status"] isEqualToString:@"success"]) {
        NSLog(@"Error sending message to Notifo.");
    }

    [answer release];
    
}

//////////////////////////////////////////////////
// Boxcar
//////////////////////////////////////////////////
- (void)boxcarSendMessage:(NSString *)message {
    
	// shorten the description string
	if ([message length] > 1000) {
		message = [message substringToIndex:1000];
	}
    
    NSString *BName = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"BoxcarUser"];
    EMGenericKeychainItem *BKeychainItem = [EMGenericKeychainItem genericKeychainItemForService: @"pushmenu_Boxcar" 
                                                                                   withUsername: BName]; 
    
    if (BKeychainItem == nil) {
        NSLog(@"Not configured");
        return;
    }
    
    NSString *credentials = [NSString stringWithFormat:@"user = %@:%@\n", 
                             BKeychainItem.username, 
                             BKeychainItem.password];
    
    NSString *payload = [NSString stringWithFormat:@"notification[from_screen_name]=pushmenu&notification[message]=%@", 
                         [self urlEncodeString:message]];
    
    // We call curl on the command line to do
    // the heavy lifting for us
    
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/bin/curl"];
    [task setArguments:[NSArray arrayWithObjects:@"-K-",
                                @"-d", payload, @"-i",
                                @"https://boxcar.io/notifications", 
                                nil]];
    
    // NSLog(@"%@",[[task arguments]description]);
    
    NSPipe *pipe = [NSPipe pipe];
    NSPipe *inpipe = [NSPipe pipe];
    NSFileHandle *devnull = [NSFileHandle fileHandleForWritingAtPath:@"/dev/null"];

    [task setStandardOutput:pipe];
    [task setStandardInput:inpipe];
    [task setStandardError:devnull];
    
    [task launch];
    [[inpipe fileHandleForWriting] writeData: [credentials dataUsingEncoding: NSUTF8StringEncoding]];
    [[inpipe fileHandleForWriting] closeFile];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];

    [task waitUntilExit];
    [task release];
    
    NSString *answer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    // we're only getting some HTTP headers
    NSArray *lines = [answer componentsSeparatedByString:@"\n"];
    BOOL ok = FALSE;
    for(NSString *line in lines) {
        NSRange range = [line rangeOfString:@"Status: 200"] ;
        if (range.location == 0) {
            ok = TRUE;
        }
    }
    
    if (!ok) {
        NSLog(@"Error sending message to Boxcar.");
    }
    
    [answer release];
    
}

//////////////////////////////////////////////////
//
//  AppleScript Interface
//
//  This is called from apple script with a 
//  message to send.
//
//  Example AppleScript:
//
//    tell application "pushmenu"
//         sendmessage "hello world"
//    end tell
//
//////////////////////////////////////////////////
- (id)performDefaultImplementation {
    
    // check which services are active
    ProwlActive = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
                    valueForKey:@"ProwlActive"]boolValue];
    NotifoActive = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
                     valueForKey:@"NotifoActive"]boolValue];
    BoxcarActive = [[[[NSUserDefaultsController sharedUserDefaultsController] values] 
                     valueForKey:@"BoxcarActive"]boolValue];
    
	if (ProwlActive) {
        [self prowlSendMessage: [self directParameter]];
    }
    if (NotifoActive) {
        [self notifoSendMessage: [self directParameter]];
	}
    if (BoxcarActive) {
        [self boxcarSendMessage: [self directParameter]];
    }

	return nil;
}


//////////////////////////////////////////////////
// Install the services menu entry
//////////////////////////////////////////////////
- (void) installService:(id) sender {

    NSFileManager *FM = [NSFileManager defaultManager];
    NSString *serviceFile = [[NSBundle mainBundle] pathForResource:@"SendtoiPhone" 
                                                            ofType:@"workflow"];
    NSString *destination = [@"~/Library/Services/SendtoiPhone.workflow" stringByExpandingTildeInPath];

    if ([installService state] == NSOnState) {
        if (![FM fileExistsAtPath:destination]) 
        {
            [FM copyItemAtPath:serviceFile toPath:destination error:Nil];
        }
    } else  { // User turned the service off
        if ([FM fileExistsAtPath:destination]) 
        {
            [FM removeItemAtPath:destination error:Nil];
        }
    }
}


//////////////////////////////////////////////////
// Hotkey handling
//
// a static hot key (ctrl-command-p) is registered.
//
//////////////////////////////////////////////////
- (void) hotKey:(id) sender {

    DDHotKeyCenter * hkc = [[DDHotKeyCenter alloc] init];
    
    if ([shortcut state] == NSOnState) {

        if (![hkc registerHotKeyWithKeyCode:35 modifierFlags:NSControlKeyMask|NSCommandKeyMask 
                                 target:self action:@selector(clipboard2iPhone:) object:Nil]) {
            NSLog(@"Could not register hot key.");
        }
    } else {
        [hkc unregisterHotKeyWithKeyCode:35 modifierFlags:NSControlKeyMask|NSCommandKeyMask ];
    }
    
    [hkc release];
}

@end
