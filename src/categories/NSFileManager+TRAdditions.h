//
//  NSFileManager+Additions.h
//  MailPluginManager
//
//  Created by Aaron on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//
//  NSFileManagerAdditions.h
//  TRKit
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface NSFileManager (TRAdditions)
+(NSError *)errorWithMessage:(NSString *)message;
- (BOOL)trashPath:(NSString *)source showAlerts:(BOOL)flag destination:(NSString **)destination error:(NSError **)error;
@end

