//
//  GNPreviewDelegate.h
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 21.04.2012.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GNPreviewDelegate <NSObject>
-(void) handleDropedFilesList:(NSArray*)list;
-(void) handleDataItemWasChanged:(NSUInteger)index x:(float)x y:(float)y anchor:(CGPoint)anchor;
@end
