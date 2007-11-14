//
//  MailbundleEnabler.h
//  MailPluginManager
//
//  Created by Aaron on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MailPreferencesFiddler : NSObject {

}
// All together:
+(BOOL)enableMailbundlesForCurrentVersionError: (NSError **)error;
+(BOOL)enableMailbundlesForVersion:(int)version error:(NSError **)error;

// Enable
+(BOOL)mailbundlesAreEnabled;
+(BOOL)setMailbundlesEnabled:(BOOL)enabled error:(NSError **)error;

// Compatibility version
+(NSNumber *)bundleCompatability;
+(BOOL)setBundleCompatability:(NSNumber *)version error:(NSError **)error;

@end
