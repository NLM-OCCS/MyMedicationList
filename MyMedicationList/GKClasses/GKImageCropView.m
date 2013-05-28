//
//  GKImageCropView.m
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
#import "GKImageCropView.h"
#import "GKImageCropOverlayView.h"
#import "GKResizeableCropOverlayView.h"

#import <QuartzCore/QuartzCore.h>

@interface ScrollView : UIScrollView
@end

@implementation ScrollView

- (void)layoutSubviews{
    [super layoutSubviews];

    UIView *zoomView = [self.delegate viewForZoomingInScrollView:self];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    zoomView.frame = frameToCenter;
}

@end

@interface GKImageCropView ()<UIScrollViewDelegate>
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) GKImageCropOverlayView *cropOverlayView;
@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;
@end

@implementation GKImageCropView
- (void) dealloc {
    self.scrollView = nil;
    self.imageToCrop = nil;
    self.imageView = nil;
    self.cropOverlayView = nil;
    [super dealloc];
}

#pragma mark -
#pragma Getter/Setter
@synthesize scrollView, imageView, cropOverlayView, resizableCropArea, xOffset, yOffset;

- (void)setImageToCrop:(UIImage *)imageToCrop{
    self.imageView.image = imageToCrop;
}

- (UIImage *)imageToCrop{
    return self.imageView.image;
}

- (void)setCropSize:(CGSize)cropSize{
    
    if (self.cropOverlayView == nil){
        if(self.resizableCropArea)
            self.cropOverlayView = [[[GKResizeableCropOverlayView alloc] initWithFrame:self.bounds andInitialContentSize:CGSizeMake(cropSize.width, cropSize.height)] autorelease];
        else
            self.cropOverlayView = [[[GKImageCropOverlayView alloc] initWithFrame:self.bounds] autorelease];
        
        [self addSubview:self.cropOverlayView];
    }
    self.cropOverlayView.cropSize = cropSize;
}

- (CGSize)cropSize{
    return self.cropOverlayView.cropSize;
}

#pragma mark -
#pragma Public Methods

- (UIImage *)croppedImage{
    
    //renders the the zoomed area into the cropped image
    if (self.resizableCropArea){
        GKResizeableCropOverlayView* resizeableView = (GKResizeableCropOverlayView*)self.cropOverlayView;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(resizeableView.contentView.frame.size.width, resizeableView.contentView.frame.size.height), self.scrollView.opaque, 0.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGFloat xPositionInScrollView = resizeableView.contentView.frame.origin.x + self.scrollView.contentOffset.x - self.xOffset;
        CGFloat yPositionInScrollView = resizeableView.contentView.frame.origin.y + self.scrollView.contentOffset.y - self.yOffset;
        CGContextTranslateCTM(ctx, -(xPositionInScrollView), -(yPositionInScrollView));
    }
    else {
		
		CGFloat scale = self.scrollView.maximumZoomScale / self.scrollView.zoomScale;
        UIGraphicsBeginImageContextWithOptions(self.scrollView.frame.size, self.scrollView.opaque, scale);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(ctx, -self.scrollView.contentOffset.x, -self.scrollView.contentOffset.y);
    }
    [self.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

#pragma mark -
#pragma Override Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.scrollView = [[[ScrollView alloc] initWithFrame:self.bounds ] autorelease];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.decelerationRate = 0.0; 
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        
        self.imageView = [[[UIImageView alloc] initWithFrame:self.scrollView.frame] autorelease];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:self.imageView];
    
        
        self.scrollView.minimumZoomScale = CGRectGetWidth(self.scrollView.frame) / CGRectGetWidth(self.imageView.frame);
        self.scrollView.maximumZoomScale = 20.0;
        [self.scrollView setZoomScale:1.0];
    }
    return self;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (!self.resizableCropArea)
        return self.scrollView;

    GKResizeableCropOverlayView* resizeableCropView = (GKResizeableCropOverlayView*)self.cropOverlayView;
    
    CGRect outerFrame = CGRectInset(resizeableCropView.cropBorderView.frame, -10 , -10);
    if (CGRectContainsPoint(outerFrame, point)){
        
        if (resizeableCropView.cropBorderView.frame.size.width < 60 || resizeableCropView.cropBorderView.frame.size.height < 60 )
            return [super hitTest:point withEvent:event];
        
        CGRect innerTouchFrame = CGRectInset(resizeableCropView.cropBorderView.frame, 30, 30);
        if (CGRectContainsPoint(innerTouchFrame, point))
            return self.scrollView;
        
        CGRect outBorderTouchFrame = CGRectInset(resizeableCropView.cropBorderView.frame, -10, -10);
        if (CGRectContainsPoint(outBorderTouchFrame, point))
            return [super hitTest:point withEvent:event];
        
        return [super hitTest:point withEvent:event];
    }
    return self.scrollView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize size = self.cropSize;
    CGFloat toolbarSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0 : 54;
    self.xOffset = floor((CGRectGetWidth(self.bounds) - size.width) * 0.5);
    self.yOffset = floor((CGRectGetHeight(self.bounds) - toolbarSize - size.height) * 0.5); //fixed

    CGFloat height = self.imageToCrop.size.height;
    CGFloat width = self.imageToCrop.size.width;
    
    CGFloat faktor = 0.f;
    CGFloat faktoredHeight = 0.f;
    CGFloat faktoredWidth = 0.f;
    
    if(width > height){
        
        faktor = width / size.width;
        faktoredWidth = size.width;
        faktoredHeight =  height / faktor;
        
    } else {
        
        faktor = height / size.height;
        faktoredWidth = width / faktor;
        faktoredHeight =  size.height;
    }
    
    self.cropOverlayView.frame = self.bounds;
    self.scrollView.frame = CGRectMake(xOffset, yOffset, size.width, size.height);
    self.scrollView.contentSize = CGSizeMake(size.width, size.height);
    self.imageView.frame = CGRectMake(0, floor((size.height - faktoredHeight) * 0.5), faktoredWidth, faktoredHeight);
}

#pragma mark -
#pragma UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

@end
