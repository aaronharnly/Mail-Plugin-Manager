//
//  Constants.h
//  MailPluginManager
//
//  Created by Aaron on 11/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// paths
extern NSString *BundleSubdirectory;
extern NSString *DisabledBundleSubdirectory;

// identifiers & stuff
extern NSString *MailIdentifier;
extern NSString *MailbundleExtension;

// dictionary keys
extern NSString *ErrorMessageKey;
extern NSString *MailbundlesEnabledKey;
extern NSString *MailbundleVersionKey;

// notifications
extern NSString *MailbundleDisabledNotification;
extern NSString *MailbundleEnabledNotification;
extern NSString *MailbundleRemovedNotification;
extern NSString *MailbundleInstalledNotification;
extern NSString *MailbundleFilesystemChangedNotification;

extern NSString *MailbundleOperationWindowKey;
extern NSString *MailbundleOperationOriginPathKey;
extern NSString *MailbundleOperationDestinationPathKey;
extern NSString *MailbundleOperationSuccessKey;
extern NSString *MailbundleOperationErrorKey;
