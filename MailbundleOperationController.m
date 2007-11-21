//
//  MailbundleOperationController.m
//  MailPluginManager
//
//  Created by Aaron on 11/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MailbundleOperationController.h"
#import "Mailbundle.h"
#import "MailbundleOperations.h"
#import "Constants.h"

@implementation MailbundleOperationController
-(void)postNotificationName:(NSString *)name 
	bundle:(Mailbundle *)bundle
	window:(NSWindow *)window
	originPath:(NSString *)originPath
	destinationPath:(NSString *)destinationPath
	success:(BOOL)success
	error:(NSError *)error
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:7];
	[userInfo setObject:window forKey:MailbundleOperationWindowKey];
	[userInfo setObject:originPath forKey:MailbundleOperationOriginPathKey];
	[userInfo setObject:[NSNumber numberWithBool:success] forKey:MailbundleOperationSuccessKey];
	if (destinationPath != nil)
		[userInfo setObject:destinationPath forKey:MailbundleOperationDestinationPathKey];
	if (error != nil)
		[userInfo setObject:error forKey:MailbundleOperationErrorKey];
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:name 
		object:bundle 
		userInfo:userInfo];

}

// Enable/disable
-(BOOL) enableOrDisableMailbundle:(Mailbundle *)bundle window:(NSWindow *)window
{
	if (bundle.enabled)
		return [self disableMailbundle:bundle window:window];
	else
		return [self enableMailbundle:bundle window:window];
}
-(BOOL) enableMailbundle:(Mailbundle *)bundle window:(NSWindow *)window
{
	NSError *error = nil;
	NSString *destination = nil;
	BOOL success = [MailbundleOperations enableMailbundle:bundle destination:&destination error:&error];
	[self postNotificationName:MailbundleEnabledNotification 
		bundle:bundle
		window:window 
		originPath:bundle.path 
		destinationPath:destination 
		success:success
		error:error];
	return success;
}
-(BOOL) disableMailbundle:(Mailbundle *)bundle window:(NSWindow *)window
{
	NSError *error = nil;
	NSString *destination = nil;
	BOOL success = [MailbundleOperations disableMailbundle:bundle destination:&destination error:&error];
	[self postNotificationName:MailbundleDisabledNotification 
		bundle:bundle
		window:window 
		originPath:bundle.path
		destinationPath:destination
		success:success
		error:error];
	return success;

}

// Install/remove
-(BOOL) installMailbundle:(Mailbundle *)bundle inDomain:(NSSearchPathDomainMask)domain window:(NSWindow *)window
{
	NSError *error = nil;
	NSString *destination = nil;
	BOOL success = [MailbundleOperations installMailbundle:bundle inDomain:NSUserDomainMask destination:&destination error:&error];
	[self postNotificationName:MailbundleInstalledNotification 
		bundle:bundle 
		window:window 
		originPath:bundle.path 
		destinationPath:destination 
		success:success
		error:error];
	return success;
}

-(BOOL) removeMailbundle:(Mailbundle *)bundle window:(NSWindow *)window
{
	NSError *error = nil;
	NSString *destination = nil;
	BOOL success = [MailbundleOperations removeMailbundle:bundle destination:&destination error:&error];
	[self postNotificationName:MailbundleRemovedNotification 
		bundle:bundle 
		window:window 
		originPath:bundle.path 
		destinationPath:destination 
		success:success
		error:error];
	return success;
}


@end
