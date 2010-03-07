//
//  PluginWindowController.h
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>
@class Mailbundle;
@class TransparentImageView;

@interface PluginWindowController : NSWindowController {
	Mailbundle *plugin;
	IBOutlet TransparentImageView *iconView;
	IBOutlet NSTextField *nameField;
	IBOutlet NSTextField *versionField;
	IBOutlet NSTextField *descriptionField;
	IBOutlet NSPathControl *pathBar;
	IBOutlet NSTextField *installationStatusField;
	IBOutlet NSTextField *otherCopiesStatusField;
	IBOutlet NSButton *installOrRemoveButton;
	IBOutlet NSButton *enableOrDisableButton;
	IBOutlet BWHyperlinkButton *websiteLink;
}
- (id)initWithMailbundle:(Mailbundle *)bundle;

// manage view
- (void)updateDisplay;
- (NSString *)textForName:(NSString *)name installed:(BOOL)installed enabled:(BOOL)enabled domain:(NSSearchPathDomainMask)domain;
- (void)configureButtonsForCurrentInstallationStatus;

// install, remove
- (IBAction) installOrRemovePlugin:(id)sender;
- (IBAction) installPlugin:(id)sender;
- (IBAction) removePlugin:(id)sender;

// enable, disable
- (IBAction) enableOrDisablePlugin:(id)sender;
- (IBAction) enablePlugin:(id)sender;
- (IBAction) disablePlugin:(id)sender;

@property Mailbundle *plugin;
@end
