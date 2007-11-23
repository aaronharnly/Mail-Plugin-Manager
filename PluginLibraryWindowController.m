//
//  PluginLibraryController.m
//  MailPluginManager
//
//  Created by Aaron on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PluginLibraryWindowController.h"
#import "PluginLibraryController.h"
#import "Mailbundle.h"
#import "MailbundleOperations.h"
#import "MailPluginManagerController.h"
#import "MailbundleOperationController.h"
#import "AlertFactory.h"

enum LibraryToolbarItems {
	LibraryToolbarItemEnable = 1,
	LibraryToolbarItemRemove = 2,
	LibraryToolbarItemRefresh = 3,
	LibraryToolbarItemReveal = 4
};



enum LibraryMenuItems {
	LibraryMenuItemEnable = 1,
	LibraryMenuItemRemove = 2,
	LibraryMenuItemRefresh = 3,
	LibraryMenuItemReveal = 4,
	LibraryMenuItemShowWindow = 9
};

@implementation PluginLibraryWindowController
-(void)awakeFromNib
{
	// Set up the tableview doubleclick action
	[tableView setTarget:self];
	[tableView setDoubleAction:@selector(openRow:)];	
}

// -------------------------- Toolbar methods -----------------------
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	NSInteger itemTag = [theItem tag];
	NSArray *selected = [[pluginLibraryController pluginArrayController] selectedObjects];
	BOOL atLeastOneSelected = ([selected count] > 0);
	switch (itemTag) {
		case LibraryToolbarItemEnable:
			return atLeastOneSelected;
			break;
		case LibraryToolbarItemRemove:
			return atLeastOneSelected;
			break;
		case LibraryToolbarItemRefresh:
			return YES;
			break;
		case LibraryToolbarItemReveal:
			return atLeastOneSelected;
			break;
		default:
			return NO;
			break;
	}
}
// -------------------------- Menu methods --------------------------
-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
	NSInteger itemTag = [theMenuItem tag];
	NSArray *selected = [[pluginLibraryController pluginArrayController] selectedObjects];
	BOOL atLeastOneSelected = ([selected count] > 0);
	switch (itemTag) {
		case LibraryMenuItemEnable:
			return atLeastOneSelected;
			break;
		case LibraryMenuItemRemove:
			return atLeastOneSelected;
			break;
		case LibraryMenuItemRefresh:
			return YES;
			break;
		case LibraryMenuItemReveal:
			return atLeastOneSelected;
			break;
		case LibraryMenuItemShowWindow:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

// -------------------------- Tableview methods --------------------------

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
//	NSTableView *tableView = [notification object];
	NSArray *selected = [[pluginLibraryController pluginArrayController] selectedObjects];
	// Decide what text and icon to show for the enable/disable button.
	int enabledCount = 0;
	int selectedCount = [selected count];
	for (Mailbundle *bundle in selected) {
		if ([bundle respondsToSelector:@selector(enabled)])
			if (bundle.enabled)
				enabledCount++;
	}
	
	if (selectedCount == 0) {
		[enableDisableItem setLabel:NSLocalizedString(@"Disable",@"Toolbar button label: disable")];
		[enableDisableItem setImage:[NSImage imageNamed:@"Pause"]];
	} else {
		if (enabledCount == 0) {
			[enableDisableItem setLabel:NSLocalizedString(@"Enable",@"Toolbar button label: enable")];
			[enableDisableItem setImage:[NSImage imageNamed:@"Play"]];
		} else if (enabledCount == selectedCount) {
			[enableDisableItem setLabel:NSLocalizedString(@"Disable",@"Toolbar button label: disable")];
			[enableDisableItem setImage:[NSImage imageNamed:@"Pause"]];
		} else {
			[enableDisableItem setLabel:NSLocalizedString(@"Enable / Disable",@"Toolbar button label: mixed enable/disable")];
			[enableDisableItem setImage:[NSImage imageNamed:@"PausePlay"]];
		}	
	}
}

// -------------------------- Actions --------------------------
-(IBAction) refreshListing:(id)sender
{
	[pluginLibraryController refresh:self];
}

-(IBAction) openRow:(id) sender
{
	int clickedRow = [sender clickedRow];
	if (clickedRow >= 0) {
		Mailbundle *bundle = [[[pluginLibraryController pluginArrayController] arrangedObjects] objectAtIndex:clickedRow];
		[[NSApp delegate] application:NSApp openFile:bundle.path];
	}
}

-(IBAction) enableOrDisableSelection:(id)sender
{
	NSArray *selected = [[pluginLibraryController pluginArrayController] selectedObjects];
	for (Mailbundle *bundle in selected) {
		[[[NSApp delegate] operationController] enableOrDisableMailbundle:bundle window:[self window]];
	}
}
-(IBAction) enableOrDisableRow:(id) sender
{
	int clickedRow = [sender clickedRow];
	if (clickedRow >= 0) {
		Mailbundle *bundle = [[[pluginLibraryController pluginArrayController] arrangedObjects] objectAtIndex:clickedRow];
		// First we have to toggle the enabled status, since the click will already have toggled it
		bundle.enabled = !bundle.enabled;
		[[[NSApp delegate] operationController] enableOrDisableMailbundle:bundle window:[self window]];
	}
}
-(IBAction) revealSelectionInFinder:(id)sender
{
	NSArray *selection = [[pluginLibraryController pluginArrayController] selectedObjects];
	for (Mailbundle *bundle in selection) {
		[[NSWorkspace sharedWorkspace] selectFile:bundle.path inFileViewerRootedAtPath:[bundle.path stringByDeletingLastPathComponent]];
	}
}
-(IBAction) removeSelection:(id)sender
{
	NSArray *selection = [[pluginLibraryController pluginArrayController] selectedObjects];
	for (Mailbundle *bundle in selection) {
		[[[NSApp delegate] operationController] removeMailbundle:bundle window:[self window]];
	}
}
@synthesize pluginLibraryController;
@end
