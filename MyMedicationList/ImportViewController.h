//
//  ImportViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol ImportViewDelegate;

@interface ImportViewController : UIViewController

@property (copy, nonatomic) NSString *ccdString;
@property (assign,nonatomic) id<ImportViewDelegate> delegate;

@end

@protocol ImportViewDelegate <NSObject>
@required
- (void)importViewControllerDidDismiss:(ImportViewController *)importViewController didImport:(BOOL)shouldImport error:(NSError *)error; 
@end
