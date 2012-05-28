//
//  GNAppDelegate.m
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 20.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import "CJSONSerializer.h"
#import "GNAppDelegate.h"
#import "NSImage+Extension.h"


@interface GNAppDelegate ()
-(BOOL) canSaflyCloseCurrentProject;
-(void) openProjectFile:(NSString*)path;
-(void) saveProjectFile:(NSString*)path;
-(void) closeProject;
-(void) setDefault;
@end


@implementation GNAppDelegate

@synthesize currentProjectPath;
@synthesize window;
@synthesize preview;
@synthesize items;
@synthesize scaleSlider;
@synthesize scaleText;
@synthesize removeButton;
@synthesize cleanButton;
@synthesize tilesRows;
@synthesize tilesCols;
@synthesize tilesScaleX;
@synthesize tilesScaleY;
@synthesize tilesAnchorX;
@synthesize tilesAnchorY;
@synthesize tilesRotate;
@synthesize openRecentItems;
@synthesize clearRecentItems;
@synthesize tileHeight;
@synthesize tileWidth;

-(void) setCurrentProjectPath:(NSString *)value
{
    if (value != currentProjectPath)
    {
        [currentProjectPath release];
        currentProjectPath = [value retain];
		
		NSString* newTitle;
		if (currentProjectPath)
		{
			newTitle = [orgWindowTitle stringByAppendingFormat:@" (%@)", currentProjectPath];
		}
		else
		{
			newTitle = orgWindowTitle;
		}
		[[self window] setTitle:newTitle];
    }
}

-(void) dealloc
{
    [super dealloc];
}

-(void) applicationDidFinishLaunching:(NSNotification*)aNotification
{
    [NSImage setIgnoreDPI:YES];
    
	orgWindowTitle = [[[self window] title] retain];
	
    itemsData = [[GNItemsData alloc] init];
    itemsTableView = [items documentView];
    [itemsTableView setDataSource:itemsData];
    itemsTableView.delegate = self;
    
    [self setDefault];
    
    // Images loading dialog
    imagesOpenPanel = [[NSOpenPanel alloc] init];
    [imagesOpenPanel setCanChooseFiles:YES];
    [imagesOpenPanel setCanChooseDirectories:NO];
    [imagesOpenPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"png", @"jpg", @"jpeg", @"gif", @"bmp", nil]];
    [imagesOpenPanel setAllowsMultipleSelection:YES];
    [imagesOpenPanel setAllowsOtherFileTypes:NO];
    
    // JSON export dialog
    exportPanel = [[NSSavePanel alloc] init];
    [exportPanel setAllowedFileTypes:[NSArray arrayWithObject:@"json"]];
    
    // Project loading dialog
    openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"apc", nil]];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowsOtherFileTypes:NO];
    
    // Project save dialog
    savePanel = [[NSSavePanel alloc] init];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"apc"]];
}

-(void) applicationWillTerminate:(NSNotification*)notification
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[itemsData toArray] forKey:@"data"];
    [userDefaults setObject:[NSNumber numberWithFloat:preview.tilesSize.x] forKey:@"tileWidth"];
    [userDefaults setObject:[NSNumber numberWithFloat:preview.tilesSize.y] forKey:@"tileHeight"];
    [userDefaults setObject:[NSNumber numberWithFloat:preview.tilesRows] forKey:@"tilesRows"];
    [userDefaults setObject:[NSNumber numberWithFloat:preview.tilesCols] forKey:@"tilesCols"];
	[userDefaults setObject:[NSNumber numberWithFloat:preview.tilesScale.x] forKey:@"tilesScaleX"];
	[userDefaults setObject:[NSNumber numberWithFloat:preview.tilesScale.y] forKey:@"tilesScaleY"];
	[userDefaults setObject:[NSNumber numberWithFloat:preview.tilesRotate] forKey:@"tilesRotate"];
	[userDefaults setObject:[NSNumber numberWithFloat:preview.tilesAnchorPoint.x] forKey:@"tilesAnchorPointX"];
	[userDefaults setObject:[NSNumber numberWithFloat:preview.tilesAnchorPoint.y] forKey:@"tilesAnchorPointY"];
    
	[orgWindowTitle release];
	
    [imagesOpenPanel release];
    [exportPanel release];
    [openPanel release];
    [savePanel release];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(IBAction) updateScaleWithSlider:(id)sender
{
    const float scale = 0.5f + roundf(self.scaleSlider.floatValue) / 100.0f;
    [self.scaleText setFloatValue:scale];
    
    preview.scale = scale;
}

-(IBAction) updateScaleWithText:(id)sender
{
	const float minValue = 0.5f + [self.scaleSlider minValue] / 100.0f;
	const float maxValue = 0.5f + [self.scaleSlider maxValue] / 100.0f;
    float scale = self.scaleText.floatValue;
    
    if (scale < minValue)
        scale = minValue;
    else if (scale > maxValue)
        scale = maxValue;
    
    const int sliderValue = (scale - 0.5f) * 100;
    [self.scaleSlider setIntValue:sliderValue];
    [self.scaleSlider updateTrackingAreas];
    [self.scaleText setFloatValue:scale];
    
    preview.scale = scale;
}


#pragma mark - NSApplicationDelegate implementation

-(void) tableViewSelectionIsChanging:(NSNotification *)notification
{
    BOOL anyItemSelected = [itemsTableView selectedRow] >= 0;
    [removeButton setEnabled:anyItemSelected];
    [cleanButton setEnabled:anyItemSelected];
    
    NSIndexSet* selectedIndexes = [itemsTableView selectedRowIndexes];
    [preview setSelectedIndexes:selectedIndexes];
}


#pragma mark - NSWindowDelegate implementation

-(BOOL) windowShouldClose:(id)sender
{
	return [self canSaflyCloseCurrentProject];
}

#pragma mark - GNPreviewDelegate implementation

-(void) handleDropedFilesList:(NSArray*)list
{
	BOOL anyImageWasAdded = NO;
	
	NSMutableArray* invalidFiles = nil;
    for (NSString* path in list)
    {
        NSImage* image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
        
        if (image)
        {
            GNItemsDataItem* item = [[[GNItemsDataItem alloc] init] autorelease];
            
            item.visible = YES;
            item.name = [[path lastPathComponent] stringByDeletingPathExtension];
            item.path = path;
            item.x = 0;
            item.y = 0;
            item.imageSize = image.size;
            
            [itemsData addItem:item];
            [preview addItemWithImage:image];
			
			anyImageWasAdded = YES;
        }
        else
        {
			if ( ! invalidFiles)
			{
				invalidFiles = [NSMutableArray array];
			}
			
			[invalidFiles addObject:path];
        }
    }
    
	itemsData.wasChanged |= anyImageWasAdded;
	
    [itemsTableView reloadData];
	
	if (invalidFiles)
	{
		// TODO: display alert with list of invalid files
	}
}

-(void) handleDataItemWasChanged:(NSUInteger)index x:(float)x y:(float)y anchor:(CGPoint)anchor
{
    GNItemsDataItem* item = [itemsData itemAtIndex:index];
    NSAssert(item, @"Item at index %d not exits.", index);
    
	if (item.x != x || item.y != y || item.anchor.x != anchor.x || item.anchor.y != anchor.y)
	{
		item.x = x;
		item.y = y;
		item.anchor = anchor;
		
		itemsData.wasChanged = YES;
		
		[itemsTableView reloadData];
	}
}

-(IBAction) setVisible:(id)sender
{
    [itemsTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        GNItemsDataItem* item = [itemsData itemAtIndex:idx];
		if ( ! item.visible)
		{
			item.visible = YES;
			itemsData.wasChanged = YES;
		}
        [preview setItemVisible:idx visible:YES];
    }];
    
    [itemsTableView reloadData];
}

-(IBAction) setInvisible:(id)sender
{
    [itemsTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        GNItemsDataItem* item = [itemsData itemAtIndex:idx];
		if (item.visible)
		{
			item.visible = NO;
			itemsData.wasChanged = YES;
		}
        [preview setItemVisible:idx visible:NO];
    }];
	
	itemsData.wasChanged = YES;
    
    [itemsTableView reloadData];
}

-(IBAction) addImage:(id)sender
{
    if ([imagesOpenPanel runModal])
    {
        NSArray* URLs = [imagesOpenPanel URLs];
        NSMutableArray* paths = [[NSMutableArray alloc] initWithCapacity:URLs.count];
        
        [URLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURL* URL = obj;
            [paths addObject:[URL path]];
        }];
        
        [self handleDropedFilesList:paths];
        [paths release];
    }
}

-(IBAction) removeImage:(id)sender
{
    NSAlert* alert = [NSAlert alertWithMessageText:@"Removing selected items..." defaultButton:@"Yes"
                                   alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"Are you sure?"];
    [alert setIcon:[NSImage imageNamed:@"question.png"]];
    
    NSInteger value = [alert runModal];
    
    if (value)
    {
        [[itemsTableView selectedRowIndexes] enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop) {
            [itemsData removeItemAtIndex:idx];
            [preview removeItemAtIndex:idx];
        }];
        [itemsTableView reloadData];
        
        itemsData.wasChanged = YES;
    }
}

-(IBAction) cleanInvalid:(id)sender
{
    // TODO: remove all invalid images
}

-(void) updateProperties
{
	self.tileWidth.floatValue = preview.tilesSize.x;
	self.tileHeight.floatValue = preview.tilesSize.y;
	self.tilesRows.intValue = preview.tilesRows;
	self.tilesCols.intValue = preview.tilesCols;
	self.tilesScaleX.floatValue = preview.tilesScale.x;
	self.tilesScaleY.floatValue = preview.tilesScale.y;
	self.tilesAnchorX.floatValue = preview.tilesAnchorPoint.x;
	self.tilesAnchorY.floatValue = preview.tilesAnchorPoint.y;
	self.tilesRotate.floatValue = preview.tilesRotate * 180.0f / M_PI;
	
	[self.scaleSlider setFloatValue:(preview.scale - 0.5f) * 100.0f];
	[self.scaleText setFloatValue:preview.scale];
}

-(IBAction) setWidth:(id)sender
{
	const float newValue = [[sender stringValue] floatValue];
	if (preview.tilesSize.x != newValue)
	{
		preview.tilesSize = CGPointMake(newValue, preview.tilesSize.y);
		itemsData.wasChanged = YES;
	}
}

-(IBAction) setHeight:(id)sender
{
	const float newValue = [sender floatValue];
	if (preview.tilesSize.y != newValue)
	{
		preview.tilesSize = CGPointMake(preview.tilesSize.x, newValue);
		itemsData.wasChanged = YES;
	}
}

-(IBAction) setRows:(id)sender
{
	const int newValue = [sender intValue];
	if (preview.tilesRows != newValue)
	{
		preview.tilesRows = newValue;
		itemsData.wasChanged = YES;
	}
}

-(IBAction) setCols:(id)sender
{
	const int newValue = [sender intValue];
	if (preview.tilesCols != newValue)
	{
		preview.tilesCols = newValue;
		itemsData.wasChanged = YES;
	}
}

-(IBAction) setScaleX:(id)sender
{
	const float newValue = [sender floatValue];
	if (preview.tilesScale.x != newValue)
	{
		preview.tilesScale = CGPointMake(newValue, preview.tilesScale.y);
		itemsData.wasChanged = YES;
	}
}

-(IBAction) setScaleY:(id)sender
{
	const float newValue = [sender floatValue];
	if (preview.tilesScale.y != newValue)
	{
		preview.tilesScale = CGPointMake(preview.tilesScale.x, newValue);
		itemsData.wasChanged = YES;
	}
}

-(IBAction) setAnchorPointX:(id)sender
{
	const float newValue = [sender floatValue];
	if (preview.tilesAnchorPoint.x != newValue)
	{
		preview.tilesAnchorPoint = CGPointMake(newValue, preview.tilesAnchorPoint.y);
		itemsData.wasChanged = YES;
	}
}

-(IBAction) setAnchorPointY:(id)sender
{
	const float newValue = [sender floatValue];
	if (preview.tilesAnchorPoint.y != newValue)
	{
		preview.tilesAnchorPoint = CGPointMake(preview.tilesAnchorPoint.x, newValue);
		itemsData.wasChanged = YES;
	}
}

-(IBAction) setRotate:(id)sender
{
	const float newValue = [sender floatValue] * M_PI / 180.0f;
	if (preview.tilesRotate != newValue)
	{
		preview.tilesRotate = newValue;
		itemsData.wasChanged = YES;
	}
}

- (IBAction)dataWasChanged:(id)sender
{
    [itemsData enumerateItemsWithBlock:^(GNItemsDataItem* item, NSUInteger idx, BOOL *stop) {
        [preview setItemPosition:idx x:item.x y:item.y];
        [preview setItemVisible:idx visible:item.visible];
    }];
}

-(IBAction) openProject:(id)sender
{
	if ([self canSaflyCloseCurrentProject])
	{
		if ([openPanel runModal])
		{
			[self openProjectFile:[openPanel.URL path]];
		}
	}
}

-(IBAction) saveProject:(id)sender
{
    if (currentProjectPath)
    {
        [self saveProjectFile:currentProjectPath];
    }
    else
    {
        [self saveAsProject:sender];
    }
}

-(IBAction) saveAsProject:(id)sender
{
    if ([savePanel runModal])
    {
        [self saveProjectFile:[savePanel.URL path]];
    }
}

-(IBAction) clearOpenRecentMenu:(id)sender
{
    NSMenu* submenu = [openRecentItems submenu];
    
    for (NSUInteger i = submenu.numberOfItems - 1; i > 0; --i)
    {
        [submenu removeItemAtIndex:i];
    }
}

-(IBAction)selectAll:(id)sender
{
    if (itemsTableView.selectedRowIndexes.count == itemsData.count)
    {
        [itemsTableView deselectAll:sender];
        [preview setSelectedIndexes:nil];
    }
    else
    {
        [itemsTableView selectAll:sender];
        [preview setSelectedIndexes:itemsTableView.selectedRowIndexes];
    }
}

-(IBAction) exportJSON:(id)sender
{
    if ([exportPanel runModal])
    {
        NSString* path = [[exportPanel URL] path];
        CJSONSerializer* serializer = [CJSONSerializer serializer];
        NSMutableDictionary* assets = [NSMutableDictionary dictionary];
        
        [itemsData enumerateItemsWithBlock:^(GNItemsDataItem* item, NSUInteger idx, BOOL *stop) {
            NSArray* anchor = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:item.anchor.x],
                               [NSNumber numberWithFloat:item.anchor.y],
                               nil];
            
            NSDictionary* itemDesc = [NSDictionary dictionaryWithObjectsAndKeys:
                                      anchor, @"anchor",
                                      nil];
            
            [assets setObject:itemDesc forKey:item.name];
        }];
        
        NSError* error = nil;
        NSData* data = [serializer serializeDictionary:assets error:&error];
        
        [data writeToFile:path atomically:YES];
    }
}

-(IBAction) closeCurrent:(id)sender
{
    if ([self canSaflyCloseCurrentProject])
    {
		[self closeProject];
	}
}

-(IBAction) quit:(id)sender
{
	if ([self canSaflyCloseCurrentProject])
	{
		exit(0);
	}
}


#pragma mark - Private methods

-(BOOL) canSaflyCloseCurrentProject
{
	if (itemsData.wasChanged)
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Current project was changed." defaultButton:@"Save changes"
                                       alternateButton:@"Ignore changes" otherButton:@"Cancel" informativeTextWithFormat:@"Do you realy want close them without save? Unsaved changes will lost."];
        [alert setIcon:[NSImage imageNamed:@"question.png"]];
        
        switch ([alert runModal])
		{
			case NSAlertOtherReturn:
				return NO;
				
			case NSAlertDefaultReturn:
				if (currentProjectPath)
				{
					[self saveProjectFile:currentProjectPath];
					
				}
				else if ([savePanel runModal])
				{
					[self saveProjectFile:[savePanel.URL path]];
				}
				else
				{
					return NO;
				}
				break;
				
			case NSAlertAlternateReturn:
				break;
		}
    }
	
	return YES;
}

-(void) openProjectFile:(NSString*)path
{
	[self closeProject];
	
    NSDictionary* project = [NSDictionary dictionaryWithContentsOfFile:path];
    
	[itemsData release];
    itemsData = [[GNItemsData alloc] initWithArray:[project objectForKey:@"data"] withPathsRelativeTo:path];
    
    itemsTableView = [items documentView];
    [itemsTableView setDataSource:itemsData];
    itemsTableView.delegate = self;
    
    [itemsTableView reloadData];
    
    NSNumber* dTileWidth = [project objectForKey:@"tileWidth"];
    NSNumber* dTileHeight = [project objectForKey:@"tileHeight"];
    NSNumber* dTilesRows = [project objectForKey:@"tilesRows"];
    NSNumber* dTilesCols = [project objectForKey:@"tilesCols"];
    NSNumber* dTilesRotate = [project objectForKey:@"tilesRotate"];
    NSNumber* dTilesScaleX = [project objectForKey:@"tilesScaleX"];
    NSNumber* dTilesScaleY = [project objectForKey:@"tilesScaleY"];
	NSNumber* dTilesAnchorPointX = [project objectForKey:@"tilesAnchorPointX"];
	NSNumber* dTilesAnchorPointY = [project objectForKey:@"tilesAnchorPointY"];
	
    if ([dTileWidth isKindOfClass:[NSNumber class]] && [dTileHeight isKindOfClass:[NSNumber class]])
    {
        preview.tilesSize = CGPointMake([dTileWidth floatValue], [dTileHeight floatValue]);
    }
    
    if ([dTilesRows isKindOfClass:[NSNumber class]] && [dTilesCols isKindOfClass:[NSNumber class]])
    {
        preview.tilesRows = [dTilesRows intValue];
        preview.tilesCols = [dTilesCols intValue];
    }
    
    if ([dTilesRotate isKindOfClass:[NSNumber class]])
    {
        preview.tilesRotate = [dTilesRotate floatValue];
    }
    
    if ([dTilesScaleX isKindOfClass:[NSNumber class]] && [dTilesScaleY isKindOfClass:[NSNumber class]])
    {
        preview.tilesScale = CGPointMake([dTilesScaleX floatValue], [dTilesScaleY floatValue]);
    }
	
	if ([dTilesAnchorPointX isKindOfClass:[NSNumber class]] && [dTilesAnchorPointY isKindOfClass:[NSNumber class]])
    {
        preview.tilesAnchorPoint = CGPointMake([dTilesAnchorPointX floatValue], [dTilesAnchorPointY floatValue]);
    }
    
        
    [preview removeAll];
    [itemsData enumerateItemsWithBlock:^(GNItemsDataItem* item, NSUInteger idx, BOOL *stop) {
        NSImage* image = [[NSImage alloc] initWithContentsOfFile:item.path];
        
        item.imageSize = image.size;
        
        [preview addItemWithImage:image];
        [preview setItemPosition:idx x:item.x y:item.y];
        [preview setItemVisible:idx visible:item.visible];
		
		[image release];
    }];
    
	[self updateProperties];
    
    self.currentProjectPath = path;
}

-(void) saveProjectFile:(NSString*)path
{
    NSMutableDictionary* project = [NSMutableDictionary dictionaryWithCapacity:5];
    
    [project setObject:[itemsData toArrayWithPathsRelativeTo:path] forKey:@"data"];
    [project setObject:[NSNumber numberWithFloat:preview.tilesSize.x] forKey:@"tileWidth"];
    [project setObject:[NSNumber numberWithFloat:preview.tilesSize.y] forKey:@"tileHeight"];
    [project setObject:[NSNumber numberWithFloat:preview.tilesRows] forKey:@"tilesRows"];
    [project setObject:[NSNumber numberWithFloat:preview.tilesCols] forKey:@"tilesCols"];
	[project setObject:[NSNumber numberWithFloat:preview.tilesScale.x] forKey:@"tilesScaleX"];
	[project setObject:[NSNumber numberWithFloat:preview.tilesScale.y] forKey:@"tilesScaleY"];
	[project setObject:[NSNumber numberWithFloat:preview.tilesAnchorPoint.x] forKey:@"tilesAnchorPointX"];
	[project setObject:[NSNumber numberWithFloat:preview.tilesAnchorPoint.y] forKey:@"tilesAnchorPointY"];
	[project setObject:[NSNumber numberWithFloat:preview.tilesRotate] forKey:@"tilesRotate"];
    
    if ([project writeToFile:path atomically:YES])
	{
		self.currentProjectPath = path;
		itemsData.wasChanged = NO;
	}
}

-(void) closeProject
{
	[preview removeAll];
	[itemsData removeAll];
	itemsData.wasChanged = NO;
	
	[itemsTableView reloadData];
	
	self.currentProjectPath = nil;
	
	[self setDefault];
}

-(void) setDefault
{
	self.currentProjectPath = nil;
	
	preview.scale = 1.0f;
	preview.tilesSize = CGPointMake(50, 50);
    preview.tilesRows = 5;
    preview.tilesCols = 5;
    preview.delegate = self;
    preview.tilesRotate = M_PI_4;
    preview.tilesScale = CGPointMake(1, 0.5f);
	preview.tilesAnchorPoint = CGPointMake(1, 0);
	[preview center];
	
	[self updateProperties];
	
	[cleanButton setEnabled:NO];
    [removeButton setEnabled:NO];
}

@end
