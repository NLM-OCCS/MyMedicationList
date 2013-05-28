//
//  CCDParser.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>

@class MMLPersonData;
@protocol CCDParserDelegate;

@interface CCDParser : NSObject
@property (nonatomic,copy) NSString *parseString; // String that will be parsed 
@property (nonatomic,assign) id<CCDParserDelegate> delegate;

- (id)init;
- (id)initWithParseString:(NSString *)parseString;

- (void)parse;

@end

@protocol CCDParserDelegate <NSObject>

- (void)ccdParserDidFail:(CCDParser *)ccdParser;
- (void)ccdParser:(CCDParser *)ccdParser didParsePerson:(MMLPersonData *)personData;

@end
