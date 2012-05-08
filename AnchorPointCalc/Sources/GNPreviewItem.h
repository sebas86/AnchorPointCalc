//
//  GNPreviewItem.h
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 21.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GNPreviewItem : NSObject
{
    NSImage* image;
    CGPoint position;
    CGPoint anchorPoint;
    CGPoint dragOffset;
    BOOL selected;
    BOOL visible;
}

@property (readonly) NSImage* image;
@property (assign) CGPoint position;
@property (assign) CGPoint anchorPoint;
@property (assign) CGPoint dragOffset;
@property (assign) BOOL selected;
@property (assign) BOOL visible;

-(id) initWithImage:(NSImage*)image;

@end
