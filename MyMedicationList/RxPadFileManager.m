//
//  RxPadFileManager.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "RxPadFileManager.h"
#import "NSData+CommonCrypto.h"
#import "Date.h"
BOOL isDir;

@implementation RxPadFileManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString *)getRootDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootDirectory = [paths objectAtIndex:0];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:rootDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
    
    if(error != nil)
        return nil;
    else
        return rootDirectory;
    
}
+ (NSString *)fileNameWithFirstName:(NSString *) firstName withLastName:(NSString *) lastName {
    
    // Get private docs dir
    NSString *documentsDirectory = [RxPadFileManager getRootDir];
    // Append sub directory
    //documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",firstName,lastName]];
    Date *today = [Date today];
    NSString *dateStr=[NSString stringWithFormat:@"%d%d%d",today.month, today.day, today.year];
        
    NSString *fileName = [NSString stringWithFormat:@"%@/%@%@_%@.xml",documentsDirectory,firstName,lastName,dateStr];
    // Get contents of documents directory
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory isDirectory:&isDir] && isDir) {
         
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
    }

    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        //May be a new directory Create one
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        // file Already exists just owverwrite
        return fileName;
    }
    else {
        // File does not exist just create one
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];           
    }
    return fileName;
}

+ (BOOL) saveToDisk:(NSString *) data withFirstName:(NSString *) firstName withLastName:(NSString *) lastName {
       // Create a file with <FirstName_LastName>/<first_name>/<last_name>_todaysDate.xml
    NSString *fileName = [RxPadFileManager fileNameWithFirstName:firstName withLastName:lastName]; 
    NSData *nsData=[data dataUsingEncoding:NSUTF8StringEncoding];    
    // Now we have both NSData and fileName just write to the fileName; 
    
    
    NSError *error = nil;
    NSData *secureData = [nsData AES256EncryptedDataUsingKey:@"SECUREKEY" error:&error ];
    if (error != nil) {
        return NO;
    }
    BOOL didSucceed = [secureData writeToFile:fileName options:NSDataWritingFileProtectionComplete error:&error];

    if((didSucceed)&&(error == nil)) 
        return YES;
    else
        return NO;
}



@end