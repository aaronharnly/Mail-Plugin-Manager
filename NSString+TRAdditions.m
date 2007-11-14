//
//  NSString+TRAdditions.m
//  MailPluginManager
//
//  Created by Aaron on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSString+TRAdditions.h"


//
//  NSStringAdditions.m
//  TRFoundation
//
@implementation NSString (TRAdditions)

- (BOOL)containsString:(NSString *)subString
{
	return [self rangeOfString:subString].location != NSNotFound;
}

@end