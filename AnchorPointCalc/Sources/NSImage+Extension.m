//
//  NSImage+Extension.m
//  AnchorPointCalc
//
//  Created by Sebastian Sledz on 12-05-28.
//  Copyright (c) 2012 Garaz.net. All rights reserved.
//

#import <objc/runtime.h>
#import "NSImage+Extension.h"

static BOOL ignoreDPI = NO;

@implementation NSImage (Extension)

+(BOOL) ignoreDPI
{
    return ignoreDPI;
}

+(void) setIgnoreDPI:(BOOL)value
{
    ignoreDPI = value;
}

+(void) load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(initWithContentsOfFile:)),
                                   class_getInstanceMethod(self, @selector(orgInitWithContentsOfFile:)));
}

-(id) orgInitWithContentsOfFile:(NSString*)text
{
    if ((self = [self orgInitWithContentsOfFile:text]) && ignoreDPI)
    {
        NSBitmapImageRep *rep = [[self representations] objectAtIndex: 0];
        [self setSize:NSMakeSize([rep pixelsWide], [rep pixelsHigh])];
    }
    return self;
}

@end
