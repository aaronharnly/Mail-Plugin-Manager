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
#import "MailbundleOperationController.h"
#import "MailPluginManagerController.h"
#import "AlertFactory.h"

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

// ------------ NSWindow delegate methods ---------
- (void)windowWillClose:(NSNotification *)notification
{
	NSWindow *closingWindow = [notification object];
	if (closingWindow == [self window]) {
		// Tell the app delegate to stop tracking us
		[[NSApp delegate] removeWindowControllerForPath:self.plugin.path];
	}
}

// ------------ manage view ------------
- (NSString *)textForName:(NSString *) name installed:(BOOL)installed enabled:(BOOL)enabled domain:(NSSearchPathDomainMask)domain {
	NSString *statusText;
	if (installed) {
		NSString *domainText = (domain == NSUserDomainMask) ?
			@"for this user" : @"for all users";
		NSString *enabledText = (enabled) ? 
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
	// most of these we take care of with bindings
	//	nameField <-> plugin.name
	//	versionField <-> plugin.version
	//	descriptionField <-> plugin.description
	//	pathBar <-> plugin.path
	//	self.window.title <-> plugin.name
	//	self.window.representedFilename <-> plugin.path
	[iconView setImage:plugin.icon];
	[installationStatusField setStringValue:[self textForName:self.plugin.name installed:self.plugin.installed enabled:self.plugin.enabled domain:self.plugin.domain]];
	[otherCopiesStatusField setStringValue:@"Are there other copies installed? I dunno."];
	[self configureButtonsForCurrentInstallationStatus];
}

- (void)configureButtonsForCurrentInstallationStatus {
	[installOrRemoveButton setEnabled:YES];

	if (self.plugin.installed) {
		[installOrRemoveButton setTitle:@"Remove"];				
		[enableOrDisableButton setHidden:NO];
		[enableOrDisableButton setEnabled:YES];
		if (self.plugin.enabled) {
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

// ------------ install, remove ------------
- (IBAction) installOrRemovePlugin:(id)sender
{
	if (self.plugin.installed)
		[self removePlugin:sender];
	else
		[self installPlugin:sender];
}

/*!

*/
- (IBAction) installPlugin:(id)sender 
{
	[[[NSApp delegate] operationController] installMailbundle:self.plugin inDomain:NSUserDomainMask window:[self window]];
}

/*!

*/
- (IBAction) removePlugin:(id)sender 
{
	[[[NSApp delegate] operationController] removeMailbundle:self.plugin window:[self window]];
}

// -------------- enable, disable -----------------
- (IBAction) enableOrDisablePlugin:(id)sender
{
	[[[NSApp delegate] operationController] enableOrDisableMailbundle:self.plugin window:[self window]];
}
- (IBAction) enablePlugin:(id)sender
{
	[[[NSApp delegate] operationController] enableMailbundle:self.plugin window:[self window]];
}
- (IBAction) disablePlugin:(id)sender
{
	[[[NSApp delegate] operationController] disableMailbundle:self.plugin window:[self window]];
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
