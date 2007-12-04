//
//  AlertController.m
//  MailPluginManager
//
//  Created by Aaron on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AlertFactory.h"
#import "Mailbundle.h"
#import "Constants.h"
#import "MailAppOperations.h"

@implementation AlertFactory
+ (NSAlert *) alertForPlugin:(Mailbundle *)plugin success:(BOOL)success error:(NSError *)error successMessage:(NSString *)successMessage successInfo:(NSString *)successInfo failureMessage:(NSString *)failureMessage
{
	BOOL mailIsRunning = [MailAppOperations mailIsRunning];	
	return [AlertFactory alertForPlugin:plugin success:success error:error successMessage:successMessage successInfo:successInfo failureMessage:failureMessage restartMailOption:mailIsRunning];
}
+ (NSAlert *) alertForPlugin:(Mailbundle *)plugin success:(BOOL)success error:(NSError *)error successMessage:(NSString *)successMessage successInfo:(NSString *)successInfo failureMessage:(NSString *)failureMessage restartMailOption:(BOOL)restartMailOption
{
	NSAlert *alert = [[NSAlert alloc] init];
	if (success) {
		if (restartMailOption) {
			[alert addButtonWithTitle:NSLocalizedString(@"Relaunch Mail for me",@"Relaunch button")];
			[alert addButtonWithTitle:NSLocalizedString(@"I'll relaunch Mail later",@"Latter button")];
		} else {
			[alert addButtonWithTitle:NSLocalizedString(@"OK", @"Okay button")];
		}
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert setIcon:[NSImage imageNamed:NSImageNameInfo]];
		[alert setMessageText:[NSString stringWithFormat:successMessage, plugin.name]];
		[alert setInformativeText:successInfo];
	} else {
		[alert addButtonWithTitle:NSLocalizedString(@"OK", @"Okay button")];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setMessageText:[NSString stringWithFormat:failureMessage, plugin.name]];
		NSString *errorMessage = [[error userInfo] objectForKey:@"ErrorMessage"];
		if (errorMessage == nil) 
			errorMessage = NSLocalizedString(@"No further information is available.",@"Default error explanation.");
		[alert setInformativeText:errorMessage];
	}
	return alert;
}

@end
