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
#import "MailbundleEnabler.h"

@implementation MailbundleOperations
+(NSError *)errorWithMessage:(NSString *)message
{
	return [NSError errorWithDomain:@"MailbundleOperations" code:1 userInfo:[NSDictionary 
				dictionaryWithObject:message
				forKey:@"ErrorMessage"]];
}


// Get information
+(NSArray *) getInstalledMailbundles 
{
	return [NSArray array];
}
+(NSArray *) getInstalledMailbundlesInDomain:(NSSearchPathDomainMask)domain
{
	return [NSArray array];
}

// Enable/disable
+(BOOL) toggleEnabledOrDisabledMailbundle:(Mailbundle *)bundle error:(NSError **)error
{
	return NO;
}
+(BOOL) enableMailbundle:(Mailbundle *)bundle error:(NSError **)error
{
	return NO;
}
+(BOOL) disableMailbundle:(Mailbundle *)bundle error:(NSError **)error
{
	return NO;
}

// Install/remove
+(BOOL) installMailbundle:(Mailbundle *)bundle inDomain:(NSSearchPathDomainMask)domain error:(NSError **)error
{
	NSError *enableError = nil;
	if (! [MailbundleEnabler enableMailbundlesForCurrentVersionError:&enableError] ) {
		*error = (enableError == nil) ?
			[MailbundleOperations errorWithMessage:@"Setting Mail preferences to enable mailbundles failed."]
			: enableError;	
		return NO;
	}
	NSError *installError = nil;
	if (! [Installer installMailbundle:bundle inDomain:domain replacing:YES error:&installError] ) {
		*error = (installError == nil) ?
			[MailbundleOperations errorWithMessage:@"Copying the mailbundle failed."]
			: installError;
		return NO;
	}
	return YES;
}
+(BOOL) removeMailbundle:(Mailbundle *)bundle error:(NSError **)error
{
	return NO;
}

@end
