//
//  Mailbundle.m
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Mailbundle.h"

@implementation Mailbundle
-(id)initWithPath:(NSString *)aPath
{
	self = [super init];
	if (self != nil) {
		self.path = aPath;
	}
	return self;
}

-(BOOL) isInstalled
{
	return NO;
}
-(BOOL) isEnabled
{
	return NO;
}
-(NSSearchPathDomainMask) installedDomain
{
	return 0;
}

-(void)setPath:(NSString *)newPath
{
	path = newPath;
	self.bundle = [NSBundle bundleWithPath:path];
	NSLog(@"Mailbundle's info dictionary: %@",[self.bundle infoDictionary]);
	self.name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
	self.identifier = [self.bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	self.version = [self.bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	self.icon = [[NSWorkspace sharedWorkspace] iconForFile:self.path];
}

@synthesize path;
@synthesize name;
@synthesize identifier;
@synthesize version;
@synthesize icon;
@synthesize bundle;

@end
