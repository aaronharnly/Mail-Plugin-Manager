//
//  MailPluginManagerController.m
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MailPluginManagerController.h"
#import "PluginWindowController.h"
#import "Mailbundle.h"

@implementation MailPluginManagerController
// --------------------- Initialization methods -------------------------

-(id) init {
	self = [super init];
	if (self != nil) {
		pluginWindowControllers = [NSMutableArray arrayWithCapacity:4];
	}
	return self;
}

// --------------------- Custom methods -------------------------
- (IBAction)openDocumentPanel:(id)sender
{	
	// Get the Downloads directory (I guess?)
	NSArray *downloadPaths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
	if (downloadPaths.count > 0) {
		NSOpenPanel *openPanel = [NSOpenPanel openPanel];
		NSArray *fileTypes = [NSArray arrayWithObject:@"mailbundle"];
		NSString *downloadDirectory = [downloadPaths objectAtIndex:0];
		[openPanel setAllowsMultipleSelection:YES];
		[openPanel beginForDirectory:downloadDirectory file:nil types:fileTypes modelessDelegate:self didEndSelector:@selector(openDocumentPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
	} 
}

- (void)openDocumentPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton) {
		NSArray *filenames = [panel filenames];
		for (NSString *filename in filenames) {
			[self application:[NSApplication sharedApplication] openFile:filename];
		}
	}
}

-(IBAction)installFrontmostPluginWindow:(id)sender
{
	
}


// --------------------- NSApplication delegate methods -------------------------
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	Mailbundle *bundle = [[Mailbundle alloc] initWithPath:filename];
	PluginWindowController *windowController = [[PluginWindowController alloc] initWithMailbundle:bundle];
	NSLog(@"Have window controller: %@",windowController);
	[windowController showWindow:self];
	[windowController updateDisplay];

	[pluginWindowControllers addObject:windowController];
	return YES;
}

@end
