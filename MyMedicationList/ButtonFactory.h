//
//  ButtonFactory.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>


@interface ButtonFactory : NSObject {
    
}

+ (UIButton *)newButtonWithTitle:(NSString *)title;
+ (UIButton *)newButtonWithTitle:(NSString *)title size:(CGSize)size;

@end
