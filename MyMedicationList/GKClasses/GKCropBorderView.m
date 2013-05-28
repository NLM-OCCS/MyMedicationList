//
//  PTCropBorderView.m
//  GKImagePicker
//
//  Created by Patrick Thonhauser on 9/21/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
/*Copyright (C) 2012, Georg Kitz, @gekitz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
#import "GKCropBorderView.h"

#define kNumberOfBorderHandles 8
#define kHandleDiameter 24


@interface GKCropBorderView()
-(NSMutableArray*)_calculateAllNeededHandleRects;
@end

@implementation GKCropBorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark -
#pragma drawing
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1. green:1. blue:1. alpha:0.5].CGColor);
    CGContextSetLineWidth(ctx, 1.5f);
    CGContextAddRect(ctx, CGRectMake(kHandleDiameter / 2, kHandleDiameter / 2, rect.size.width - kHandleDiameter, rect.size.height - kHandleDiameter));
    CGContextStrokePath(ctx);
    
    NSMutableArray* handleRectArray = [self _calculateAllNeededHandleRects];
    for (NSValue* value in handleRectArray){
        CGRect currentHandleRect = [value CGRectValue];
        
        CGContextSetRGBFillColor(ctx, 1., 1., 1., 0.95);
        CGContextFillEllipseInRect(ctx, currentHandleRect);
    }
    
}

#pragma mark -
#pragma private
-(NSMutableArray*)_calculateAllNeededHandleRects{
    
    NSMutableArray* a = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    //starting with the upper left corner and then following clockwise
    CGRect currentRect = CGRectMake(0, 0, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    
    currentRect = CGRectMake(self.frame.size.width / 2 - kHandleDiameter / 2, 0, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    
    currentRect = CGRectMake(self.frame.size.width - kHandleDiameter, 0 , kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    //upper row done
    currentRect = CGRectMake(self.frame.size.width - kHandleDiameter, self.frame.size.height / 2 - kHandleDiameter / 2, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    
    currentRect = CGRectMake(self.frame.size.width - kHandleDiameter, self.frame.size.height - kHandleDiameter, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    
    currentRect = CGRectMake(self.frame.size.width / 2 - kHandleDiameter / 2, self.frame.size.height - kHandleDiameter, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    
    currentRect = CGRectMake(0, self.frame.size.height - kHandleDiameter, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    //now back up again
    currentRect = CGRectMake(0, self.frame.size.height / 2 - kHandleDiameter / 2, kHandleDiameter, kHandleDiameter);
    [a addObject:[NSValue valueWithCGRect:currentRect]];
    
    return a;
}
@end
