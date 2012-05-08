//
//  GNPreview.h
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 20.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GNPreviewDelegate.h"


@interface GNPreview : NSView
{
    NSMutableArray* items;
    CGPoint offset;
	CGPoint relativeOffset;
    CGPoint dragOffset;
	CGPoint tilesAnchorPoint;
    
    id <GNPreviewDelegate> delegate;
    float scale;
    
    CGPoint tilesSize;
    CGPoint tilesScale;
    float tilesRotate;
    int tilesRows;
    int tilesCols;
    
    NSMutableIndexSet* selectedIndexes;
}

@property (nonatomic, assign) id <GNPreviewDelegate> delegate;
@property (nonatomic, assign) float scale;

@property (nonatomic, assign) CGPoint tilesSize;
@property (nonatomic, assign) CGPoint tilesScale;
@property (nonatomic, assign) CGPoint tilesAnchorPoint;
@property (nonatomic, assign) float tilesRotate;
@property (nonatomic, assign) int tilesRows;
@property (nonatomic, assign) int tilesCols;

-(void) center;

-(void) addItemWithImage:(NSImage*)image;
-(void) removeItemAtIndex:(NSUInteger)index;
-(void) removeAll;
-(void) setItemPosition:(NSUInteger)index x:(float)x y:(float)y;
-(void) setItemVisible:(NSUInteger)index visible:(BOOL)visible;

-(void) setSelectedIndexes:(NSIndexSet*)indexes;

@end
