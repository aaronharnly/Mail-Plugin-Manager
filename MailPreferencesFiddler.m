//
//  PluginEnabler.m
//  MailPluginManager
//
//  Created by Aaron on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MailPreferencesFiddler.h"
#import "Constants.h"

@implementation MailPreferencesFiddler
+(NSError *)errorWithMessage:(NSString *)message
{
	return [NSError errorWithDomain:@"MailbundleEnabler" code:1 userInfo:[NSDictionary 
				dictionaryWithObject:message
				forKey:@"ErrorMessage"]];
}

+(BOOL)enableMailbundlesForCurrentVersionError:(NSError **)error
{
	NSError *enableError = nil;
	if (! [MailPreferencesFiddler enableMailbundlesForVersion:3 error:&enableError]) {
		*error = (enableError == nil) ?
			[MailPreferencesFiddler errorWithMessage:@"Couldn't enable Mailbundles."]
			: enableError;
		return NO;
	}
	return YES;
}

+(BOOL)enableMailbundlesForVersion:(int)version error:(NSError **)error
{
	NSError *enableError = nil;
	if (! [MailPreferencesFiddler setMailbundlesEnabled:YES error:error] ) {
		*error = (enableError == nil) ?
			[MailPreferencesFiddler errorWithMessage:@"Couldn't enable Mailbundles."]
			: enableError;	
		return NO;
	}
	NSError *compatabilityError = nil;
	if (! [MailPreferencesFiddler setBundleCompatability:[NSNumber numberWithInt:version] error:&compatabilityError] ) {
		*error = (compatabilityError == nil) ?
			[MailPreferencesFiddler errorWithMessage:@"Couldn't set the Mailbundle compatability level."]
			: compatabilityError;	
		return NO;
	}
	return YES;
}


// Enable
+(BOOL)mailbundlesAreEnabled {
	Boolean valid = FALSE;
	Boolean enabled = CFPreferencesGetAppBooleanValue((CFStringRef) MailbundlesEnabledKey, (CFStringRef) MailIdentifier, &valid);
	return (enabled) ? YES : NO;
}
+(BOOL)setMailbundlesEnabled:(BOOL)enabled error:(NSError **)error{
	CFBooleanRef booleanEnabled = (enabled) ? kCFBooleanTrue : kCFBooleanFalse;
	CFPreferencesSetAppValue((CFStringRef) MailbundlesEnabledKey, booleanEnabled, (CFStringRef) MailIdentifier);
	if (CFPreferencesAppSynchronize((CFStringRef) MailIdentifier)) {
		return YES;
	} else {
		*error = [MailPreferencesFiddler errorWithMessage:
			[NSString stringWithFormat:@"Failed to set the %@ preference.", MailbundlesEnabledKey]];
		return NO;
	}
}

// Compatibility version
+(NSNumber *)bundleCompatability {
	Boolean valid = FALSE;
	CFIndex compat = CFPreferencesGetAppIntegerValue((CFStringRef) MailbundleVersionKey,(CFStringRef)  MailIdentifier, &valid);
	return [NSNumber numberWithInt:compat];
}
+(BOOL)setBundleCompatability:(NSNumber *)version error:(NSError **)error{
	CFPreferencesSetAppValue((CFStringRef) MailbundleVersionKey, version, (CFStringRef) MailIdentifier);
	if (CFPreferencesAppSynchronize((CFStringRef) MailIdentifier)) {
		return YES;
	} else {
		*error = [MailPreferencesFiddler errorWithMessage:
			[NSString stringWithFormat:@"Failed to set the %@ preference.", MailbundleVersionKey]];
		return NO;
	}	
}

@end
