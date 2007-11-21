//
//  PluginLibraryController.m
//  MailPluginManager
//
//  Created by Aaron on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PluginLibraryController.h"
#import "MailbundleOperations.h"
#import "Mailbundle.h"
#import "NSArray+CocoaDevUsersAdditions.h"

@implementation PluginLibraryController
-(id)init
{
	self = [super init];
	if (self != nil) {
		plugins = [[NSMutableSet alloc] init];
	}
	return self;
}

-(void) awakeFromNib 
{
	[pluginArrayController setPreservesSelection:YES];
	[pluginArrayController setSelectsInsertedObjects:NO];
	[self loadFromDisk: self];
}

-(IBAction) loadFromDisk:(id)sender
{
	[pluginArrayController addObjects:[PluginLibraryController getInstalledMailbundles]];
}
-(void) refreshMovingPath:(NSString *)oldPath toPath:(NSString *)newPath
{
	NSMutableArray *selectedPaths = [NSMutableArray arrayWithCapacity:[[pluginArrayController selectedObjects] count]];
	for (Mailbundle *bundle in [pluginArrayController selectedObjects]) {
		if ([[bundle path] isEqualToString:oldPath])
			[selectedPaths addObject:newPath];
		else
			[selectedPaths addObject:[bundle path]];
	}
	
	NSArray *objectsToRemove = [NSArray arrayWithArray:[pluginArrayController arrangedObjects]];
	[pluginArrayController removeObjects:objectsToRemove];
	[self loadFromDisk:self];
	
	for (Mailbundle *bundle in [pluginArrayController arrangedObjects]) {
		for (NSString *path in selectedPaths) {
			if ([[bundle path] isEqualToString:path])
				[pluginArrayController addSelectedObjects:[NSArray arrayWithObject:bundle]];
		}
	}
}
-(IBAction) refresh:(id)sender
{
	[self refreshMovingPath:nil toPath:nil];
}
+(NSArray *) getInstalledMailbundles
{
	NSArray *mailbundlePaths = [MailbundleOperations getInstalledMailbundlePaths];
	NSMutableArray *mailbundles = [NSMutableArray arrayWithCapacity:[mailbundlePaths count]];
	for (NSString *path in mailbundlePaths) {
		Mailbundle *bundle = [[Mailbundle alloc] initWithPath:path];
		[mailbundles addObject:bundle];
	}
	return mailbundles;
}
-(NSArray *) installedMailbundles
{
	return [pluginArrayController arrangedObjects];
}
-(NSArray *) installedMailbundlesForIdentifier:(NSString *)identifier
{
	NSMutableArray *matches = [NSMutableArray arrayWithCapacity:[[self installedMailbundles] count]];
	for (Mailbundle *bundle in [self installedMailbundles]) {
		if ([[bundle identifier] isEqualToString:identifier])
			[matches addObject:bundle];
	}
	return [NSArray arrayWithArray:matches];
}
-(NSArray *) enabledMailbundlesForIdentifier:(NSString *)identifier
{
	NSArray *installed = [self installedMailbundlesForIdentifier:identifier];	
	NSMutableArray *matches = [NSMutableArray arrayWithCapacity:[installed count]];
	for (Mailbundle *bundle in installed) {
		if ([bundle enabled]) 
			[matches addObject:bundle];
	}
	return [NSArray arrayWithArray:matches];
}

@synthesize plugins;
@synthesize pluginArrayController;
@end
