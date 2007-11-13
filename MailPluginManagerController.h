//
//  MailPluginManagerController.h
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MailPluginManagerController : NSObject {
	NSMutableArray *pluginWindowControllers;
}
-(IBAction)openDocumentPanel:(id)sender;
-(void)openDocumentPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

-(IBAction)installFrontmostPluginWindow:(id)sender;

@end
