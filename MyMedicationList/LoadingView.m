//
//  LoadingView.m
//  LoadingView
//
//  Created by Matt Gallagher on 12/04/09.
//  Copyright Matt Gallagher 2009. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

static BOOL isOnScreen = NO;
@implementation LoadingView

//
// loadingViewInView:
//
// Constructor for this view. Creates and adds a loading view for covering the
// provided aSuperview.
//
// Parameters:
//    aSuperview - the superview that will be covered by the loading view
//
// returns the constructed view, already added as a subview of the aSuperview
//	(and hence retained by the superview)
//
+ (id)loadingViewInView:(UIView *)aSuperview withMessage:(NSString *)message
{

    CGFloat viewWidth = 165;
    CGFloat viewHeight = 130;
    CGFloat viewX = (aSuperview.frame.size.width - viewWidth)/2.0;
    CGFloat viewY = (aSuperview.frame.size.height - viewHeight)/2.0;
    
    LoadingView *loadingView =
    //[[[LoadingView alloc] initWithFrame:[aSuperview bounds]] autorelease];
    [[[LoadingView alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, viewHeight)] autorelease];
	if (!loadingView)
	{
		return nil;
	}
	
	loadingView.opaque = NO;
	loadingView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[aSuperview addSubview:loadingView];
    isOnScreen = YES;
    
	const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
	const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
	CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
	UILabel *loadingLabel =
    [[[UILabel alloc]
      initWithFrame:labelFrame]
     autorelease];
	//loadingLabel.text = NSLocalizedString(@"Loading...", nil);
    loadingLabel.text = NSLocalizedString(message, nil);
	loadingLabel.textColor = [UIColor whiteColor];
	loadingLabel.backgroundColor = [UIColor clearColor];
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
	loadingLabel.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
	
	[loadingView addSubview:loadingLabel];
	UIActivityIndicatorView *activityIndicatorView =
    [[[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]
     autorelease];
	[loadingView addSubview:activityIndicatorView];
	activityIndicatorView.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
	[activityIndicatorView startAnimating];
	
	CGFloat totalHeight =
    loadingLabel.frame.size.height +
    activityIndicatorView.frame.size.height;
	labelFrame.origin.x = floor(0.5 * (loadingView.frame.size.width - DEFAULT_LABEL_WIDTH));
	labelFrame.origin.y = floor(0.5 * (loadingView.frame.size.height - totalHeight));
	loadingLabel.frame = labelFrame;
	
	CGRect activityIndicatorRect = activityIndicatorView.frame;
	activityIndicatorRect.origin.x =
    0.5 * (loadingView.frame.size.width - activityIndicatorRect.size.width);
	activityIndicatorRect.origin.y =
    loadingLabel.frame.origin.y + loadingLabel.frame.size.height;
	activityIndicatorView.frame = activityIndicatorRect;
	
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
    animation.delegate = self;
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
	return loadingView;
}

+ (BOOL)isOnScreen
{
    return isOnScreen;
}

- (void)animationDidStart:(CAAnimation *)anim
{
    NSLog(@"Animation!!!!!!!!!!!!!!");
    isOnScreen = YES;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"More Animation!!!!!!!!!!!!!!");
    isOnScreen = YES;
}

//
// removeView
//
// Animates the view out from the superview. As the view is removed from the
// superview, it will be released.
//
- (void)removeView
{

    UIView *aSuperview = [self superview];
	[super removeFromSuperview];
    isOnScreen = NO;
    
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
    
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	rect.size.height -= 1;
	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = 8.0;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = 5.0;
	
    
    // Create a rounded rect path with a given radius
    CGMutablePathRef roundRectPath = CGPathCreateMutable();
	CGPathMoveToPoint(roundRectPath, NULL,
                      rect.origin.x,
                      rect.origin.y + rect.size.height - ROUND_RECT_CORNER_RADIUS);
    
	// Top left corner
	CGPathAddArcToPoint(roundRectPath, NULL,
                        rect.origin.x,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        ROUND_RECT_CORNER_RADIUS);
    
	// Top right corner
	CGPathAddArcToPoint(roundRectPath, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        ROUND_RECT_CORNER_RADIUS);
    
	// Bottom right corner
	CGPathAddArcToPoint(roundRectPath, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        ROUND_RECT_CORNER_RADIUS);
    
	// Bottom left corner
	CGPathAddArcToPoint(roundRectPath, NULL,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y,
                        ROUND_RECT_CORNER_RADIUS);
    
	// Close the path at the rounded rect
	CGPathCloseSubpath(roundRectPath);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	const CGFloat BACKGROUND_OPACITY = 0.85;
	CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
    
	const CGFloat STROKE_OPACITY = 0.25;
	CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
	CGContextAddPath(context, roundRectPath);
	CGContextStrokePath(context);
	
	CGPathRelease(roundRectPath);
}

//
// dealloc
//
// Release instance memory.
//
- (void)dealloc
{
    [super dealloc];
}

@end
