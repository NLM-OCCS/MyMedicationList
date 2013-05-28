//
//  InsuranceViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "ELCTextFieldCell.h"
#import "MMLCustomImageButton.h"

@protocol InsuranceInfoDelegate <NSObject>

- (void)saveInsuranceInfo:(NSDictionary *)dictionary isPrimary:(BOOL) isPrimary;

@end
@interface InsuranceViewController : UITableViewController<ELCTextFieldDelegate> {
    NSArray *labels;
    NSArray *placeholders;    
}

@property (nonatomic,assign)  id<InsuranceInfoDelegate> _delegate;
@property (nonatomic) BOOL isPrimary;
@property (nonatomic, assign) NSMutableDictionary *insuranceDataDict;
@property (nonatomic,retain) IBOutlet MMLCustomImageButton *frontCardBtn;
@property (nonatomic,retain) IBOutlet MMLCustomImageButton *backCardBtn;
@end
