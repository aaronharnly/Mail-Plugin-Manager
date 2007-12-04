//
//  MailAppOperations.m
//  MailPluginManager
//
//  Created by Aaron on 12/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MailAppOperations.h"
#import "Constants.h"
#import "Mail.h"

@implementation MailAppOperations
+(BOOL)mailIsRunning 
{
	BOOL mailIsRunning = NO;
	NSArray *launchedApps = [[NSWorkspace sharedWorkspace] launchedApplications];
	for (NSDictionary *app in launchedApps) {
		if ([[app objectForKey:@"NSApplicationBundleIdentifier"] isEqualToString:MailIdentifier])
			mailIsRunning = YES;
	}
	return mailIsRunning;
}

+(BOOL)relaunchMail
{
    // Quit Mail using the Scripting Bridge
	MailApplication *mailApp = [SBApplication applicationWithBundleIdentifier:MailIdentifier];
	if ([mailApp isRunning]) {
		NSLog(@"Quitting Mail...");
		[mailApp quitSaving:MailSavoYes];
		NSLog(@"done.");
		
		// we have to get a new handle on Mail after quitting
		mailApp = [SBApplication applicationWithBundleIdentifier:MailIdentifier];
		[mailApp activate];
	}
	return YES;
}
@end
