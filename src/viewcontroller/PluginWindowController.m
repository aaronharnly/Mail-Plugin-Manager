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
			NSLocalizedString(@"for this user",@"Plugin status: User domain description") 
			: NSLocalizedString(@"for all users",@"Plugin status: Local domain description");
		NSString *enabledText = (enabled) ? 
			NSLocalizedString(@"and enabled",@"Plugin status: enabled") 
			: NSLocalizedString(@"but disabled",@"Plugin status: disabled");
		statusText = [NSString stringWithFormat:
			NSLocalizedString(@"installed %@ %@.",@"Plugin status: installed")
			, enabledText, domainText];
	} else {
		statusText = NSLocalizedString(@"not currently installed.",@"Plugin status: not installed");
	}
	return [NSString stringWithFormat:NSLocalizedString(@"This copy of %@ is %@",@"Plugin status: main string"),name, statusText];
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
		return [NSString stringWithFormat:
			NSLocalizedString(@"No copies of %@ are enabled.",@"Installation status: none"), [bundle name]];
	} else if (totalEnabledExcludingThis == 0) {
		return [NSString stringWithFormat:
			NSLocalizedString(@"This is the only enabled copy of %@.",@"Installation status: one"), [bundle name]];	
	} else if (totalEnabledExcludingThis == 1) {
		return [NSString stringWithFormat:
			NSLocalizedString(@"Version %@ is currently enabled.",@"Installation status: One other copy is installed."), [[enabledCopies firstObject] version]];
	} else {
		NSMutableArray *enabledVersions = [NSMutableArray arrayWithCapacity:totalEnabledExcludingThis];
		for (Mailbundle *enabledBundle in enabledCopiesExcludingThis) {
			[enabledVersions addObject:[enabledBundle version]];
		}
		NSString *lastVersion = [enabledVersions lastObject];
		NSArray *enabledVersionsExceptLast = [enabledVersions arrayByRemovingLastObject];
		NSString *versionListPrefix = (bundle.enabled) ?
			NSLocalizedString(@"Other than this copy, versions",@"Installation status: Multiple other copies are installed, and so is this.") 
			:NSLocalizedString(@"Versions",@"Installations status: Multiple other copies are installed; this copy is not installed.");
		
		NSString *versionList = [NSString stringWithFormat:
			NSLocalizedString(@"%@ %@ and %@ are enabled.",@"Installation status: Master text for a list of other enabled versions."),
			versionListPrefix,
			[enabledVersionsExceptLast componentsJoinedByString:@", "],
			lastVersion];
		return versionList;
	}
}

- (void)updateWebsiteLink {
	NSString *url = self.plugin.bundleWebsiteURL;
	if (url == nil) {
		[websiteLink setHidden:YES];
	} else {
		[websiteLink setHidden:NO];
		[websiteLink setUrlString:url];
		NSString *title = [NSString stringWithFormat:@"%@ Website", self.plugin.name];
		[websiteLink setTitle:title];
	}
	[websiteLink setNeedsDisplay];
}

/*!
	@method updateDisplay
	@abstract Refresh the view.
	@discussion
	
*/
- (void)updateDisplay {
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
	[self configureButtonsForCurrentInstallationStatus];
	[self updateWebsiteLink];
}

- (void)configureButtonsForCurrentInstallationStatus {
	[installOrRemoveButton setEnabled:YES];

	if (self.plugin.installed) {
		[installOrRemoveButton setTitle:NSLocalizedString(@"Remove",@"Window button label: remove")];				
		[enableOrDisableButton setHidden:NO];
		[enableOrDisableButton setEnabled:YES];
		if (self.plugin.enabled) {
			[enableOrDisableButton setTitle:NSLocalizedString(@"Disable",@"Window button label: disable")];
		} else {
			[enableOrDisableButton setTitle:NSLocalizedString(@"Enable",@"Window button label: enable")];		
		}
	} else {
		[installOrRemoveButton setTitle:NSLocalizedString(@"Install",@"Window button label: install")];
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
