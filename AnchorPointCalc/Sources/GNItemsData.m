//
//  GNItemsData.m
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 21.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import "GNItemsData.h"

@implementation GNItemsData

#pragma mark - Properties

-(NSUInteger) count
{
    return data.count;
}

@synthesize wasChanged;


#pragma mark - Memory management

-(id) init
{
    if ((self = [super init]))
    {
        data = [[NSMutableArray alloc] init];
        wasChanged = NO;
    }
    return self;
}

-(id) initWithArray:(NSArray*)array
{
    return [self initWithArray:array withPathsRelativeTo:nil];
}

-(id) initWithArray:(NSArray *)array withPathsRelativeTo:(NSString*)path
{
    if ((self = [super init]))
    {
        if ([array isKindOfClass:[NSArray class]])
        {
            data = [[NSMutableArray alloc] initWithCapacity:array.count];
            
            for (NSDictionary* dict in array)
            {
                if ([dict isKindOfClass:[NSDictionary class]])
                {
                    GNItemsDataItem* item = [[GNItemsDataItem alloc] initWithDictionary:dict relativeToPath:path];
                    if (item)
                    {
                        [data addObject:item];
                        [item release];
                    }
                }
            }
        }
        else
        {
            data = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

-(NSArray*) toArrayWithPathsRelativeTo:(NSString*)path
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:data.count];
    for (GNItemsDataItem* item in data)
    {
        [array addObject:[item toDictionaryWithPathRelativeTo:path]];
    }
    return array;
}

-(NSArray*) toArray
{
    return [self toArrayWithPathsRelativeTo:nil];
}

-(void) encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:data forKey:@"data"];
}

-(id) initWithCoder:(NSCoder*)aDecoder
{
    if ((self = [super init]))
    {
        data = nil;
        
        // Decode data
        NSArray* decodedArray = [aDecoder decodeObjectForKey:@"data"];
        
        // Check data integrity
        if ([data isKindOfClass:[NSArray class]])
        {
            data = [[NSMutableArray alloc] initWithCapacity:decodedArray.count];
            
            for (NSUInteger i = 0; i < data.count; ++i)
            {
                id object = [data objectAtIndex:i];
                
                if ([object isKindOfClass:[GNItemsDataItem class]])
                {
                    [data addObject:object]; 
                }
            }
        }
    }
    return self;
}

-(void) writeToFile:(NSString*)file error:(NSError**)error
{
    // TODO: write data to file
}

-(id)initWithFile:(NSString*)file error:(NSError**)error
{
    if ((self = [super init]))
    {
        data = nil;
        // TODO: read data from file
    }
    return self;
}

-(void) dealloc
{
    [data release];
    [super dealloc];
}


#pragma mark - Public methods

-(void) addItem:(GNItemsDataItem*)item
{
    [data addObject:item];
	wasChanged = YES;
}

-(GNItemsDataItem*) itemAtIndex:(NSUInteger)index
{
    return [data objectAtIndex:index];
}

-(void) removeItemAtIndex:(NSUInteger)index
{
    [data removeObjectAtIndex:index];
	wasChanged = YES;
}

-(void) removeAll
{
    [data removeAllObjects];
	wasChanged = YES;
}

-(void) enumerateItemsWithBlock:(void(^)(GNItemsDataItem*item,NSUInteger idx,BOOL* stop))block
{
    BOOL stop = NO;
    for (NSUInteger i = 0; i < data.count && ! stop; ++i)
    {
        block([data objectAtIndex:i], i, &stop);
    }
}


#pragma mark - NSTableViewDataSource implementation

-(NSInteger) numberOfRowsInTableView:(NSTableView*)tableView
{
    return data.count;
}

-(id) tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row
{
    NSString* identifier = tableColumn.identifier;
    
    id value = nil;
    
    if (row >= 0 && row < data.count)
    {
        GNItemsDataItem* item = [data objectAtIndex:row];
        
        if ([identifier isEqualToString:@"visible"])
        {
            value = [NSNumber numberWithBool:item.visible];
        }
        else if ([identifier isEqualToString:@"name"])
        {
            value = item.name;
        }
        else if ([identifier isEqualToString:@"path"])
        {
            value = item.path;
        }
        else if ([identifier isEqualToString:@"x"])
        {
            value = [NSNumber numberWithFloat:item.x];
        }
        else if ([identifier isEqualToString:@"y"])
        {
            value = [NSNumber numberWithFloat:item.y];
        }
        else
        {
            NSAssert(NO, @"Unsupported column '%@'.", identifier);
        }
    }
    
    return value;
}

-(void) tableView:(NSTableView*)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row
{
    NSString* identifier = tableColumn.identifier;
    
    if (row >= 0 && row < data.count)
    {
        GNItemsDataItem* item = [data objectAtIndex:row];
        
        if ([identifier isEqualToString:@"visible"])
        {
            if (item.visible != [object boolValue])
            {
                wasChanged = YES;
                item.visible = [object boolValue];
            }
        }
        else if ([identifier isEqualToString:@"name"])
        {
            if ( ! [item.name isEqualToString:object])
            {
                wasChanged = YES;
                item.name = object;
            }
        }
        else if ([identifier isEqualToString:@"path"])
        {
            if ([item.path isEqualToString:object])
            {
                wasChanged = YES;
                item.path = object;
            }
        }
        else if ([identifier isEqualToString:@"x"])
        {
            if (item.x != [object floatValue])
            {
                wasChanged = YES;
                item.x = [object floatValue];
                item.anchor = CGPointMake(-item.x / item.imageSize.width, item.anchor.y);
            }
        }
        else if ([identifier isEqualToString:@"y"])
        {
            if (item.y != [object floatValue])
            {
                wasChanged = YES;
                item.y = [object floatValue];
                item.anchor = CGPointMake(item.anchor.x, -item.y / item.imageSize.height);
            }
        }
        else
        {
            NSAssert(NO, @"Unsupported column '%@'.", identifier);
        }
    }
}

@end
