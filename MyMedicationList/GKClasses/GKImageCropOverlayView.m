//
//  GKImageCropOverlayView.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
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
#import "GKImageCropOverlayView.h"

@interface GKImageCropOverlayView ()
@property (nonatomic, retain) UIToolbar *toolbar;
@end

@implementation GKImageCropOverlayView

#pragma mark -
#pragma Getter/Setter

@synthesize cropSize;
@synthesize toolbar;

#pragma mark -
#pragma Overriden

- (void) dealloc {
    self.toolbar = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect{
    
    CGFloat toolbarSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0 : 54;

    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame) - toolbarSize;
    
    CGFloat heightSpan = floor(height / 2 - self.cropSize.height / 2);
    CGFloat widthSpan = floor(width / 2 - self.cropSize.width  / 2);
    
    //fill outer rect
    [[UIColor colorWithRed:0. green:0. blue:0. alpha:0.5] set];
    UIRectFill(self.bounds);
    
    //fill inner border
    [[UIColor colorWithRed:1. green:1. blue:1. alpha:0.5] set];
    UIRectFrame(CGRectMake(widthSpan - 2, heightSpan - 2, self.cropSize.width + 4, self.cropSize.height + 4));
    
    //fill inner rect
    [[UIColor clearColor] set];
    UIRectFill(CGRectMake(widthSpan, heightSpan, self.cropSize.width, self.cropSize.height));
    
    
    
    if (heightSpan > 30 && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        
        [[UIColor whiteColor] set];
        [NSLocalizedString(@"GKImoveAndScale", @"") drawInRect:CGRectMake(10, (height - heightSpan) + (heightSpan / 2 - 20 / 2) , width - 20, 20) 
                                                   withFont:[UIFont boldSystemFontOfSize:20] 
                                              lineBreakMode:UILineBreakModeTailTruncation 
                                                  alignment:UITextAlignmentCenter];
        
    }
}

@end

