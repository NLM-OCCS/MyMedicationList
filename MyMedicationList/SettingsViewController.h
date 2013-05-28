//
//  SettingsViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"

@interface SettingsViewController : UITableViewController

@property (assign,nonatomic) id<HomeScreenDelegate> delegate;

@end
