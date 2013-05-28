//
//  RxNormWebDataObject.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>


// Notifications
//------------------------------------
// Downloading the display names completed
static NSString *const MMLDisplayNamesFinishedDownloadingNotification = @"MMLDisplayNamesFinishedDownloadingNotification";
// Downloading the display names failed
static NSString *const MMLDisplayNamesUpdatingFailedNotification = @"MMLDisplayNamesUpdatingFailedNotification";
//------------------------------------

@class ConceptProperty;
@protocol RxNormWebDataDelegate;

@interface RxNormWebDataObject : NSObject 

@property (assign,nonatomic) id <RxNormWebDataDelegate> delegate;

+ (RxNormWebDataObject *)webDataObject;

- (void)cancel;

- (void)getConceptPropertiesWithDisplayName:(NSString *)displayName;

- (void)getCCDInfo:(ConceptProperty *)conceptProperty;

- (void)getDisplayNames;

- (UIImage *)getMedicationImage:(NSString *)rxcuiString;
- (NSString *)getIngredient:(NSString *)rxcuiString;
- (void)getSPLSetId:(NSString *)rxcuiValue;
- (BOOL)isPrescribable:(NSString *)rxcui;
- (void) getApproximateMatch:(NSString *) term;
- (void)getConceptPropertiesUsingApproxMatchWithDisplayName:(NSString *)displayName;
@end


@protocol RxNormWebDataDelegate<NSObject>

- (void)rxNormWebDataObject:(RxNormWebDataObject *)webDataObject didReturnResult:(id)result;
- (void)rxNormWebDataObjectDidFail:(RxNormWebDataObject *)webDataObject;
- (void)rxNormWebDataObjectDidWarn:(RxNormWebDataObject *)webDataObject warningMessage:(id)result;

@end

