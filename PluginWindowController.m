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
#import "NSArray+CocoaDevUsersAdditions.h"
#import "PluginLibraryController.h"

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

- (NSString *)textDescribingInstalledCopiesOfMailbundle:(Mailbundle *)bundle
{
	NSArray *enabledCopies = [[[NSApp delegate] pluginLibraryController] enabledMailbundlesForIdentifier:bundle.identifier];
	int totalEnabledCopies = [enabledCopies count];
	
	NSMutableArray *enabledCopiesExcludingThis = [NSMutableArray arrayWithCapacity:totalEnabledCopies];
	for (Mailbundle *enabledBundle in enabledCopies) {
		if (! [[enabledBundle path] isEqualToString:[bundle path]]) {
			[enabledCopiesExcludingThis addObject:enabledBundle];
			NSLog(@"My path is %@, and this thing is %@", [bundle path], [enabledBundle path]);
		}
	}
	int totalEnabledExcludingThis = [enabledCopiesExcludingThis count];
	
	if (totalEnabledCopies == 0) {
		return [NSString stringWithFormat:@"No copies of %@ are enabled.", [bundle name]];
	} else if (totalEnabledExcludingThis == 0) {
		return [NSString stringWithFormat:@"This is the only enabled copy of %@.", [bundle name]];	
	} else if (totalEnabledExcludingThis == 1) {
		return [NSString stringWithFormat:@"Version %@ is currently enabled.", [[enabledCopies firstObject] version]];
	} else {
		NSMutableArray *enabledVersions = [NSMutableArray arrayWithCapacity:totalEnabledExcludingThis];
		for (Mailbundle *enabledBundle in enabledCopiesExcludingThis) {
			[enabledVersions addObject:[enabledBundle version]];
		}
		NSString *lastVersion = [enabledVersions lastObject];
		NSArray *enabledVersionsExceptLast = [enabledVersions arrayByRemovingLastObject];
		NSString *versionListPrefix = (bundle.enabled) ?
			@"Other than this copy, versions" :
			@"Versions";
		
		NSString *versionList = [NSString stringWithFormat:@"%@ %@ and %@ are enabled.",
			versionListPrefix,
			[enabledVersionsExceptLast componentsJoinedByString:@", "],
			lastVersion];
		return versionList;
	}
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
	[otherCopiesStatusField setStringValue:[self textDescribingInstalledCopiesOfMailbundle:self.plugin]];
	NSLog(@"Updated with other-copies value: %@", [self textDescribingInstalledCopiesOfMailbundle:self.plugin]);
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
