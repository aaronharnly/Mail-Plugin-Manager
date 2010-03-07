//
//  PluginLibraryController.h
//  MailPluginManager
//
//  Created by Aaron on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PluginLibraryController;

@interface PluginLibraryWindowController : NSWindowController {
	IBOutlet PluginLibraryController *pluginLibraryController;
	IBOutlet NSToolbarItem *enableDisableItem;
	IBOutlet NSTableView *tableView;
}
-(IBAction) openRow:(id) sender;
-(IBAction) openSelection:(id) sender;
-(IBAction) refreshListing:(id) sender;
-(IBAction) enableOrDisableSelection:(id) sender;
-(IBAction) enableOrDisableRow:(id) sender;
-(IBAction) revealSelectionInFinder:(id) sender;
-(IBAction) removeSelection:(id) sender;

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
@property (readonly) PluginLibraryController *pluginLibraryController;
@end
