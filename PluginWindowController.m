//
//  PluginWindowController.m
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PluginWindowController.h"
#import "Mailbundle.h"
#import "TransparentImageView.h"
#import "MailbundleOperations.h"
#import "InstallationStatus.h"

@implementation PluginWindowController
// ------------ NSWindowController methods ---------
- (id)initWithMailbundle:(Mailbundle *)bundle {
	self = [super initWithWindowNibName:@"PluginWindow"];
	if (self != nil) {
		self.plugin = bundle;
		[self setWindowFrameAutosaveName:plugin.path];
	}
	return self;
}
- (void)windowDidLoad {
	[super windowDidLoad];
	[self updateDisplay];
}

// ------------ manage view ------------
- (NSString *)textForName:(NSString *) name installationStatus:(struct InstallationStatus)status {
	NSString *statusText;
	if (status.installed) {
		NSString *domainText = (status.domain == NSUserDomainMask) ?
			@"for this user" : @"for all users";
		NSString *enabledText = (status.enabled) ? 
			@" and enabled" : @" but disabled";
		statusText = [NSString stringWithFormat:@"installed%@ %@.", enabledText, domainText];
	} else {
		statusText = @"not currently installed.";
	}
	return [NSString stringWithFormat:@"This copy of %@ is %@",name, statusText];
}

/*!
	@method updateDisplay
	@abstract Refresh the view.
	@discussion
	
*/
- (void)updateDisplay
{
	[self.window setTitle:plugin.name];
	[self.window setRepresentedURL:[NSURL fileURLWithPath:plugin.path]];
	[iconView setImage:plugin.icon];
	[nameField setStringValue:plugin.name];
	[versionField setStringValue:[NSString stringWithFormat:@"Version %@",plugin.version]];	
	[descriptionField setStringValue:@"No description available."];
	[pathBar setStringValue:plugin.path];
	[installationStatusField setStringValue:[self textForName:self.plugin.name installationStatus:self.plugin.installationStatus]];
	[otherCopiesStatusField setStringValue:@"Are there other copies installed? I dunno."];
	[self configureButtonsForCurrentInstallationStatus];
}

- (void)configureButtonsForCurrentInstallationStatus {
	[installOrRemoveButton setEnabled:YES];

	if (self.plugin.installationStatus.installed) {
		[installOrRemoveButton setTitle:@"Remove"];				
		[enableOrDisableButton setHidden:NO];
		[enableOrDisableButton setEnabled:YES];
		if (self.plugin.installationStatus.enabled) {
			[enableOrDisableButton setTitle:@"Disable"];
		} else {
			[enableOrDisableButton setTitle:@"Enable"];		
		}
	} else {
		[installOrRemoveButton setTitle:@"Install"];
		[enableOrDisableButton setHidden:YES];
	}
	[installOrRemoveButton setNeedsDisplay];
	[enableOrDisableButton setNeedsDisplay];
}

// ------------ manage alerts ------------
- (void) displayAlertForSuccess:(BOOL)success error:(NSError *)error successMessage:(NSString *)successMessage successInfo:(NSString *)successInfo failureMessage:(NSString *)failureMessage pathToOpen:(NSString *)path
{
	// Display an alert appropriate to the result
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
	[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(pluginAlertDidEnd:returnCode:contextInfo:) contextInfo:path];
}

- (void) pluginAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
	[self updateDisplay];
	[[alert window] orderOut:self];
	if (contextInfo != nil) { // we gave a path to open when we're done.
		[[NSApp delegate] application:NSApp openFile:contextInfo];
	}
}



// ------------ install, remove ------------
- (IBAction) installOrRemovePlugin:(id)sender
{
	if (self.plugin.installationStatus.installed)
		[self removePlugin:sender];
	else
		[self installPlugin:sender];
}

/*!

*/
- (IBAction) installPlugin:(id)sender 
{
	NSError *error = nil;
	NSString *destination = nil;
	BOOL success = [MailbundleOperations installMailbundle:self.plugin inDomain:NSUserDomainMask destination:&destination error:&error];
	[self displayAlertForSuccess:success 
		error:error 
		successMessage:@"Successfully installed the plugin '%@'." 
		successInfo:@"It will be available the next time you start Mail. I'll now open the installed plugin."
		failureMessage:@"Failed to install the plugin '%@'."
		pathToOpen:destination];
}

/*!

*/
- (IBAction) removePlugin:(id)sender 
{
	NSError *error = nil;
	NSString *destination = nil;
	BOOL success = [MailbundleOperations removeMailbundle:self.plugin destination:&destination error:&error];
	[self displayAlertForSuccess:success 
		error:error 
		successMessage:@"Sucessfully removed the plugin '%@'." 
		successInfo:@"It will be absent the next time you start Mail." 
		failureMessage:@"Failed to remove the plugin '%@'."
		pathToOpen:nil];
	if (success) {
		self.plugin.path = destination;
	}
}

// -------------- enable, disable -----------------
- (IBAction) enableOrDisablePlugin:(id)sender
{
	if (self.plugin.installationStatus.installed) {
		if (self.plugin.installationStatus.enabled)
			[self disablePlugin:sender];
		else
			[self enablePlugin:sender];
	}
}
- (IBAction) enablePlugin:(id)sender
{
	NSError *error = nil;
	BOOL success = [MailbundleOperations enableMailbundle:self.plugin error:&error];
	[self displayAlertForSuccess:success 
		error:error
		successMessage:@"Successfully enabled the plugin '%@'." 
		successInfo:@"It will be available the next time you start Mail." 
		failureMessage:@"Failed to enable the plugin '%@'."
		pathToOpen:nil];
}
- (IBAction) disablePlugin:(id)sender
{
	NSError *error = nil;
	BOOL success = [MailbundleOperations disableMailbundle:self.plugin error:&error];
	[self displayAlertForSuccess:success 
		error:error
		successMessage:@"Successfully disabled the plugin '%@'." 
		successInfo:@"It will be absent the next time you start Mail." 
		failureMessage:@"Failed to disable the plugin '%@'."
		pathToOpen:nil];
}


// ------ accessors ------
-(void)setPlugin:(Mailbundle *)bundle {
	plugin = bundle; 
	[plugin addObserver:self forKeyPath:@"path" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	[self updateDisplay];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == plugin && [keyPath isEqualToString:@"path"]) {
		[self updateDisplay];
	}
}

@synthesize plugin;
@end
