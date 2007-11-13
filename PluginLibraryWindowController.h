//
//  PluginLibraryController.h
//  MailPluginManager
//
//  Created by Aaron on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PluginLibraryWindowController : NSWindowController {
	IBOutlet NSToolbarItem *enableDisableItem;
}
-(IBAction) refreshListing;
-(IBAction) enableOrDisableSelection;
-(IBAction) revealSelectionInFinder;
-(IBAction) removeSelection;

@end
