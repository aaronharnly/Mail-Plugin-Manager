//
//  MailPluginManagerController.h
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PluginLibraryController;
@class MailbundleOperationController;
@class MailbundleUIUpdater;
@class FSEventsController;

@interface MailPluginManagerController : NSObject {
	NSMutableDictionary *pluginWindowControllers;
	IBOutlet PluginLibraryController *pluginLibraryController;
	IBOutlet MailbundleOperationController *operationController;
	IBOutlet MailbundleUIUpdater *uiUpdater;
	IBOutlet FSEventsController *fsEventsController;
}
-(IBAction)openDocumentPanel:(id)sender;
-(void)openDocumentPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;
-(void)removeWindowControllerForPath:(NSString *)path;
-(void)movePath:(NSString *)oldPath toPath:(NSString *)newPath;
@property (readonly) MailbundleOperationController *operationController;
@property (readonly) PluginLibraryController *pluginLibraryController;
@property (readonly) NSMutableDictionary *pluginWindowControllers;
@end
