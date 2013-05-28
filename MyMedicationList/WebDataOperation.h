//
//  WebDataOperation.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>

@interface WebDataOperation : NSOperation 

// The selector dataHandler is called on dataHandlerDelegate when the operation completes
@property (assign,nonatomic) id dataHandlerDelegate;

- (id)initWithURLString:(NSString *)urlString usesJSON:(BOOL)doesUseJSON withDataHandler:(SEL)dataHandler forError:(SEL) errorHandler;
- (id)initWithURLString:(NSString *)urlString usesJSON:(BOOL)doesUseJSON withDataHandler:(SEL)dataHandler withContext:(id)context forError:(SEL) errorHandler;

@end
