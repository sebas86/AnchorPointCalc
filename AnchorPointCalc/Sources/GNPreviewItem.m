//
//  GNPreviewItem.m
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 21.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import "GNPreviewItem.h"

@implementation GNPreviewItem

@synthesize image;
@synthesize position;
@synthesize anchorPoint;
@synthesize dragOffset;
@synthesize selected;
@synthesize visible;

-(id) initWithImage:(NSImage*)newImage
{
    if ((self = [super init]))
    {
        image = [newImage retain];
        anchorPoint = CGPointMake(0.5f, 0.5f);
        position = CGPointMake(0, 0);
        dragOffset = CGPointMake(0, 0);
        selected = NO;
        visible = YES;
    }
    return self;
}

-(void) dealloc
{
    [image release];
    [super dealloc];
}

@end
