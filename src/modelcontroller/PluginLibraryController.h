//
//  PluginLibraryController.h
//  MailPluginManager
//
//  Created by Aaron on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
	@class PluginLibraryController
	@abstract Model controller for the list of installed plugins
	@discussion
*/
@interface PluginLibraryController : NSObject {
	IBOutlet NSArrayController *pluginArrayController;
	NSMutableSet *plugins;
}
@property (copy) NSMutableSet *plugins;
@property (readonly) NSArrayController *pluginArrayController;
+(NSArray *) getInstalledMailbundles; 
-(IBAction) loadFromDisk:(id)sender;
-(IBAction) refresh:(id)sender;
-(void) refreshMovingPath:(NSString *)oldPath toPath:(NSString *)newPath;

-(NSArray *) installedMailbundles;
-(NSArray *) installedMailbundlesForIdentifier:(NSString *)identifier;
-(NSArray *) enabledMailbundlesForIdentifier:(NSString *)identifier;
@end
