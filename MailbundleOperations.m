//
//  PluginProcessor.m
//  MailPluginManager
//
//  Created by Aaron on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MailbundleOperations.h"
#import "Mailbundle.h"
#import "Installer.h"
#import "MailPreferencesFiddler.h"
#import "Constants.h"
#import "Utilities.h"

@implementation MailbundleOperations
+(NSError *)errorWithMessage:(NSString *)message
{
	return [NSError errorWithDomain:@"MailbundleOperations" code:1 userInfo:[NSDictionary 
				dictionaryWithObject:message
				forKey:@"ErrorMessage"]];
}

+(NSArray *) getInstalledMailbundlePaths 
{
	return [[MailbundleOperations getInstalledMailbundlePathsInDomain:NSUserDomainMask] arrayByAddingObjectsFromArray:
		[MailbundleOperations getInstalledMailbundlePathsInDomain:NSLocalDomainMask]];
}
+(NSArray *) getInstalledMailbundlePathsInDomain:(NSSearchPathDomainMask)domain
{
	return [[MailbundleOperations getInstalledMailbundlePathsInDomain:domain enabled:YES] arrayByAddingObjectsFromArray:
		[MailbundleOperations getInstalledMailbundlePathsInDomain:domain enabled:NO]];
}
+(NSArray *) getInstalledMailbundlePathsInDomain:(NSSearchPathDomainMask)domain enabled:(BOOL)enabled;
{
	NSString *subDirectory = (enabled) ? BundleSubdirectory : DisabledBundleSubdirectory;
	NSString *directory = [Utilities librarySubdirectoryPath:subDirectory inDomain:domain];
	NSArray *directoryContents = [[NSFileManager defaultManager] directoryContentsAtPath:directory];
	NSMutableArray *justMailbundles = [NSMutableArray arrayWithCapacity:[directoryContents count]];
	for (NSString *filename in directoryContents) {
		if ([[filename pathExtension] caseInsensitiveCompare:@"mailbundle"] == NSOrderedSame) {
			[justMailbundles addObject:[directory stringByAppendingPathComponent:filename]];
		}
	}
	return [NSArray arrayWithArray:justMailbundles];
}

// Enable/disable
+(BOOL) enableMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error
{
	NSError *moveError = nil;
	if (! [Installer enableMailbundle:bundle replacing:YES destination:destination error:&moveError] ) {
		*error = (moveError == nil) ?
			[MailbundleOperations errorWithMessage:@"Enabling the mailbundle failed."]
			: moveError;
		return NO;
	}
	return YES;
}
+(BOOL) disableMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error
{
	NSError *moveError = nil;
	if (! [Installer disableMailbundle:bundle replacing:YES destination:destination error:&moveError] ) {
		*error = (moveError == nil) ?
			[MailbundleOperations errorWithMessage:@"Enabling the mailbundle failed."]
			: moveError;
		return NO;
	}
	return YES;
}

// Install/remove
+(BOOL) installMailbundle:(Mailbundle *)bundle inDomain:(NSSearchPathDomainMask)domain destination:(NSString **)destination error:(NSError **)error
{
	NSError *enableError = nil;
	if (! [MailPreferencesFiddler enableMailbundlesForCurrentVersionError:&enableError] ) {
		*error = (enableError == nil) ?
			[MailbundleOperations errorWithMessage:@"Setting Mail preferences to enable mailbundles failed."]
			: enableError;	
		return NO;
	}
	NSError *installError = nil;
	if (! [Installer installMailbundle:bundle inDomain:domain replacing:YES destination:destination error:&installError] ) {
		*error = (installError == nil) ?
			[MailbundleOperations errorWithMessage:@"Copying the mailbundle failed."]
			: installError;
		return NO;
	}
	return YES;
}
+(BOOL) removeMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error
{
	NSError *removeError = nil;
	if (! [Installer removeMailbundle:bundle destination:destination error:&removeError] ) {
		*error = (removeError == nil) ?
			[MailbundleOperations errorWithMessage:@"Removing the mailbundle failed."]
			: removeError;
		return NO;
	}
	return YES;
}

@end
