//
//  Constants.m
//  MailPluginManager
//
//  Created by Aaron on 11/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

// paths
NSString *BundleSubdirectory = @"Mail/Bundles";
NSString *DisabledBundleSubdirectory = @"Mail/Bundles (Disabled)";

// bundle identifiers
NSString *MailIdentifier = @"com.apple.mail";
NSString *MailbundleExtension = @"mailbundle";

// dictionary keys
NSString *ErrorMessageKey = @"ErrorMessage";
NSString *MailbundlesEnabledKey = @"EnableBundles";
NSString *MailbundleVersionKey = @"BundleCompatibilityVersion";

// notifications
NSString *MailbundleDisabledNotification = @"MailbundleDisabledNotification";
NSString *MailbundleEnabledNotification = @"MailbundleEnabledNotification";
NSString *MailbundleRemovedNotification = @"MailbundleRemovedNotification";
NSString *MailbundleInstalledNotification = @"MailbundleInstalledNotification";
NSString *MailbundleFilesystemChangedNotification = @"MailbundleFilesystemChangedNotification";

NSString *MailbundleOperationWindowKey = @"Window";
NSString *MailbundleOperationOriginPathKey = @"OriginPath";
NSString *MailbundleOperationDestinationPathKey = @"DestinationPath";
NSString *MailbundleOperationSuccessKey = @"SuccessKey";
NSString *MailbundleOperationErrorKey = @"Error";
