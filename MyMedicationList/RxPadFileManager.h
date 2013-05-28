//
//  RxPadFileManager.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>

@interface RxPadFileManager : NSObject

+ (BOOL)saveToDisk:(NSString *)data withFirstName:(NSString *) firstName withLastName:(NSString *) lastName;

@end
