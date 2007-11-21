//
//  InstallationStatus.m
//  MailPluginManager
//
//  Created by Aaron on 11/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "InstallationStatus.h"


@implementation InstallationStatus
@synthesize installed;
@synthesize enabled;
@synthesize domain;
-(void) setDomain:(NSSearchPathDomainMask)aDomain 
{
	domain = aDomain;
	switch (domain) {
		case NSUserDomainMask:
			domainName = @"This user";
			break;
		case NSLocalDomainMask:
			domainName = @"All users";
			break;
		default:
			domainName = @"(unknown)";
			break;
	}
}
@synthesize domainName;
@end
