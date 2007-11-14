//
//  InstallationStatus.h
//  MailPluginManager
//
//  Created by Aaron on 11/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
	@struct InstallationStatus
	@abstract Indicates the current status of a mailbundle (which is purely determined by its path)
	@discussion
	
*/
struct InstallationStatus {
	BOOL installed;
	BOOL enabled;
	NSSearchPathDomainMask domain;
};