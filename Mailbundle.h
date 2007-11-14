//
//  Mailbundle.h
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstallationStatus.h"

@interface Mailbundle : NSObject {
	NSString *path;
	NSString *name;
	NSString *identifier;
	NSString *version;
	NSImage *icon;
	NSBundle *bundle;
	struct InstallationStatus installationStatus;
}
-(id)initWithPath:(NSString *)path;

-(struct InstallationStatus) getInstallationStatus;

@property (copy) NSString *path;
@property (readonly) NSString *name;
@property (readonly) NSString *identifier;
@property (readonly) NSString *version;
@property (readonly) NSImage *icon;
@property (readonly) NSBundle *bundle;
@property (readonly) struct InstallationStatus installationStatus;
@end
