//
//  PluginWindowController.h
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Mailbundle;
@class TransparentImageView;

@interface PluginWindowController : NSWindowController {
	Mailbundle *plugin;
	IBOutlet TransparentImageView *iconView;
	IBOutlet NSTextField *nameField;
	IBOutlet NSTextField *versionField;
	IBOutlet NSButton *installButton;
}
- (id)initWithMailbundle:(Mailbundle *)bundle;

- (IBAction) installPlugin:(id)sender;
- (void)updateDisplay;

- (void) installPluginAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@property Mailbundle *plugin;
@end
