//
//  MailbundleOperationController.h
//  MailPluginManager
//
//  Created by Aaron on 11/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Mailbundle;
// Performs operations on Mailbundles, and then posts notifications
@interface MailbundleOperationController : NSObject {

}

// Enable/disable
-(BOOL) enableOrDisableMailbundle:(Mailbundle *)bundle window:(NSWindow *)window;
-(BOOL) enableMailbundle:(Mailbundle *)bundle window:(NSWindow *)window;
-(BOOL) disableMailbundle:(Mailbundle *)bundle window:(NSWindow *)window;

// Install/remove
-(BOOL) installMailbundle:(Mailbundle *)bundle inDomain:(NSSearchPathDomainMask)domain window:(NSWindow *)window;
-(BOOL) removeMailbundle:(Mailbundle *)bundle window:(NSWindow *)window;

@end
