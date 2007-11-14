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

@implementation MailbundleOperations
+(NSError *)errorWithMessage:(NSString *)message
{
	return [NSError errorWithDomain:@"MailbundleOperations" code:1 userInfo:[NSDictionary 
				dictionaryWithObject:message
				forKey:@"ErrorMessage"]];
}

+(NSArray *) getInstalledMailbundles 
{
	return [NSArray array];
}
+(NSArray *) getInstalledMailbundlesInDomain:(NSSearchPathDomainMask)domain
{
	return [NSArray array];
}

// Enable/disable
+(BOOL) enableMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error
{
	if (! bundle.installationStatus.installed) {
		*error = [MailbundleOperations errorWithMessage:@"The plugin is not installed."];
		return NO;
	}
	if (bundle.installationStatus.enabled) {
		*error = [MailbundleOperations errorWithMessage:@"The plugin is already enabled."];
		return NO;
	}
	return NO;
}
+(BOOL) disableMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error
{
	return NO;
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
