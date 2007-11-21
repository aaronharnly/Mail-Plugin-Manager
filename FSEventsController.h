//
//  FSEventsController.h
//  MailPluginManager
//
//  Created by Aaron on 11/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>

void receiveFSEvents(
	ConstFSEventStreamRef streamRef,
	void *clientCallBackInfo,
	size_t numEvents,
	void *eventPaths,
	const FSEventStreamEventFlags eventFlags[],
	const FSEventStreamEventId eventIds[]
);

@interface FSEventsController : NSObject {

}
-(void)registerForFSEvents;
@end
