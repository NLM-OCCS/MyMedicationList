//
//  LayoverView.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "LayoverView.h"

/*
 Background of AlertView is an image And you can change this image
 
 UIAlertView *theAlert = [[[UIAlertView alloc] initWithTitle:@"Atention"
 message: @"YOUR MESSAGE HERE", nil)
 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
 
 [theAlert show];
 
 UILabel *theTitle = [theAlert valueForKey:@"_titleLabel"];
 [theTitle setTextColor:[UIColor redColor]];
 
 UILabel *theBody = [theAlert valueForKey:@"_bodyTextLabel"];
 [theBody setTextColor:[UIColor blueColor]];
 
 UIImage *theImage = [UIImage imageNamed:@"Background.png"];    
 theImage = [theImage stretchableImageWithLeftCapWidth:16 topCapHeight:16];
 CGSize theSize = [theAlert frame].size;
 
 UIGraphicsBeginImageContext(theSize);    
 [theImage drawInRect:CGRectMake(0, 0, theSize.width, theSize.height)];    
 theImage = UIGraphicsGetImageFromCurrentImageContext();    
 UIGraphicsEndImageContext();
 
 [[theAlert layer] setContents:[theImage CGImage]];
 */


@implementation LayoverView

#define OtherButtonTitles @"Show Prescriptions",@"Print Medication List",@"Save to Disk"

- (id)initWithDelegate:(id)delegate detailedMedication:(BOOL)isDetailed
{
         
    self = [super initWithTitle:nil message:nil delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:(isDetailed)?@"Detailed View":@"Plain View",OtherButtonTitles,nil];
    
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
