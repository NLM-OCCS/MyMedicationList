//
//  CCDInfo.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>


@interface CCDInfo : NSObject<NSCoding,NSMutableCopying>{

	BOOL isClinicalDrug;
	NSString *codeDisplayName;
	NSString *codeDisplayNameRxCUI;
	NSString *translationDisplayName;
	NSString *translationDisplayNameRxCUI;
	NSString *ingredientName;
	NSString *brandName;
}

@property (assign) BOOL isClinicalDrug;
@property (retain) NSString *codeDisplayName;
@property (retain) NSString *codeDisplayNameRxCUI;
@property (retain) NSString *translationDisplayName;
@property (retain) NSString *translationDisplayNameRxCUI;
@property (retain) NSString *ingredientName;
@property (retain) NSString *brandName;

- (id)initWithIsClinicalDrug:(BOOL)isClinical;

- (void)setClinicalInfoWithCodeDisplayName:(NSString *)thisCodeDisplayName 
					  CodeDisplayNameRxCUI:(NSString *)thisCodeDisplayNameRxCUI 
							IngredientName:(NSString *)thisIngredientName;


- (void)setBrandInfoWithCodeDisplayName:(NSString *)thisCodeDisplayName 
				   CodeDisplayNameRxCUI:(NSString *)thisCodeDisplayNameRxCUI 
				 TranslationDisplayName:(NSString *)thisTranslationDisplayName 
			TranslationDisplayNameRxCUI:(NSString *)thisTranslationDisplayNameRxCUI 
						 IngredientName:(NSString *)thisIngredientName 
							  BrandName:(NSString *)thisBrandName;	

- (void)printCCD;

- (id)mutableCopy;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
