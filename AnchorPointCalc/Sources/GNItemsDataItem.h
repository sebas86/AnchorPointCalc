//
//  GNItemsDataItem.h
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 21.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GNItemsDataItem : NSObject
{
    NSString* name;
    NSString* path;
    float x, y;
    CGPoint anchor;
    CGSize imageSize;
    BOOL visible;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* path;
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) CGPoint anchor;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL visible;

-(id) initWithDictionary:(NSDictionary*)dict;
-(id) initWithDictionary:(NSDictionary *)dict relativeToPath:(NSString*)path;

-(NSDictionary*) toDictionary;
-(NSDictionary*) toDictionaryWithPathRelativeTo:(NSString*)path;

@end
