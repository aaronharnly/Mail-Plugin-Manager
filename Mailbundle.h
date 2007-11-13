//
//  Mailbundle.h
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Mailbundle : NSObject {
	NSString *path;
	NSString *name;
	NSString *identifier;
	NSString *version;
	NSImage *icon;
	NSBundle *bundle;
}
-(id)initWithPath:(NSString *)path;

-(BOOL) isInstalled;
-(BOOL) isEnabled;
-(NSSearchPathDomainMask) installedDomain;

@property (copy) NSString *path;
@property (copy) NSString *name;
@property (copy) NSString *identifier;
@property (copy) NSString *version;
@property (copy) NSImage *icon;
@property NSBundle *bundle;
@end
