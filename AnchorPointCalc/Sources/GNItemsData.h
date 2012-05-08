//
//  GNItemsData.h
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 21.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import "GNItemsDataItem.h"


@interface GNItemsData : NSObject <NSCoding, NSTableViewDataSource>
{
    NSMutableArray* data;
    BOOL wasChanged;
}

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, assign) BOOL wasChanged;

-(id) initWithArray:(NSArray*)array;
-(id) initWithArray:(NSArray *)array withPathsRelativeTo:(NSString*)path;

-(NSArray*) toArray;
-(NSArray*) toArrayWithPathsRelativeTo:(NSString*)path;

-(id) initWithFile:(NSString*)file error:(NSError**)error;
-(void) writeToFile:(NSString*)file error:(NSError**)error;

-(void) addItem:(GNItemsDataItem*)item;
-(GNItemsDataItem*) itemAtIndex:(NSUInteger)index;
-(void) removeItemAtIndex:(NSUInteger)index;
-(void) removeAll;
-(void) enumerateItemsWithBlock:(void(^)(GNItemsDataItem*,int idx,BOOL* stop))block;

@end
