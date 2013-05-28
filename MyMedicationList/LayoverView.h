//
//  LayoverView.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>


@interface LayoverView : UIAlertView {

}

- (id)initWithDelegate:(id)delegate detailedMedication:(BOOL)isDetailed;

@end
