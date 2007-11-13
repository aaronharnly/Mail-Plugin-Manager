//
//  PluginEnabler.m
//  MailPluginManager
//
//  Created by Aaron on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MailbundleEnabler.h"

CFStringRef mailIdentifier = CFSTR("com.apple.mail");
CFStringRef enabledKey = CFSTR("EnableBundles");
CFStringRef versionKey = CFSTR("BundleCompabilityVersion");

@implementation MailbundleEnabler
+(NSError *)errorWithMessage:(NSString *)message
{
	return [NSError errorWithDomain:@"MailbundleEnabler" code:1 userInfo:[NSDictionary 
				dictionaryWithObject:message
				forKey:@"ErrorMessage"]];
}

+(BOOL)enableMailbundlesForCurrentVersionError:(NSError **)error
{
	NSError *enableError = nil;
	if (! [MailbundleEnabler enableMailbundlesForVersion:3 error:&enableError]) {
		*error = (enableError == nil) ?
			[MailbundleEnabler errorWithMessage:@"Couldn't enable Mailbundles."]
			: enableError;
		return NO;
	}
	return YES;
}

+(BOOL)enableMailbundlesForVersion:(int)version error:(NSError **)error
{
	NSError *enableError = nil;
	if (! [MailbundleEnabler setMailbundlesEnabled:YES error:error] ) {
		*error = (enableError == nil) ?
			[MailbundleEnabler errorWithMessage:@"Couldn't enable Mailbundles."]
			: enableError;	
		return NO;
	}
	NSError *compatabilityError = nil;
	if (! [MailbundleEnabler setBundleCompatability:[NSNumber numberWithInt:version] error:&compatabilityError] ) {
		*error = (compatabilityError == nil) ?
			[MailbundleEnabler errorWithMessage:@"Couldn't set the Mailbundle compatability level."]
			: compatabilityError;	
		return NO;
	}
	return YES;
}


// Enable
+(BOOL)mailbundlesAreEnabled {
	Boolean valid = FALSE;
	Boolean enabled = CFPreferencesGetAppBooleanValue(enabledKey, mailIdentifier, &valid);
	return (enabled) ? YES : NO;
}
+(BOOL)setMailbundlesEnabled:(BOOL)enabled error:(NSError **)error{
	CFBooleanRef booleanEnabled = (enabled) ? kCFBooleanTrue : kCFBooleanFalse;
	CFPreferencesSetAppValue(enabledKey, booleanEnabled, mailIdentifier);
	if (CFPreferencesAppSynchronize(mailIdentifier)) {
		return YES;
	} else {
		*error = [MailbundleEnabler errorWithMessage:
			[NSString stringWithFormat:@"Failed to set the %@ preference.", enabledKey]];
		return NO;
	}
}

// Compatibility version
+(NSNumber *)bundleCompatability {
	Boolean valid = FALSE;
	CFIndex compat = CFPreferencesGetAppIntegerValue(versionKey, mailIdentifier, &valid);
	return [NSNumber numberWithInt:compat];
}
+(BOOL)setBundleCompatability:(NSNumber *)version error:(NSError **)error{
	CFPreferencesSetAppValue(versionKey, version, mailIdentifier);
	if (CFPreferencesAppSynchronize(mailIdentifier)) {
		return YES;
	} else {
		*error = [MailbundleEnabler errorWithMessage:
			[NSString stringWithFormat:@"Failed to set the %@ preference.", versionKey]];
		return NO;
	}	
}

@end
