//
//  GNAppDelegate.h
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 20.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import "GNItemsData.h"
#import "GNPreview.h"


@interface GNAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSWindowDelegate, GNPreviewDelegate>
{
	NSString* orgWindowTitle;
	
    GNItemsData* itemsData;
    NSTableView* itemsTableView;
    NSString* currentProjectPath;
    
    NSOpenPanel* imagesOpenPanel;
    NSSavePanel* exportPanel;
    
    NSOpenPanel* openPanel;
    NSSavePanel* savePanel;
}

@property (nonatomic, retain) NSString* currentProjectPath;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet GNPreview* preview;
@property (assign) IBOutlet NSScrollView* items;

@property (assign) IBOutlet NSSlider* scaleSlider;
@property (assign) IBOutlet NSTextField* scaleText;
@property (assign) IBOutlet NSButton *removeButton;
@property (assign) IBOutlet NSButton *cleanButton;
@property (assign) IBOutlet NSTextField *tileHeight;
@property (assign) IBOutlet NSTextField *tileWidth;
@property (assign) IBOutlet NSTextField *tilesRows;
@property (assign) IBOutlet NSTextField *tilesCols;
@property (assign) IBOutlet NSTextField *tilesScaleX;
@property (assign) IBOutlet NSTextField *tilesScaleY;
@property (assign) IBOutlet NSTextField *tilesAnchorX;
@property (assign) IBOutlet NSTextField *tilesAnchorY;
@property (assign) IBOutlet NSTextField *tilesRotate;

@property (assign) IBOutlet NSMenuItem *openRecentItems;
@property (assign) IBOutlet NSMenuItem *clearRecentItems;

@property (assign) IBOutlet NSButton *ingoreImageDPICheckBox;


-(IBAction) updateScaleWithSlider:(id)sender;
-(IBAction) updateScaleWithText:(id)sender;

-(IBAction) setVisible:(id)sender;
-(IBAction) setInvisible:(id)sender;
-(IBAction) addImage:(id)sender;
-(IBAction) removeImage:(id)sender;
-(IBAction) cleanInvalid:(id)sender;

-(IBAction) setWidth:(id)sender;
-(IBAction) setHeight:(id)sender;
-(IBAction) setRows:(id)sender;
-(IBAction) setCols:(id)sender;
-(IBAction) setScaleX:(id)sender;
-(IBAction) setScaleY:(id)sender;
-(IBAction) setAnchorPointX:(id)sender;
-(IBAction) setAnchorPointY:(id)sender;
-(IBAction) setRotate:(id)sender;

-(IBAction) dataWasChanged:(id)sender;

-(IBAction) openProject:(id)sender;
-(IBAction) saveProject:(id)sender;
-(IBAction) saveAsProject:(id)sender;
-(IBAction) clearOpenRecentMenu:(id)sender;
-(IBAction) selectAll:(id)sender;


-(IBAction) exportJSON:(id)sender;
-(IBAction) closeCurrent:(id)sender;
-(IBAction) quit:(id)sender;

-(IBAction) ignoreImageDPIChanged:(id)sender;

@end
