//
//  NSFileManager+Additions.m
//  MailPluginManager
//
//  Created by Aaron on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+TRAdditions.h"
#import "NSString+TRAdditions.h"

//
//  NSFileManagerAdditions.m
//  TRKit
//

#import <assert.h>
#import <unistd.h>
#import <inttypes.h>
#import <pwd.h>
#import <grp.h>
#import <dirent.h>
#import <paths.h>
#import <sys/param.h>
#import <sys/mount.h> // is where the statfs struct is defined
#import <sys/attr.h>
#import <sys/vnode.h>
#import <sys/stat.h>

static __inline__ int RandomIntBetween(int a, int b)
{
    int range = b - a < 0 ? b - a - 1 : b - a + 1; 
    int value = (int)(range * ((float)random() / (float) LONG_MAX));
    return value == range ? a : a + value;
}


@implementation NSFileManager (TRAdditions)
+(NSError *)errorWithMessage:(NSString *)message
{
	return [NSError errorWithDomain:@"FileManager" code:1 userInfo:[NSDictionary 
				dictionaryWithObject:message
				forKey:@"ErrorMessage"]];
}

- (BOOL)trashPath:(NSString *)source showAlerts:(BOOL)flag destination:(NSString **)destination error:(NSError **)error
{
	NSLog(@"Starting trashing of: %@", source);
	NSString *standardizedSource = [source stringByStandardizingPath];
	const char *volPath = [source UTF8String];
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	
	// ----------------------------------- Step 1: Try to "fail-first" with a bunch of checks --------------------------
	// Check to see if we can get rid of this file.
	if ([self isDeletableFileAtPath:standardizedSource] == NO) {
		*error = [NSFileManager errorWithMessage:@"The file can't be deleted; check permissions."];
		NSLog(@"Not deletable");
		return NO;
	}
	NSLog(@"Deletable!");
	// Get attributes.
	BOOL isRemovable, isWritable, isUnmountable;
	NSString *description, *type;
	BOOL success = [workspace getFileSystemInfoForPath:standardizedSource
									  isRemovable:&isRemovable
									   isWritable:&isWritable
									isUnmountable:&isUnmountable
									  description:&description
											 type:&type];
	if (success == NO) {
		NSLog(@"No information!");
		*error = [NSFileManager errorWithMessage:@"Couldn't get information about the source disk."];
		return NO;
	}
	NSLog(@"Got info!");

	if (isWritable == NO) {
		NSLog(@"Not writable!");
		*error = [NSFileManager errorWithMessage:@"The source disk isn't writeable."];
		return NO;
	}
	NSLog(@"Writable!");

	struct statfs sfsb;
	int err = statfs(volPath, &sfsb);
	if (err != 0) {
		NSLog(@"Can't stat!");
		*error = [NSFileManager errorWithMessage:@"Couldn't stat the source disk."];
		return NO;
	}
	NSLog(@"Got stat!");
	
	// ----------------------------------- Step 2: Decide whether file is local or remote --------------------------
	NSString *device = [NSString stringWithUTF8String:sfsb.f_mntfromname];
	BOOL isLocal = [device containsString:@"/dev/"];
	
	// If the file is remote we (at the discresion of the above flag) prompt the
	// user, to trash or not. If flag is NO, NO is returned.
	
	if (isLocal == NO)
	{
		// ----------------------------------- Step 3A: Remove remote file --------------------------
		NSLog(@"Not local!");
	
		// If flag is no we can't simply delete a file (this method is intended 
		// to keep it as safe for the user as possible, return NO.
		
		if (flag == NO) {
			NSLog(@"Not local, can't ask for immediate delete!");
			*error = [NSFileManager errorWithMessage:@"The file is on a remote disk, and would be deleted immediately. We're configured not to do that without asking."];
			return NO;
		}
		NSLog(@"Not local, so going to ask for immediate delete!");
		
		if (NSRunCriticalAlertPanel([NSString stringWithFormat:@"The file \"%@\" "
			@"will be deleted immediately.\nAre you sure you want to continue?",
			[standardizedSource lastPathComponent]],
							@"You cannot undo this action.",
							@"Delete",
							@"Cancel",
							nil) == NSAlertDefaultReturn)
		{
			NSError *deleteError = nil;
			BOOL deleteSuccess = [self removeItemAtPath:standardizedSource error:&deleteError];
			if (deleteSuccess) {
				return YES;
			} else {
				*error = (deleteError == nil) ?
					[NSFileManager errorWithMessage:@"Failed to delete the file immediately."]
					: deleteError;
				return NO;
			}
		}
		else
		{
			*error = [NSFileManager errorWithMessage:@"Cancelled."];
			// User clicked cancel, they obviously do not want to delete the file.
			return NO;
		}
	} else {
		// ----------------------------------- Step 3B: Remove local file --------------------------
		NSLog(@"Local!");	
		// The file is local, we must move it to the appropriate .Trash folder.
		// The appropriate .Trash folder is ~/Trash if it is on the same drive as the 
		// system, otherwise it is to go into /Volumes/<drivename>/.Trashes/<UID>/filename
		// the fix is as follows: we are on a remote volume if the source is on a remote volume AND that remote volume is not the home
		// this line is a mouthful: first, path standardization misses the aliased volume, then the path does not end with a slash so we have to add one
		NSString *home = [[[NSHomeDirectory() stringByResolvingSymlinksInPath] stringByStandardizingPath] stringByAppendingString:@"/"];
		BOOL useDiskTrash = [standardizedSource hasPrefix:@"/Volumes/"] && ![standardizedSource hasPrefix:home];
		
		if (useDiskTrash)
		{
			// ----------------------------------- Step 3Bi: Remove to disk-trash --------------------------
			NSLog(@"Going to use disk trash!");
			BOOL fileExists, isDirectory;
			NSArray * pathComponents = [standardizedSource pathComponents];
			NSString * trashesFolder = @"/";
			trashesFolder = [trashesFolder stringByAppendingPathComponent:
				[pathComponents objectAtIndex:1]];
			trashesFolder = [trashesFolder stringByAppendingPathComponent:
				[pathComponents objectAtIndex:2]];
			trashesFolder = [trashesFolder stringByAppendingPathComponent:@".Trashes"];
			
			NSLog(@"Got trashes folder: %@");
			// If the .Trashes folder doesn't exist on this drive we must create it.
			fileExists = [self fileExistsAtPath:trashesFolder isDirectory:&isDirectory];
			if (!fileExists)
			{
				[self createDirectoryAtPath:trashesFolder
								 attributes:[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithUnsignedLong:777],@"NSFilePosixPermissions",
									 nil]];
			}
			
			trashesFolder = [trashesFolder stringByAppendingPathComponent:
				[NSString stringWithFormat:@"%i",getuid()]];
			
			// If the UID folder doesn't exist we must create it.
			fileExists = [self fileExistsAtPath:trashesFolder isDirectory:&isDirectory];
			if (!fileExists)
			{
				[self createDirectoryAtPath:trashesFolder
								 attributes:[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithUnsignedLong:777],@"NSFilePosixPermissions",
									 nil]];
			}
			
			NSString * destinationPath = [trashesFolder stringByAppendingPathComponent:
				[standardizedSource lastPathComponent]];
			
			// Make sure there are no duplicates.
			while ([self fileExistsAtPath:destinationPath])
			{
				NSString * pathExtention = [destinationPath pathExtension];
				NSString * pathWithoutExtention = [destinationPath stringByDeletingPathExtension];
				destinationPath = [pathWithoutExtention stringByAppendingFormat:@"_%i",RandomIntBetween(0,10000)];
				if (![destinationPath isEqualToString:@""]) {
					destinationPath = [destinationPath stringByAppendingPathExtension:pathExtention];
				}
			}
			
			NSError *moveError = nil;
			BOOL moveSuccess = [self moveItemAtPath:standardizedSource toPath:destinationPath error:&moveError];
			if (moveSuccess) {
				*destination = destinationPath;
				return YES;
			} else {
				*error = (moveError == nil) ?
					[NSFileManager errorWithMessage:@"Failed to move the file to the trash."]
					: moveError;
				return NO;
			}
		} else {
			// ----------------------------------- Step 3Bii: Remove to home-trash --------------------------
			NSLog(@"Going to use home trash!");
			// Use home trash.
			NSString * destinationPath = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
			destinationPath = [destinationPath stringByAppendingPathComponent:
				[standardizedSource lastPathComponent]];
			
			// Make sure there are no duplicates.
			while ([self fileExistsAtPath:destinationPath])
			{
				NSString * pathExtention = [destinationPath pathExtension];
				NSString * pathWithoutExtention = [destinationPath stringByDeletingPathExtension];
				destinationPath = [pathWithoutExtention stringByAppendingFormat:@"_%i",RandomIntBetween(0,10000)];
				if (![destinationPath isEqualToString:@""]) {
					destinationPath = [destinationPath stringByAppendingPathExtension:pathExtention];
				}		
			}
			
			NSError *moveError = nil;
			BOOL moveSuccess = [self moveItemAtPath:standardizedSource toPath:destinationPath error:&moveError];
			if (moveSuccess) {
				*destination = destinationPath;
				return YES;
			} else {
				*error = (moveError == nil) ?
					[NSFileManager errorWithMessage:@"Failed to move the file to the trash."]
					: moveError;
				return NO;
			}
		
		}
			
	}
}

@end