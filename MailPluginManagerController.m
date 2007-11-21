//
//  MailPluginManagerController.m
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MailPluginManagerController.h"
#import "PluginWindowController.h"
#import "PluginLibraryController.h"
#import "FSEventsController.h"
#import "Mailbundle.h"

@implementation MailPluginManagerController
// --------------------- Initialization methods -------------------------

-(id) init {
	self = [super init];
	if (self != nil) {
		pluginWindowControllers = [NSMutableDictionary dictionaryWithCapacity:4];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[fsEventsController registerForFSEvents];
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

-(IBAction)refreshLibrary:(id)sender
{
	[pluginLibraryController refresh:sender];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// we've been alerted that a bundle's path has changed
	[self movePath:[change objectForKey:NSKeyValueChangeOldKey] toPath:[change objectForKey:NSKeyValueChangeNewKey]];
}

-(void)removeWindowControllerForPath:(NSString *)path
{
	[pluginWindowControllers removeObjectForKey:path];
}

-(void)movePath:(NSString *)oldPath toPath:(NSString *)newPath
{
	PluginWindowController *windowController = [pluginWindowControllers objectForKey:oldPath];
	if (windowController != nil) {
		[pluginWindowControllers removeObjectForKey:oldPath];
		[[windowController plugin] setPath:newPath];
		[pluginWindowControllers setValue:windowController forKey:newPath];	
	}
}

@synthesize operationController;
@synthesize pluginLibraryController;
@synthesize pluginWindowControllers;

// --------------------- NSApplication delegate methods -------------------------
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	// If we already have a window open for this, just activate that window
	PluginWindowController *existingController = [pluginWindowControllers objectForKey:filename];
	if (existingController != nil) {
		[[existingController window] makeKeyAndOrderFront:self];
		return YES;
	} else {
		Mailbundle *bundle = [[Mailbundle alloc] initWithPath:filename];
		if (bundle == nil)
			return NO;
		PluginWindowController *windowController = [[PluginWindowController alloc] initWithMailbundle:bundle];
		[windowController showWindow:self];
		[windowController updateDisplay];
		
		// Make sure we get alerted if the path for this bundle changes, so we can update our dictionary
		[bundle addObserver:self forKeyPath:@"path" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
		[pluginWindowControllers setValue:windowController forKey:filename];
		return YES;
	}
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	for(NSString *filename in filenames) {
		[self application:sender openFile:filename];
	}
}

@end
