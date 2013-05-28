//
//  ContactUsViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
@interface ContactUsViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property (assign,nonatomic) id<HomeScreenDelegate> delegate;
@property (retain,nonatomic) IBOutlet UIButton *sendMailBtn;
@property (retain,nonatomic) IBOutlet UITableView *tableView;


- (IBAction) openEmailViewer:(id)sender;
@end
