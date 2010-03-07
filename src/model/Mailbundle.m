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

+ (BOOL)mailbundleExistsAtPath:(NSString *)path
{
	NSString *extension = [path pathExtension];
	if (! [extension isEqualToString:MailbundleExtension]) {
		NSLog(@"Doesn't appear to be a mailbundle: '%@'",path);
		return NO;
	}
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory)
		return YES;
	return NO;
}
+(InstallationStatus *) getInstallationStatusForPath:(NSString *)aPath
{
	NSString *userBundleDir = [Utilities librarySubdirectoryPath:BundleSubdirectory inDomain:NSUserDomainMask];
	NSString *userDisabledBundleDir = [Utilities librarySubdirectoryPath:DisabledBundleSubdirectory inDomain:NSUserDomainMask];
	NSString *localBundleDir = [Utilities librarySubdirectoryPath:BundleSubdirectory inDomain:NSLocalDomainMask];
	NSString *localDisabledBundleDir = [Utilities librarySubdirectoryPath:DisabledBundleSubdirectory inDomain:NSLocalDomainMask];
	
	InstallationStatus *newStatus = [[InstallationStatus alloc] init];
	NSRange userBundleResult = [aPath rangeOfString:userBundleDir options:NSCaseInsensitiveSearch];
	
	NSRange userDisabledBundleResult = [aPath rangeOfString:userDisabledBundleDir options:NSCaseInsensitiveSearch];
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

	NSRange localDisabledBundleResult = [aPath rangeOfString:localDisabledBundleDir options:NSCaseInsensitiveSearch];
	if (localDisabledBundleResult.location != NSNotFound) {
		newStatus.installed = YES;
		newStatus.enabled = NO;
		newStatus.domain = NSLocalDomainMask;
		return newStatus;	
	}
	
	NSRange localBundleResult = [aPath rangeOfString:localBundleDir options:NSCaseInsensitiveSearch];
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


+(NSError *)errorWithMessage:(NSString *)message
{
	return [NSError errorWithDomain:@"Mailbundle" code:1 userInfo:[NSDictionary 
				dictionaryWithObject:message
				forKey:@"ErrorMessage"]];
}


// Get information
-(id)initWithPath:(NSString *)aPath
{
	self = [super init];
	if (self != nil) {
		if (! [Mailbundle mailbundleExistsAtPath:aPath]) {
			return nil;
		} else {
			self.path = aPath;		
		}
	}
	return self;
}

-(BOOL)validatePath:(id *)ioValue error:(NSError **)outError {
	NSString *ioPath = *ioValue;
	// step 1: Test that there's a mailbundle
	if (! [Mailbundle mailbundleExistsAtPath:ioPath]) {
		*outError = [Mailbundle errorWithMessage:
		[NSString stringWithFormat:
			NSLocalizedString(@"No mailbundle file appears to exist at: %@",@"Validation error"), ioPath]];
		return NO;
	}

	NSBundle *testBundle = [NSBundle bundleWithPath:ioPath];
	if (testBundle == nil) {
		*outError = [Mailbundle errorWithMessage:[NSString stringWithFormat:
			NSLocalizedString(@"Couldn't load bundle information for path: %@",@"Validation error"), ioPath]];
		return NO;
	}
	return YES;
}
-(void) setDomain:(NSSearchPathDomainMask)aDomain 
{
	domain = aDomain;
	switch (domain) {
		case NSUserDomainMask:
			domainName = NSLocalizedString(@"This user",@"User domain");
			break;
		case NSLocalDomainMask:
			domainName = NSLocalizedString(@"All users",@"Local domain");
			break;
		default:
			domainName = NSLocalizedString(@"(unknown)",@"Unknown domain");
			break;
	}
}
-(void)setPath:(NSString *)newPath
{
	path = newPath;
	self.bundle = [NSBundle bundleWithPath:path];
	self.name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
	if (self.name == nil)
		self.name = [[newPath lastPathComponent] stringByDeletingPathExtension];
	self.identifier = [self.bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	self.version = [self.bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	self.versionString = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	self.bundleDescription = [self.bundle objectForInfoDictionaryKey:@"BundleDescription"];
	self.bundleWebsiteURL = [self.bundle objectForInfoDictionaryKey:@"BundleWebsiteURL"];
	self.updateFeedURL = [self.bundle objectForInfoDictionaryKey:@"SUFeedURL"];
	self.icon = [[NSWorkspace sharedWorkspace] iconForFile:self.path];
	InstallationStatus *newStatus = [Mailbundle getInstallationStatusForPath:path];
	self.installed = newStatus.installed;
	self.enabled = newStatus.enabled;
	self.domain = newStatus.domain;
}

-(NSString *)description {
	return self.path;
}

@synthesize path;
@synthesize name;
@synthesize identifier;
@synthesize version;
@synthesize versionString;
@synthesize bundleDescription;
@synthesize bundleWebsiteURL;
@synthesize updateFeedURL;
@synthesize icon;
@synthesize bundle;
@synthesize installed;
@synthesize enabled;
@synthesize domain;
@synthesize domainName;
@end
