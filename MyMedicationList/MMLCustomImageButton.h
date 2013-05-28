//
//  MMLCustomImageButton.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>

@interface MMLCustomImageButton : UIButton

- (void) addImageLayer:(NSString *) name withImage:(UIImage *) image;

- (void) addBottomTextLayer:(NSString *) layerName withText:(NSString *)text;
- (void) addTextLayer:(NSString *) layerName withText:(NSString *)text;

- (void) removeLayer:(NSString *) layerName;

- (void) addDashedBorderLayer:(NSString *)layerName withDashDistance:(int)spacing;

@end
