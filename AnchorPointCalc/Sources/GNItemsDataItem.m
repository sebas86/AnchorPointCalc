//
//  GNItemsDataItem.m
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 21.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import "GNItemsDataItem.h"
#import "NSString+RelativePath.h"


@implementation GNItemsDataItem

@synthesize name;
@synthesize path;
@synthesize x;
@synthesize y;
@synthesize anchor;
@synthesize imageSize;
@synthesize visible;

-(id) init
{
    if ((self = [super init]))
    {
        name = nil;
        path = nil;
        x = y = 0;
        anchor = CGPointMake(0, 0);
        imageSize = CGSizeMake(0, 0);
        visible = YES;
    }
    return self;
}

-(id) initWithDictionary:(NSDictionary*)dict
{
    return [self initWithDictionary:dict relativeToPath:nil];
}

-(id) initWithDictionary:(NSDictionary *)dict relativeToPath:(NSString*)basePath
{
    if ((self = [self init]))
    {
        // Obtain properties
        NSString* dName = [dict objectForKey:@"name"];
        NSString* dPath = [dict objectForKey:@"path"];
        NSNumber* dX = [dict objectForKey:@"x"];
        NSNumber* dY = [dict objectForKey:@"y"];
        NSNumber* dAX = [dict objectForKey:@"anchorX"];
        NSNumber* dAY = [dict objectForKey:@"anchorY"];
        NSNumber* dVisible = [dict objectForKey:@"visible"];
        
        // Check integrity
        if ( ! ([dName isKindOfClass:[NSString class]] &&
                [dPath isKindOfClass:[NSString class]] &&
                [dX isKindOfClass:[NSNumber class]] &&
                [dY isKindOfClass:[NSNumber class]] &&
                [dAX isKindOfClass:[NSNumber class]] &&
                [dAY isKindOfClass:[NSNumber class]] &&
                [dVisible isKindOfClass:[NSNumber class]]))
        {
            [self release];
            return nil;
        }
        
        // Set values
        name = [dName retain];
        if (basePath)
            path = [[dPath absolutePathFromBaseDirPath:[basePath stringByDeletingLastPathComponent]] retain];
        else
            path = [dPath retain];
        
        
        NSLog(@"basePath: %@, path: %@, relative: %@", basePath, path, dPath);
        
        x = [dX floatValue];
        y = [dY floatValue];
        anchor = CGPointMake([dAX floatValue], [dAY floatValue]);
        visible = [dVisible boolValue];
    }
    return self;
}

-(NSDictionary*) toDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            name, @"name",
            path, @"path",
            [NSNumber numberWithFloat:x], @"x",
            [NSNumber numberWithFloat:y], @"y",
            [NSNumber numberWithFloat:anchor.x], @"anchorX",
            [NSNumber numberWithFloat:anchor.y], @"anchorY",
            [NSNumber numberWithBool:visible], @"visible",
            nil];
}

-(NSDictionary*) toDictionaryWithPathRelativeTo:(NSString*)basePath
{
    NSString* relativePath = [path relativePathFromBaseDirPath:[basePath stringByDeletingLastPathComponent]];
    
    NSLog(@"basePath: %@, path: %@, relative: %@", basePath, path, relativePath);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            name, @"name",
            relativePath, @"path",
            [NSNumber numberWithFloat:x], @"x",
            [NSNumber numberWithFloat:y], @"y",
            [NSNumber numberWithFloat:anchor.x], @"anchorX",
            [NSNumber numberWithFloat:anchor.y], @"anchorY",
            [NSNumber numberWithBool:visible], @"visible",
            nil];
}

-(void) dealloc
{
    [name release];
    [path release];
    
    [super dealloc];
}

@end
