//
//  UserListViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"
#import "ImportViewController.h"

@interface UserListViewController : UITableViewController
@property (assign,nonatomic) id <HomeScreenDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableViewCell *genderTableViewCell;
@property (nonatomic,retain) IBOutlet UIView *bluetoothActionView;
@property (retain,nonatomic) ImportViewController *importViewController;
- (void)presentModalImportViewController;
- (void)dismissModalImportViewController;
- (void) migrateToCoreData;
@end
