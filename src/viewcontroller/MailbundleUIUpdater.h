//
//  MailbundleUIUpdater.h
//  MailPluginManager
//
//  Created by Aaron on 11/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Mailbundle;
// receives notifications of changes in bundles,
// and updates the windows and library appropriately
@interface MailbundleUIUpdater : NSObject {

}
// Notifications
- (void) bundleInstalled:(NSNotification *)notification;
- (void) bundleRemoved:(NSNotification *)notification;
- (void) bundleEnabled:(NSNotification *)notification;
- (void) bundleDisabled:(NSNotification *)notification;
- (void) filesystemChanged:(NSNotification *)notification;

// Alert management
- (void) pluginAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;


@end
