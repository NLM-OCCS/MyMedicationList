//
//  UITapRectGestureRecognizer.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>


@interface UITapRectGestureRecognizer : UITapGestureRecognizer

@property (nonatomic, assign) CGRect touchRect; // Default number of taps in touchRect is 1

- (id)initWithTarget:(id)target action:(SEL)action rect:(CGRect)touchRect;
- (id)initWithTarget:(id)target action:(SEL)action; // All touches are ignored until touchRect is set

@end
