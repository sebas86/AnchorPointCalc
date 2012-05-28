//
//  GNPreview.m
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 20.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import "GNPreview.h"
#import "GNPreviewItem.h"


#pragma mark Private methods interface

@interface GNPreview ()
-(void) needsRedraw;
-(CGRect) boundingBox;
-(void) updateRelativeOffset;
-(void) updateOffset;
@end


#pragma mark - Implementation

@implementation GNPreview

#pragma mark - Properties

@synthesize delegate;
@synthesize tilesSize;
@synthesize tilesScale;
@synthesize tilesAnchorPoint;
@synthesize tilesRotate;
@synthesize tilesRows;
@synthesize tilesCols;

-(float) scale
{
    return scale;
}

-(void) setScale:(float)value
{
    if (value < 0.01f && value > -0.01f)
	{
        return;
	}
    
    scale = value;
    
	[self updateOffset];
    [self needsRedraw];
}

-(void) setTilesAnchorPoint:(CGPoint)newValue
{
	tilesAnchorPoint = newValue;
	[self needsRedraw];
}

-(void) setTilesSize:(CGPoint)newValue
{
	tilesSize = newValue;
	[self needsRedraw];
}

-(void) setTilesRotate:(float)newValue
{
	tilesRotate = newValue;
	[self needsRedraw];
}

-(void) setTilesCols:(int)newValue
{
	tilesCols = newValue;
	[self needsRedraw];
}

-(void) setTilesRows:(int)newValue
{
	tilesRows = newValue;
	[self needsRedraw];
}


#pragma mark - Memory management

-(id) initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        items = [[NSMutableArray alloc] init];
        
        delegate = nil;
        offset = CGPointMake(0, 0);
		relativeOffset = CGPointMake(0, 0);
        scale = 1;
        
        tilesSize.x = tilesSize.y = 1;
        tilesScale.x = tilesScale.y = 1;
		tilesAnchorPoint = CGPointMake(0, 0);
        tilesRotate = 0;
        tilesRows = 1;
        tilesCols = 1;
        
        selectedIndexes = [[NSMutableIndexSet alloc] init];
        
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    
    return self;
}

-(void) dealloc
{
    [items release];
    [selectedIndexes release];
    
    [super dealloc];
}


#pragma mark - Public methods

-(void) center
{
	const CGRect boundingBox = [self boundingBox];
	const CGRect bounds = [self bounds];
	
	offset.x = roundf(boundingBox.size.width * -0.5f - boundingBox.origin.x + bounds.size.width * 0.5f);
	offset.y = roundf(boundingBox.size.height * -0.5f - boundingBox.origin.y + bounds.size.height * 0.5f);
	
	[self updateRelativeOffset];
	[self needsRedraw];
}

-(void) addItemWithImage:(NSImage*)image
{
    GNPreviewItem* item = [[GNPreviewItem alloc] initWithImage:image];
    [items addObject:item];
	[item release];
    
    [self needsRedraw];
}

-(void) removeItemAtIndex:(NSUInteger)index
{
    [items removeObjectAtIndex:index];
    
    [selectedIndexes removeIndex:index];
    
    [self needsRedraw];
}

-(void) removeAll
{
    [items removeAllObjects];
    
    [selectedIndexes removeAllIndexes];
    
    [self needsRedraw];
}

-(void) setItemPosition:(NSUInteger)index x:(float)x y:(float)y
{
    GNPreviewItem* item = [items objectAtIndex:index];
    item.position = CGPointMake(x, y);
    
    [self needsRedraw];
}

-(void) setItemVisible:(NSUInteger)index visible:(BOOL)visible
{
    GNPreviewItem* item = [items objectAtIndex:index];
    item.visible = visible;
    
    [self needsRedraw];
}

-(void) setSelectedIndexes:(NSIndexSet*)indexes
{
    // Unselect old
    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx < items.count)
		{
            [[items objectAtIndex:idx] setSelected:NO];
		}
    }];
    
    [selectedIndexes removeAllIndexes];
    
    // Select new
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx < items.count)
        {
            [[items objectAtIndex:idx] setSelected:YES];
            [selectedIndexes addIndex:idx];
        }
    }];
    
    [self needsRedraw];
}


#pragma mark - Drawing code

-(void) setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    [self updateOffset];
}

-(void) drawRect:(NSRect)dirtyRect
{
	const CGRect bounds = [self bounds];
	
    CGSize size = bounds.size;
    CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSaveGState(c);
    
    CGContextScaleCTM(c, scale, scale);
    
    // draw checker
    const float checkerSize = 32;
    const float bx = fmodf(offset.x, checkerSize) - checkerSize;
    const float by = fmodf(offset.y, checkerSize) - checkerSize;
    const float ex = size.width / scale;
    const float ey = size.height / scale;
    int i = offset.x / checkerSize;
    
    CGContextSaveGState(c);
    for (float y = by; y < ey; y += checkerSize)
    {
        ++i;
        int k = offset.y / checkerSize;
        for (float x = bx; x < ex; x += checkerSize)
        {
            ++k;
            const float l = ((i + k) & 1) * 0.1f + 0.5f;
            CGContextSetRGBFillColor(c, l, l, l, 1);
            CGContextFillRect(c, CGRectMake (x, y, checkerSize, checkerSize));
        }
    }
    CGContextRestoreGState(c);
    
    
    // draw tiles grid
    const float tilesTotalWidth = tilesSize.x * tilesCols;
    const float tilesTotalHeight = tilesSize.y * tilesRows;
    
    CGContextSaveGState(c);
    CGContextTranslateCTM(c, offset.x, offset.y);
    CGContextScaleCTM(c, tilesScale.x, tilesScale.y);
    CGContextRotateCTM(c, -tilesRotate);
	CGContextTranslateCTM(c, -tilesTotalWidth * tilesAnchorPoint.x, -tilesTotalHeight * tilesAnchorPoint.y);
    
    CGContextSetRGBFillColor(c, 1, 0, 0, 0.5f);
    CGContextFillRect(c, CGRectMake(0, 0, tilesTotalWidth, tilesTotalHeight));
    
    CGContextSetRGBStrokeColor(c, 0, 0, 0, 0.5f);
    for (int i = 1; i < tilesRows; ++i)
    {
        const float tileOffset = i * tilesSize.y;
        CGContextMoveToPoint(c, 0, tileOffset);
        CGContextAddLineToPoint(c, tilesTotalWidth, tileOffset);
    }
    for (int i = 1; i < tilesCols; ++i)
    {
        const float tileOffset = i * tilesSize.x;
        CGContextMoveToPoint(c, tileOffset, 0);
        CGContextAddLineToPoint(c, tileOffset, tilesTotalHeight);
    }
    CGContextMoveToPoint(c, 0, 0);
    CGContextAddLineToPoint(c, tilesTotalWidth, 0);
    CGContextAddLineToPoint(c, tilesTotalWidth, tilesTotalHeight);
    CGContextAddLineToPoint(c, 0, tilesTotalHeight);
    CGContextAddLineToPoint(c, 0, 0);
    CGContextStrokePath(c);
    
    CGContextRestoreGState(c);
	
	
	// draw anchor point guidline
	CGContextSaveGState(c);
	CGContextSetRGBFillColor(c, 0, 0, 0, 1.0f);
	CGContextMoveToPoint(c, offset.x - 10, offset.y);
	CGContextAddLineToPoint(c, offset.x + 10, offset.y);
	CGContextMoveToPoint(c, offset.x, offset.y - 10);
	CGContextAddLineToPoint(c, offset.x, offset.y + 10);
	CGContextStrokePath(c);
	CGContextRestoreGState(c);
	
    
    
    // draw items
    CGContextSetRGBStrokeColor(c, 1, 1, 0, 0.5f);
    CGContextSetLineWidth(c, 5 / scale);
    for (GNPreviewItem* item in items)
    {
        if (item.visible)
        {
            NSImage* image = item.image;
            CGPoint itemPosition = item.position;
            CGSize imageSize = image.size;
            
            CGRect srcRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
            CGRect dstRect = CGRectMake(offset.x + itemPosition.x, offset.y + itemPosition.y, imageSize.width, imageSize.height);
            
            // draw highlight
            if (item.selected)
            {
                CGContextAddRect(c, dstRect);
                CGContextStrokePath(c);
            }
            
            // draw image
            [image drawInRect:dstRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1];
        }
    }
    
    CGContextRestoreGState(c);
}


#pragma mark - Events handling

-(void) mouseDown:(NSEvent*)event
{
    CGPoint point = [event locationInWindow];
    
    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        GNPreviewItem* item = [items objectAtIndex:idx];
        CGPoint position = item.position;
        item.dragOffset = CGPointMake(point.x - position.x * scale,
                                      point.y - position.y * scale);
    }];
}

-(void) mouseUp:(NSEvent*)event
{
    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        GNPreviewItem* item = [items objectAtIndex:idx];
        
        if (item.visible)
        {
            CGSize imageSize = item.image.size;
            CGPoint position = item.position;
            CGPoint anchor;
            
            anchor.x = -position.x / imageSize.width;
            anchor.y = -position.y / imageSize.height;
            
            [delegate handleDataItemWasChanged:idx x:position.x y:position.y anchor:anchor];
        }
    }];
}

-(void) mouseDragged:(NSEvent*)event
{
    CGPoint point = [event locationInWindow];
    
    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        GNPreviewItem* item = [items objectAtIndex:idx];
        CGPoint itemDragOffset = item.dragOffset;
        item.position = CGPointMake(roundf((point.x - itemDragOffset.x) / scale),
                                    roundf((point.y - itemDragOffset.y) / scale));
    }];
    
    [self needsRedraw];
}

-(void) otherMouseDown:(NSEvent*)event
{
    CGPoint point = [event locationInWindow];
    
    dragOffset.x = point.x - offset.x * scale;
    dragOffset.y = point.y - offset.y * scale;
}

-(void) otherMouseDragged:(NSEvent*)event
{
    CGPoint point = [event locationInWindow];
    
    offset.x = roundf(point.x - dragOffset.x) / scale;
    offset.y = roundf(point.y - dragOffset.y) / scale;
	
	[self updateRelativeOffset];
    [self needsRedraw];
}

-(void) otherMouseUp:(NSEvent*)event
{}

//- (void)mouseDown:(NSEvent *)theEvent;
//- (void)rightMouseDown:(NSEvent *)theEvent;
//- (void)otherMouseDown:(NSEvent *)theEvent;
//- (void)mouseUp:(NSEvent *)theEvent;
//- (void)rightMouseUp:(NSEvent *)theEvent;
//- (void)otherMouseUp:(NSEvent *)theEvent;
//- (void)mouseMoved:(NSEvent *)theEvent;


#pragma mark - Drag & drop support

-(NSDragOperation) draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationLink;
}

-(BOOL) performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard* pasteboard = sender.draggingPasteboard;
    NSArray* files = [pasteboard propertyListForType:NSFilenamesPboardType];
    
    [delegate handleDropedFilesList:files];
    
    return YES;
}


#pragma mark - Private methods

-(void) needsRedraw
{
    [self setNeedsDisplayInRect:self.bounds];
}

-(CGRect) boundingBox
{
	const CGFloat w = tilesSize.x * tilesCols;
	const CGFloat h = tilesSize.y * tilesRows;
	
	CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformMakeRotation(-tilesRotate),
												  CGAffineTransformMakeScale(tilesScale.x, tilesScale.y));
	m = CGAffineTransformTranslate(m, -w * tilesAnchorPoint.x, -h * tilesAnchorPoint.y);
	
	const CGPoint a = CGPointApplyAffineTransform(CGPointMake(0, 0), m);
	const CGPoint b = CGPointApplyAffineTransform(CGPointMake(w, 0), m);
	const CGPoint c = CGPointApplyAffineTransform(CGPointMake(w, h), m);
	const CGPoint d = CGPointApplyAffineTransform(CGPointMake(0, h), m);
	
	const float bx = fminf(fminf(fminf(a.x, b.x), c.x), d.x);
	const float by = fminf(fminf(fminf(a.y, b.y), c.y), d.y);
	const float ex = fmaxf(fmaxf(fmaxf(a.x, b.x), c.x), d.x);
	const float ey = fmaxf(fmaxf(fmaxf(a.y, b.y), c.y), d.y);
	
	return CGRectMake(bx, by, ex - bx, ey - by);
}

-(void) updateRelativeOffset
{
	const CGRect boundingBox = [self boundingBox];
	const CGRect bounds = [self bounds];
	
	relativeOffset.x = (offset.x + boundingBox.origin.x + boundingBox.size.width * 0.5f) * scale / bounds.size.width;
	relativeOffset.y = (offset.y + boundingBox.origin.y + boundingBox.size.height * 0.5f) * scale / bounds.size.height;
}

-(void) updateOffset
{
	const CGRect boundingBox = [self boundingBox];
	const CGRect bounds = [self bounds];
	
	offset.x = roundf(relativeOffset.x / scale * bounds.size.width - boundingBox.origin.x - boundingBox.size.width * 0.5f);
	offset.y = roundf(relativeOffset.y / scale * bounds.size.height - boundingBox.origin.y - boundingBox.size.height * 0.5f);
}

@end
