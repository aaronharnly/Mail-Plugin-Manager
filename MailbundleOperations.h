//
//  PluginProcessor.h
//  MailPluginManager
//
//  Created by Aaron on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Mailbundle;
//
// Central interface for all of the operations on plugins.
//
@interface MailbundleOperations : NSObject {

}
// Get information
+(NSArray *) getInstalledMailbundlePaths;
+(NSArray *) getInstalledMailbundlePathsInDomain:(NSSearchPathDomainMask)domain;
+(NSArray *) getInstalledMailbundlePathsInDomain:(NSSearchPathDomainMask)domain enabled:(BOOL)enabled;

// Enable/disable
+(BOOL) enableMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error;
+(BOOL) disableMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error;

// Install/remove
+(BOOL) installMailbundle:(Mailbundle *)bundle inDomain:(NSSearchPathDomainMask)domain destination:(NSString **)destination error:(NSError **)error;
+(BOOL) removeMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error;

@end
