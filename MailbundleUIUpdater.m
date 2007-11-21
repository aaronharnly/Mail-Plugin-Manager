//
//  MailbundleUIUpdater.m
//  MailPluginManager
//
//  Created by Aaron on 11/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MailbundleUIUpdater.h"
#import "AlertFactory.h"
#import "MailPluginManagerController.h"
#import "PluginWindowController.h"
#import "PluginLibraryController.h"
#import "Constants.h"
#import "Mailbundle.h"

@implementation MailbundleUIUpdater
- (void)awakeFromNib
{
	// register for notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleInstalled:) name:MailbundleInstalledNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleRemoved:) name:MailbundleRemovedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleEnabled:) name:MailbundleEnabledNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleDisabled:) name:MailbundleDisabledNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filesystemChanged:) name:MailbundleFilesystemChangedNotification object:nil];
}

// Alert management
- (void) displayAlertForMailbundle:(Mailbundle *)bundle window:(NSWindow *)window success:(BOOL)success error:(NSError *)error successMessage:(NSString *)successMessage successInfo:(NSString *)successInfo failureMessage:(NSString *)failureMessage
{
	// Display an alert appropriate to the result
	NSAlert *alert = [AlertFactory alertForPlugin:bundle success:success error:error successMessage:successMessage successInfo:successInfo failureMessage:failureMessage];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(pluginAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) displayAlertForNotification:(NSNotification *)notification
{
	NSString *successMessage = NSLocalizedString(@"Succeeded.",@"Generic success message.");
	NSString *successInfo = @"";
	NSString *failureMessage = NSLocalizedString(@"Failed.",@"Generic failure message.");
	
	Mailbundle *bundle = [notification object];
	NSString *operation = [notification name];
	NSWindow *window = [[notification userInfo] objectForKey:MailbundleOperationWindowKey];
	BOOL success = [[[notification userInfo] objectForKey:MailbundleOperationSuccessKey] boolValue];
	NSError *error = [[notification userInfo] objectForKey:MailbundleOperationErrorKey];

	if ([operation isEqualToString:MailbundleInstalledNotification]) {
		successMessage = [NSString stringWithFormat:
			NSLocalizedString(@"Successfully installed %@",@"Installation message: success"), [bundle name]];
		successInfo = NSLocalizedString(@"It will be available when you next launch Mail.",@"Installation message: success info");
		failureMessage = [NSString stringWithFormat:
			NSLocalizedString(@"Failed to install %@",@"Installation message: failure"), [bundle name]];
	} else if ([operation isEqualToString:MailbundleRemovedNotification]) {
		successMessage = [NSString stringWithFormat:
			NSLocalizedString(@"Successfully removed %@",@"Removal message: success"), [bundle name]];
		successInfo = NSLocalizedString(@"It will be absent when you next launch Mail. You can retrieve it from the Trash if you change your mind.",@"Removal message: success info");
		failureMessage = [NSString stringWithFormat:
			NSLocalizedString(@"Failed to remove %@",@"Removal message: failure"), [bundle name]];	
	} else if ([operation isEqualToString:MailbundleEnabledNotification]) {
		successMessage = [NSString stringWithFormat:
			NSLocalizedString(@"Successfully enabled %@",@"Enable message: success (not used)"), [bundle name]];
		successInfo = NSLocalizedString(@"It will be available when you next launch Mail.",@"Enable message: success info (not used)");
		failureMessage = [NSString stringWithFormat:
			NSLocalizedString(@"Failed to enable %@",@"Enable message: failure (not used)"), [bundle name]];	
	} else if ([operation isEqualToString:MailbundleDisabledNotification]) {
		successMessage = [NSString stringWithFormat:
			NSLocalizedString(@"Successfully disabled %@",@"Disable message: success (not used)"), [bundle name]];
		successInfo = NSLocalizedString(@"It will be absent when you next launch Mail.",@"Disable message: success info (not used)");
		failureMessage = [NSString stringWithFormat:
			NSLocalizedString(@"Failed to disable %@",@"Disable message: failure (not used)"), [bundle name]];	
	}

	[self displayAlertForMailbundle:bundle window:window success:success error:error successMessage:successMessage successInfo:successInfo failureMessage:failureMessage];
	
}

- (void) pluginAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
	[[alert window] orderOut:self];
}

// Notifications
- (void)handleOperationNotification:(NSNotification *)notification
{
	NSString *operation = [notification name];
	NSString *oldPath = [[notification userInfo] objectForKey:MailbundleOperationOriginPathKey];
	NSString *newPath = [[notification userInfo] objectForKey:MailbundleOperationDestinationPathKey];

	// If there was a problem, put an error up on the sending window
	BOOL success = [[[notification userInfo] objectForKey:MailbundleOperationSuccessKey] boolValue];
	// We also show messages for successful installations and removals
	if ( (! success)
	|| ([operation isEqualToString:MailbundleInstalledNotification])
	|| ([operation isEqualToString:MailbundleRemovedNotification]))
		[self displayAlertForNotification:notification];

	// Update the library window
	[[[NSApp delegate] pluginLibraryController] refreshMovingPath:oldPath toPath:newPath];
	
	// Update any open plugin windows
	[[NSApp delegate] movePath:oldPath toPath:newPath];

	// Update the display of open windows
	for (PluginWindowController *controller in [[NSApp delegate] pluginWindowControllers]) {
		[controller updateDisplay];
	}
	
}

- (void) bundleInstalled:(NSNotification *)notification
{
	[self handleOperationNotification:notification];
}
- (void) bundleRemoved:(NSNotification *)notification
{
	[self handleOperationNotification:notification];
}
- (void) bundleEnabled:(NSNotification *)notification
{
	[self handleOperationNotification:notification];
}
- (void) bundleDisabled:(NSNotification *)notification
{
	[self handleOperationNotification:notification];
}

- (void) filesystemChanged:(NSNotification *)notification
{
	// update the library window
	[[[NSApp delegate] pluginLibraryController] refreshMovingPath:nil toPath:nil];

	// Also check the open windows; if any of them refer to mailbundles that can't be found, be unhappy.
	for (NSString *path in [[NSApp delegate] pluginWindowControllers]) {
		PluginWindowController *controller = [[[NSApp delegate] pluginWindowControllers] objectForKey:path];
		[controller updateDisplay];
		if (! [Mailbundle mailbundleExistsAtPath:path]) {
			Mailbundle *bundle = [controller plugin];
			NSString *lostMessage = [NSString stringWithFormat:
				NSLocalizedString(@"%@ has been moved from its previous location by another application.",@"Alert when a mailbundle has been moved by another application."), [bundle name]];
			[self displayAlertForMailbundle:bundle window:[controller window] success:NO error:nil successMessage:@"" successInfo:@"" failureMessage:lostMessage];
		} 
	}

}

@end
