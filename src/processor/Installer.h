//
//  Installer.h
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Mailbundle;

@interface Installer : NSObject {

}
// Enable/Disable
+(BOOL) enableMailbundle:(Mailbundle *)bundle replacing:(BOOL)replacing destination:(NSString **)destination error:(NSError **)error;
+(BOOL) disableMailbundle:(Mailbundle *)bundle replacing:(BOOL)replacing destination:(NSString **)destination error:(NSError **)error;

// Install/Remove
+ (BOOL)installMailbundle:(Mailbundle *)bundle inDomain:(NSSearchPathDomainMask)domain replacing:(BOOL)replacing destination:(NSString **)destination error:(NSError **)error;
+ (BOOL)removeMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error;

// Utilities
+ (NSString *)findOrCreateBundlesDirectoryForDomain:(NSSearchPathDomainMask)domain error:(NSError **)error;
+ (NSString *)findOrCreateDisabledBundlesDirectoryForDomain:(NSSearchPathDomainMask)domain error:(NSError **)error;
+ (BOOL)directoryExistsAtPath:(NSString *)path;
+ (BOOL)mailbundleExistsAtPath:(NSString *)path;
+ (BOOL)copyBundleAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)error;
+ (BOOL)moveBundleAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)error;
+ (BOOL)deleteIfReplacing:(NSString *)destinationPath replacing:(BOOL)replacing error:(NSError **)error;
+ (NSString *)findOrCreateLibrarySubdirectory:(NSString *)subpath forDomain:(NSSearchPathDomainMask)domain error:(NSError **)error;

@end
