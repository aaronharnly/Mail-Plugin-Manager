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

// -------------- Custom methods ---------
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
	[installButton setEnabled:YES];
}


- (void)displaySuccess
{
	
}

- (void)displayFailure
{

}
/*!

*/
- (IBAction) installPlugin:(id)sender 
{
	NSError *installError = nil;
	BOOL success = [MailbundleOperations installMailbundle:self.plugin inDomain:NSUserDomainMask error:&installError];

	// Display an alert appropriate to the result
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	if (success) {
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert setIcon:[NSImage imageNamed:NSImageNameInfo]];
		[alert setMessageText:[NSString stringWithFormat:@"The Mail plugin '%@' was successfully installed.", plugin.name]];
		[alert setInformativeText:@"It will be activated the next time you start Mail."];
	} else {
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setMessageText:[NSString stringWithFormat:@"The Mail plugin '%@' failed to install.", plugin.name]];
		NSString *errorMessage = [[installError userInfo] objectForKey:@"ErrorMessage"];
		if (errorMessage == nil) 
			errorMessage = @"No further information is available.";
		[alert setInformativeText:errorMessage];
	}
	[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(installPluginAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) installPluginAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
	[[alert window] orderOut:self];
}


// ------ accessors ------
-(void)setPlugin:(Mailbundle *)bundle {
	plugin = bundle; 
	[self updateDisplay];
}
@synthesize plugin;
@end
