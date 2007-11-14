//
//  Utilities.m
//  MailPluginManager
//
//  Created by Aaron on 11/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import "Constants.h"

@implementation Utilities
+(NSString *) librarySubdirectoryPath:(NSString *)subpath inDomain:(NSSearchPathDomainMask)domain
{
	// Step 1: Get the Library path
	NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, domain, YES);

	if ([libraryPaths count] > 0) {
		NSString *libraryPath = [libraryPaths objectAtIndex:0];
		
		// Step 2: Get the requested subdirectory.
		NSString *fullpath = [libraryPath stringByAppendingPathComponent:subpath];
		return fullpath;
	}
	return nil;
}

+(NSArray *) bundleDirectories
{
	static NSString *userBundleDir = nil;
	static NSString *localBundleDir = nil;
	static NSArray *bundleDirectories = nil;

	if (userBundleDir == nil) {
		userBundleDir = [Utilities librarySubdirectoryPath:BundleSubdirectory inDomain:NSUserDomainMask];
	}
	if (localBundleDir == nil) {
		localBundleDir = [Utilities librarySubdirectoryPath:BundleSubdirectory inDomain:NSLocalDomainMask];
	}
	if (bundleDirectories == nil) {
		bundleDirectories = [NSArray arrayWithObjects:userBundleDir, localBundleDir];
	}
	
	return bundleDirectories;
}

+(NSArray *) disabledBundleDirectories
{
	static NSString *userDisabledBundleDir = nil;
	static NSString *localDisabledBundleDir = nil;
	static NSArray *disabledBundleDirectories = nil;

	if (userDisabledBundleDir == nil) {
		userDisabledBundleDir = [Utilities librarySubdirectoryPath:DisabledBundleSubdirectory inDomain:NSUserDomainMask];
	}
	if (localDisabledBundleDir == nil) {
		localDisabledBundleDir = [Utilities librarySubdirectoryPath:DisabledBundleSubdirectory inDomain:NSLocalDomainMask];
	}
	if (disabledBundleDirectories == nil) {
		disabledBundleDirectories = [NSArray arrayWithObjects:userDisabledBundleDir, localDisabledBundleDir];
	}
	return disabledBundleDirectories;
}
@end
