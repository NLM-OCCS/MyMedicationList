//
//  Medication+CCDFunctionality.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//


#import "Medication+CCDFunctionality.h"

@implementation Medication (CCDFunctionality)

+ (NSArray *)parseIngredientString:(NSString *)ingredientString
{
    
    NSArray *components = [ingredientString componentsSeparatedByString:@" / "];
    for (NSString *component in components) {
        NSLog(@"component = %@",component);
        NSLog(@"component length = %d",[component length]);
    }
    
    NSMutableArray *ingredientStrings = [NSMutableArray arrayWithCapacity:[components count]];
    
    NSLog(@"trimming...");
    for (NSString *component in components)
        [ingredientStrings addObject:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    for (NSString *ingredient in ingredientStrings) {
        NSLog(@"component = %@",ingredient);
        NSLog(@"component length = %d",[ingredient length]);
    }
    
    return ingredientStrings;
}

@end
