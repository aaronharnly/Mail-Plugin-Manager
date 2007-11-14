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
	IBOutlet NSTextField *descriptionField;
	IBOutlet NSPathControl *pathBar;
	IBOutlet NSTextField *installationStatusField;
	IBOutlet NSTextField *otherCopiesStatusField;
	IBOutlet NSButton *installOrRemoveButton;
	IBOutlet NSButton *enableOrDisableButton;
}
- (id)initWithMailbundle:(Mailbundle *)bundle;

// manage view
- (void)updateDisplay;
- (NSString *)textForName:(NSString *)name installationStatus:(struct InstallationStatus)status;
- (void)configureButtonsForCurrentInstallationStatus;

// manage alerts
- (void) displayAlertForSuccess:(BOOL)success error:(NSError *)error successMessage:(NSString *)successMessage successInfo:(NSString *)successInfo failureMessage:(NSString *)failureMessage pathToOpen:(NSString *)path;
- (void) pluginAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

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
