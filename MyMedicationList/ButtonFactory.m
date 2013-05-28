//
//  ButtonFactory.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "ButtonFactory.h"


@implementation ButtonFactory

+ (UIButton *)newButtonWithTitle:(NSString *)title
                            size:(CGSize)size
                           image:(UIImage *)image
                    imagePressed:(UIImage *)imagePressed
{	
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];
	
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}

#define BUTTON_PADDING 10
+ (UIButton *)newButtonWithTitle:(NSString *)title size:(CGSize)size
{
    UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
    UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"blueButton.png"];
    
    UIButton *button = [ButtonFactory newButtonWithTitle:title
                                                    size:size
                                                   image:buttonBackground
                                            imagePressed:buttonBackgroundPressed];
    
	return button;
}

+ (UIButton *)newButtonWithTitle:(NSString *)title
{
    
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
    CGSize defaultTitleButtonSize = CGSizeMake(titleSize.width + BUTTON_PADDING, titleSize.height);
    
    UIButton *button = [ButtonFactory newButtonWithTitle:title
                                                    size:defaultTitleButtonSize];
    
	return button;
}


@end
