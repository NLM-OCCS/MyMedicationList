//
//  PictureEncasingView.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>

@interface PictureEncasingView : UIView
@property (strong,nonatomic) UIImage *encasedImage;
@property (assign,nonatomic) UIInterfaceOrientation interfaceOrientation;

- (id)initWithEncasedImage:(UIImage *)encasedImage;

@end
