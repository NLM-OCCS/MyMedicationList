//
//  HomeScreenDelegate.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>

@protocol HomeScreenDelegate <NSObject>

@required
- (void)viewControllerWillReturnHome:(UIViewController *)viewController;

@end
