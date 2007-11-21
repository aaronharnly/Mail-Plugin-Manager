//
//  Mailbundle.h
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class InstallationStatus;

@interface Mailbundle : NSObject {
	NSString *path;
	NSString *name;
	NSString *identifier;
	NSString *version;
	NSString *bundleDescription;
	NSImage *icon;
	NSBundle *bundle;
	BOOL installed;
	BOOL enabled;
	NSSearchPathDomainMask domain;
	NSString *domainName;
}

+ (BOOL)mailbundleExistsAtPath:(NSString *)path;
+ (InstallationStatus *) getInstallationStatusForPath:(NSString *)aPath;

-(id)initWithPath:(NSString *)path;

@property (copy) NSString *path;
@property (copy) NSString *name;
@property (copy) NSString *identifier;
@property (copy) NSString *version;
@property (copy) NSString *bundleDescription;
@property (assign) NSImage *icon;
@property (assign) NSBundle *bundle;
@property BOOL installed;
@property BOOL enabled;
@property NSSearchPathDomainMask domain;
@property (readonly) NSString *domainName;
@end
