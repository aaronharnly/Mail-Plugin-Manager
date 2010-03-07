//
//  Installer.m
//  MailPluginManager
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Installer.h"
#import "Mailbundle.h"
#import "Constants.h"
#import "Utilities.h"
#import "NSFileManager+TRAdditions.h"

@implementation Installer
+(NSError *)errorWithMessage:(NSString *)message
{
	return [NSError errorWithDomain:@"Installer" code:1 userInfo:[NSDictionary 
				dictionaryWithObject:message
				forKey:@"ErrorMessage"]];
}
// Enable/Disable
+(BOOL) enableMailbundle:(Mailbundle *)bundle replacing:(BOOL)replacing destination:(NSString **)destination error:(NSError **)error
{
	// Step 0: validate
	if (! bundle.installed) {
		*error = [Installer errorWithMessage:
			NSLocalizedString(@"This plugin isn't installed.",@"Install error (trying to enable): Can't enable a bundle that isn't installed.")];
		return NO;
	}

	if (bundle.enabled) {
		*error = [Installer errorWithMessage:
			NSLocalizedString(@"This plugin is already enabled.",@"Install error (trying to enable): Already enabled")];
		return NO;
	}

	// Step 1: Get our bundles dir
	NSError *bundleDirError = nil;
	NSString *bundlesDir = [Installer findOrCreateBundlesDirectoryForDomain:bundle.domain error:&bundleDirError];
	if (bundlesDir == nil) {
		*error = (bundleDirError == nil) ?
			[Installer errorWithMessage:
				NSLocalizedString(@"Couldn't find or create the Bundles directory.",@"Install error (trying to enable): No Mail/Bundles dir")]
			: bundleDirError;
		NSLog(@"Failed, because we couldn't find or create the Bundles directory.");
		return NO;
	}
	NSLog(@"Have bundles dir: %@", bundlesDir);
	
	// Step 2: Get our source item
	if (! [Installer mailbundleExistsAtPath:bundle.path]) {
		*error = [Installer errorWithMessage:[NSString 
			stringWithFormat:NSLocalizedString(@"Couldn't find the plugin to enable at: %@",@"Install error (trying to enable): Can't find the file to copy"), bundle.path]];
		NSLog(@"Failed, because we couldn't find the plugin to enable.");
		return NO;
	}	
	
	// Step 3: Delete an existing mailbundle, if it's already present & we're replacing
	NSString *destinationPath = [bundlesDir stringByAppendingPathComponent:[bundle.path lastPathComponent]];
	NSError *deleteExistingError = nil;
	if (! [Installer deleteIfReplacing:destinationPath replacing:replacing error:&deleteExistingError]) {
		*error = (deleteExistingError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"An existing bundle is present that we wouldn't or couldn't remove.",@"Install error (trying to enable): Can't remove an existing plugin")]
			: deleteExistingError;
		NSLog(@"Failed, because an existing bundle is present that we wouldn't or couldn't remove.");
		return NO;
	}
	
	// Step 4: Move
	NSError *moveError = nil;
	if (! [Installer moveBundleAtPath:bundle.path toPath:destinationPath error:&moveError]) {
		*error = (moveError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"Failed to move the plugin.",@"Install error (trying to enable): Couldn't move the file from disabled to enabled folder")]
			: moveError;
		NSLog(@"Failed to move the bundle.");
		return NO;
	}
	
	// We did it! Inform the caller of the destination
	*destination = destinationPath;
	return YES;
}
+(BOOL) disableMailbundle:(Mailbundle *)bundle replacing:(BOOL)replacing destination:(NSString **)destination error:(NSError **)error
{
	// Step 0: validate
	if (! bundle.installed) {
		*error = [Installer errorWithMessage:NSLocalizedString(@"This plugin isn't installed.",@"Install error (trying to disable)")];
		return NO;
	}
	if (! bundle.enabled) {
		*error = [Installer errorWithMessage:NSLocalizedString(@"This plugin is already disabled.",@"Install error (trying to disable)")];
		return NO;
	}

	// Step 1: Get our disabled-bundles dir
	NSError *bundleDirError = nil;
	NSString *bundlesDir = [Installer findOrCreateDisabledBundlesDirectoryForDomain:bundle.domain error:&bundleDirError];
	if (bundlesDir == nil) {
		*error = (bundleDirError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"Couldn't find or create the Disabled Bundles directory.",@"Install error (trying to disable)")]
			: bundleDirError;
		NSLog(@"Failed, because we couldn't find or create the Disabled Bundles directory.");
		return NO;
	}
	NSLog(@"Have disabled bundles dir: %@", bundlesDir);
	
	// Step 2: Get our source item
	if (! [Installer mailbundleExistsAtPath:bundle.path]) {
		*error = [Installer errorWithMessage:[NSString 
			stringWithFormat:NSLocalizedString(@"Couldn't find the plugin to disable at: %@",@"Install error (trying to disable)"), bundle.path]];
		NSLog(@"Failed, because we couldn't find the plugin to disable.");
		return NO;
	}	
	
	// Step 3: Delete an existing mailbundle, if it's already present & we're replacing
	NSString *destinationPath = [bundlesDir stringByAppendingPathComponent:[bundle.path lastPathComponent]];
	NSError *deleteExistingError = nil;
	if (! [Installer deleteIfReplacing:destinationPath replacing:replacing error:&deleteExistingError]) {
		*error = (deleteExistingError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"An existing bundle is present that we wouldn't or couldn't remove.",@"Install error (trying to disable)")]
			: deleteExistingError;
		NSLog(@"Failed, because an existing bundle is present that we wouldn't or couldn't remove.");
		return NO;
	}
	
	// Step 4: Move
	NSError *moveError = nil;
	if (! [Installer moveBundleAtPath:bundle.path toPath:destinationPath error:&moveError]) {
		*error = (moveError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"Failed to move the plugin.",@"Install error (trying to disable)")]
			: moveError;
		NSLog(@"Failed to move the bundle.");
		return NO;
	}
	
	// We did it! Inform the caller of the destination
	*destination = destinationPath;
	return YES;

}

// Install/Remove
/*!
	@method installBundle:forDomain:replacing:
	@abstract Installs the given mailbundle's files into the requested domain. Returns true if successful.
	@discussion
	Authentication will be needed here.
*/
+ (BOOL)installMailbundle:(Mailbundle *)bundle inDomain:(NSSearchPathDomainMask)domain replacing:(BOOL)replacing destination:(NSString **)destination error:(NSError **)error
{
	// Step 1: Get our bundles dir
	NSError *bundleDirError = nil;
	NSString *bundlesDir = [Installer findOrCreateBundlesDirectoryForDomain:domain error:&bundleDirError];
	if (bundlesDir == nil) {
		*error = (bundleDirError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"Couldn't find or create the Bundles directory.",@"Install error (trying to install)")]
			: bundleDirError;
		NSLog(@"Failed, because we couldn't find or create the Bundles directory.");
		return NO;
	}
	NSLog(@"Have bundles dir: %@", bundlesDir);
	
	// Step 2: Get our source item
	if (! [Installer mailbundleExistsAtPath:bundle.path]) {
		*error = [Installer errorWithMessage:[NSString 
			stringWithFormat:NSLocalizedString(@"Couldn't find the plugin to install at: %@",@"Install error (trying to install)"), bundle.path]];
		NSLog(@"Failed, because we couldn't find the plugin to install.");
		return NO;
	}	
	
	// Step 3: Delete an existing mailbundle, if it's already present & we're replacing
	NSString *destinationPath = [bundlesDir stringByAppendingPathComponent:[bundle.path lastPathComponent]];
	NSError *deleteExistingError = nil;
	if (! [Installer deleteIfReplacing:destinationPath replacing:replacing error:&deleteExistingError]) {
		*error = (deleteExistingError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"An existing bundle is present that we wouldn't or couldn't remove.",@"Install error (trying to install)")]
			: deleteExistingError;
		NSLog(@"Failed, because an existing bundle is present that we wouldn't or couldn't remove.");
		return NO;
	}
	
	// Step 4: Copy
	NSError *copyError = nil;
	if (! [Installer copyBundleAtPath:bundle.path toPath:destinationPath error:&copyError]) {
		*error = (copyError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"Failed to copy the  bundle.",@"Install error (trying to install)")]
			: copyError;
		NSLog(@"Failed to copy the  bundle.");
		return NO;
	}
	
	// We did it! Inform the caller of the destination
	*destination = destinationPath;
	return YES;
}

+ (BOOL)removeMailbundle:(Mailbundle *)bundle destination:(NSString **)destination error:(NSError **)error
{
	// Step 1: Get our source item
	if (! [Installer mailbundleExistsAtPath:bundle.path]) {
		*error = [Installer errorWithMessage:[NSString 
			stringWithFormat:NSLocalizedString(@"Couldn't find the plugin to remove at: %@", @"Install error (trying to remove)"),bundle.path]];
		NSLog(@"Failed, because we couldn't find the plugin to remove.");
		return NO;
	}

	// Step 2: Move it to trash
	NSError *trashError = nil;
	BOOL success = [[NSFileManager defaultManager] trashPath:bundle.path showAlerts:YES destination:destination error:&trashError];
	if (success) {
		return YES;
	} else {
		*error = (trashError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"Failed to trash the bundle (for an unknown reason).",@"Install error (trying to remove)")]
			: trashError;
		return NO;
	}
}

// ----------------------- Utilities ----------------------------
/*!
	@method findOrCreateBundlesDirectoryForDomain:
	@abstract Kinda like it says. Returns path to the bundles directory on success; nil on failure.
	@discussion
	
*/
+ (NSString *)findOrCreateBundlesDirectoryForDomain:(NSSearchPathDomainMask)domain error:(NSError **)error
{
	return [Installer findOrCreateLibrarySubdirectory:BundleSubdirectory forDomain:domain error:error];
}

/*!
	@method findOrCreateDisabledBundlesDirectoryForDomain:
	@abstract Returns path to the directory for disabled bundles on success; nil on failure.
	@discussion
	
*/
+ (NSString *)findOrCreateDisabledBundlesDirectoryForDomain:(NSSearchPathDomainMask)domain error:(NSError **)error
{
	return [Installer findOrCreateLibrarySubdirectory:DisabledBundleSubdirectory forDomain:domain error:error];
}


/*!
	@method directoryExistsAtPath:
	@abstract Returns true if a directory exists at the given path.
	@discussion
*/
+ (BOOL)directoryExistsAtPath:(NSString *)path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory)
		return YES;
	return NO;
}

+ (BOOL)mailbundleExistsAtPath:(NSString *)path
{
	NSString *extension = [path pathExtension];
	if (! [extension isEqualToString:MailbundleExtension]) {
		NSLog(@"Doesn't appear to be a mailbundle: '%@'",path);
		return NO;
	}
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory)
		return YES;
	return NO;
}

+ (BOOL)copyBundleAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)error
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *copyItemError = nil;
	BOOL success = [fileManager copyItemAtPath:sourcePath toPath:destinationPath error:&copyItemError];
	if (! success) {
		*error = (copyItemError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"Failed to copy the bundle (for an unknown reason).",@"Install error (generic copy error message)")]
			: copyItemError;
	}
	return success;
}

+ (BOOL)moveBundleAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)error
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *moveItemError = nil;
	BOOL success = [fileManager moveItemAtPath:sourcePath toPath:destinationPath error:&moveItemError];
	if (! success) {
		*error = (moveItemError == nil) ?
			[Installer errorWithMessage:NSLocalizedString(@"Failed to move the bundle (for an unknown reason).",@"Install error (generic move error message)")]
			: moveItemError;
	}
	return success;
}

/*!
	@method deleteIfReplacing:replacing:
	@abstract Removes if 
	@discussion
*/
+ (BOOL)deleteIfReplacing:(NSString *)destinationPath replacing:(BOOL)replacing error:(NSError **)error
{
	if ([Installer directoryExistsAtPath:destinationPath]) {
		NSLog(@"A bundle already exists at: %@", destinationPath);
		if (replacing) {
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSError *removeExistingError = nil;
			if ([fileManager removeItemAtPath:destinationPath error:&removeExistingError]) {
				NSLog(@"Removed existing bundle.", destinationPath);
				return YES;
			} else {
				*error = (removeExistingError == nil) ?
					[Installer errorWithMessage:NSLocalizedString(@"Failed to remove existing bundle.",@"Install error (trying to remove an existing mailbundle)")]
					: removeExistingError;
				return NO;
			}
		} else {
			*error = [Installer errorWithMessage:NSLocalizedString(@"A plugin already exists, and we've been asked not to replace existing items.",@"Install error (trying to remove an existing mailbundle)")];
			NSLog(@"A file exists and we're not replacing.");
			return NO;
		}		
	}
	else // no worries 
		return YES;
}

/*!
	@method findOrCreateLibrarySubdirectory:forDomain:
	@abstract Returns path to the given subdirectory of ~/Library or /Library on success; nil on failure.
	@discussion
	
*/
+ (NSString *)findOrCreateLibrarySubdirectory:(NSString *)subpath forDomain:(NSSearchPathDomainMask)domain error:(NSError **)error
{
	// Step 1: Get the subdirectory path
	NSString *fullpath = [Utilities librarySubdirectoryPath:subpath inDomain:domain];
	NSLog(@"Subpath: %@", fullpath);
	
	if (fullpath == nil) {
		NSLog(@"Failed, because we didn't get an appropriate Library directory.");
		*error = [Installer errorWithMessage:NSLocalizedString(@"Failed, because we didn't get an appropriate Library directory.",@"Install error (trying to locate Library directory)")];
		return nil;
	}

	// Step 2: Create the dir if necessary
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	if ([fileManager fileExistsAtPath:fullpath isDirectory:&isDirectory]) {
		if (isDirectory) {
			NSLog(@"Found an existing directory at %@", fullpath);
			return fullpath;
		} else {
			*error = [Installer errorWithMessage:
				[NSString stringWithFormat:NSLocalizedString(@"Failed to create the subdirectory '%@', because there's an existing file there.",@"Install error (trying to create Library/Bundles directory)"),fullpath]];
			NSLog(@"Failed, because there's a *file* (rather than a directory) at %@",fullpath);
			return nil;			
		}
	} else {
		NSLog(@"No directory at %@, so we'll make one", fullpath);
		if ([fileManager createDirectoryAtPath:fullpath attributes:nil]) {
			NSLog(@"Successfully created.");
			return fullpath;
		} else {
			NSLog(@"Failed, because we couldn't create the subdirectory.");
			*error = [Installer errorWithMessage:
				[NSString stringWithFormat:NSLocalizedString(@"Failed to create the subdirectory '%@' for an unknown reason. Check permissions?",@"Install error (trying to create Library/Bundles directory)"),fullpath]];
			return nil;
		}
	}
}


@end
