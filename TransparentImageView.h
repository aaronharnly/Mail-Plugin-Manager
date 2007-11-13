//
//  TransparentImageView.h
//  SpaceStation
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TransparentImageView : NSView {
	NSImage *image;
}
- (id)initWithFrame:(NSRect)frame image:(NSImage *)image;
@property (assign) NSImage *image;
@end
