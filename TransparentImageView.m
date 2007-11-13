//
//  TransparentImageView.m
//  SpaceStation
//
//  Created by Aaron on 11/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TransparentImageView.h"


@implementation TransparentImageView

- (id)initWithFrame:(NSRect)frame image:(NSImage *)anImage {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.image = anImage;		
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [self initWithFrame:frame image:nil];
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
//	NSGraphicsContext* context = [NSGraphicsContext currentContext];
	if (self.image != nil) {
		NSRect imageFrame = NSMakeRect(0.0, 0.0, self.image.size.width, self.image.size.height);
		[self.image drawInRect:rect fromRect:imageFrame  operation:NSCompositeCopy fraction:1.0];
	}
}

- (BOOL)isOpaque {
	return NO;
}

- (void)setImage:(NSImage *)theImage
{
	image = theImage;
	[self setNeedsDisplay:YES];
}

@synthesize image;
@end
