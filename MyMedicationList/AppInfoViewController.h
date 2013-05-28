//
//  AppInfoViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "HomeScreenDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
@interface AppInfoViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property (assign,nonatomic) id<HomeScreenDelegate> delegate;

@end
