//
//  FSEventsController.m
//  MailPluginManager
//
//  Created by Aaron on 11/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FSEventsController.h"
#import <CoreServices/CoreServices.h>
#import "Utilities.h"
#import "Constants.h"
#import "MailPluginManagerController.h"

void receiveFSEvents(
	ConstFSEventStreamRef streamRef,
	void *clientCallBackInfo,
	size_t numEvents,
	void *eventPaths,
	const FSEventStreamEventFlags eventFlags[],
	const FSEventStreamEventId eventIds[]
)
{
	NSLog(@"Something changed in a mailbundle directory. Going to refresh.");
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:MailbundleFilesystemChangedNotification
		object:nil
		userInfo:nil];
}


@implementation FSEventsController
-(void)registerForFSEvents
{
	NSArray *pathsToWatch = [[Utilities bundleDirectories] arrayByAddingObjectsFromArray:[Utilities disabledBundleDirectories]];
	FSEventStreamRef eventStream = FSEventStreamCreate(
		kCFAllocatorDefault, 
		&receiveFSEvents,
		NULL, 
		(CFArrayRef) pathsToWatch, 
		kFSEventStreamEventIdSinceNow, 
		0.5, 
		kFSEventStreamCreateFlagNoDefer
	);
	
	CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
	NSString *runLoopMode = NSDefaultRunLoopMode;
	
	FSEventStreamScheduleWithRunLoop(eventStream, runLoop, (CFStringRef) runLoopMode );
	Boolean success = FSEventStreamStart(eventStream);
	NSLog(@"Started listening for filesystem events in bundle directories: %d", success);
}
@end
