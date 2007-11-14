//
//  Utilities.h
//  MailPluginManager
//
//  Created by Aaron on 11/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Utilities : NSObject {

}
+(NSString *) librarySubdirectoryPath:(NSString *)subpath inDomain:(NSSearchPathDomainMask)domain;
+(NSArray *) bundleDirectories;
+(NSArray *) disabledBundleDirectories;

@end
