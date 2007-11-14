//
//  Mailbundle.m
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Mailbundle.h"
#import "Utilities.h"
#import "Constants.h"
#import "InstallationStatus.h"

@implementation Mailbundle
// Get information
-(id)initWithPath:(NSString *)aPath
{
	self = [super init];
	if (self != nil) {
		self.path = aPath;
	}
	return self;
}

-(struct InstallationStatus) getInstallationStatus
{
	NSString *userBundleDir = [Utilities librarySubdirectoryPath:BundleSubdirectory inDomain:NSUserDomainMask];
	NSString *userDisabledBundleDir = [Utilities librarySubdirectoryPath:DisabledBundleSubdirectory inDomain:NSUserDomainMask];
	NSString *localBundleDir = [Utilities librarySubdirectoryPath:BundleSubdirectory inDomain:NSLocalDomainMask];
	NSString *localDisabledBundleDir = [Utilities librarySubdirectoryPath:DisabledBundleSubdirectory inDomain:NSLocalDomainMask];
	
	struct InstallationStatus newStatus;
	NSRange userBundleResult = [self.path rangeOfString:userBundleDir options:NSCaseInsensitiveSearch];
	
	NSRange userDisabledBundleResult = [self.path rangeOfString:userDisabledBundleDir options:NSCaseInsensitiveSearch];
	if (userDisabledBundleResult.location != NSNotFound) {
		newStatus.installed = YES;
		newStatus.enabled = NO;
		newStatus.domain = NSUserDomainMask;
		return newStatus;	
	}
	
	if (userBundleResult.location != NSNotFound) {
		newStatus.installed = YES;
		newStatus.enabled = YES;
		newStatus.domain = NSUserDomainMask;
		return newStatus;
	}

	NSRange localDisabledBundleResult = [self.path rangeOfString:localDisabledBundleDir options:NSCaseInsensitiveSearch];
	if (localDisabledBundleResult.location != NSNotFound) {
		newStatus.installed = YES;
		newStatus.enabled = NO;
		newStatus.domain = NSLocalDomainMask;
		return newStatus;	
	}
	
	NSRange localBundleResult = [self.path rangeOfString:localBundleDir options:NSCaseInsensitiveSearch];
	if (localBundleResult.location != NSNotFound) {
		newStatus.installed = YES;
		newStatus.enabled = YES;
		newStatus.domain = NSLocalDomainMask;
		return newStatus;
	}
	
	newStatus.installed = NO;
	newStatus.enabled = NO;
	newStatus.domain = 0;
	return newStatus;	
}
-(BOOL) determineWhetherIsInstalledAndEnabled
{
	// We'll assume we're installed if we're in either the user-domain or local-domain bundle dirs.
	BOOL isInBundleDir = NO;
	for (NSString *bundleDir in [Utilities bundleDirectories]) {
		NSRange searchResult = [self.path rangeOfString:bundleDir options:NSCaseInsensitiveSearch];
		if (searchResult.location != NSNotFound) {
			isInBundleDir = YES;
		}
	}
	return isInBundleDir;
}
-(BOOL) determineWhetherIsInstalledAndDisabled
{
	// We'll assume we're installed if we're in either the user-domain or local-domain bundle dirs.
	BOOL isInBundleDir = NO;
	for (NSString *bundleDir in [Utilities disabledBundleDirectories]) {
		NSRange searchResult = [self.path rangeOfString:bundleDir options:NSCaseInsensitiveSearch];
		if (searchResult.location != NSNotFound)
			isInBundleDir = YES;
	}
	return isInBundleDir;
}

-(void)setPath:(NSString *)newPath
{
	path = newPath;
	bundle = [NSBundle bundleWithPath:path];
	name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
	identifier = [self.bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	version = [self.bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	description = [self.bundle objectForInfoDictionaryKey:@"Description"];
	icon = [[NSWorkspace sharedWorkspace] iconForFile:self.path];
	installationStatus = [self getInstallationStatus];
}

@synthesize path;
@synthesize name;
@synthesize identifier;
@synthesize version;
@synthesize description;
@synthesize icon;
@synthesize bundle;
@synthesize installationStatus;

@end
