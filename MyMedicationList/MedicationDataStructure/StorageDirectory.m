//
//  StorageDirectory.c
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <Foundation/Foundation.h>
#import "StorageDirectory.h"

NSString *storageDirectory(void)
{
    static NSString *directory = nil;
    
    if(directory == nil)
    {
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        directory = [paths objectAtIndex:0];
        [directory retain];
    }
    
    return directory;
}