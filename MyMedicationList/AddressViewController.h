//
//  AddressViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "ELCTextFieldCell.h"
@protocol AddressInfoDelegate <NSObject>

- (void)saveAddressInfo:(NSDictionary *)dictionary;

@end
@interface AddressViewController : UITableViewController<ELCTextFieldDelegate>  {
NSArray *labels;
NSArray *placeholders;

}

@property (nonatomic, assign) NSMutableDictionary *addressDataDict;

@property (nonatomic,assign)  id<AddressInfoDelegate> _delegate;

@end
