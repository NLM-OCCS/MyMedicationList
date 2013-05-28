//
//  DailyMedViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"

@interface DailyMedViewController : UIViewController

@property (assign,nonatomic) id<HomeScreenDelegate> delegate;
@property (copy,nonatomic) NSString *rxcuiString;

@end
