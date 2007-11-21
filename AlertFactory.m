//
//  AlertController.m
//  MailPluginManager
//
//  Created by Aaron on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AlertFactory.h"
#import "Mailbundle.h"

@implementation AlertFactory
+ (NSAlert *) alertForPlugin:(Mailbundle *)plugin success:(BOOL)success error:(NSError *)error successMessage:(NSString *)successMessage successInfo:(NSString *)successInfo failureMessage:(NSString *)failureMessage
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	if (success) {
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert setIcon:[NSImage imageNamed:NSImageNameInfo]];
		[alert setMessageText:[NSString stringWithFormat:successMessage, plugin.name]];
		[alert setInformativeText:successInfo];
	} else {
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setMessageText:[NSString stringWithFormat:failureMessage, plugin.name]];
		NSString *errorMessage = [[error userInfo] objectForKey:@"ErrorMessage"];
		if (errorMessage == nil) 
			errorMessage = @"No further information is available.";
		[alert setInformativeText:errorMessage];
	}
	return alert;
}
@end
