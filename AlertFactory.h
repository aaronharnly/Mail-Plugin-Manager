//
//  AlertController.h
//  MailPluginManager
//
//  Created by Aaron on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Mailbundle;
@interface AlertFactory : NSObject {

}
// manage alerts
+ (NSAlert *) alertForPlugin:(Mailbundle *)plugin success:(BOOL)success error:(NSError *)error successMessage:(NSString *)successMessage successInfo:(NSString *)successInfo failureMessage:(NSString *)failureMessage;

@end
