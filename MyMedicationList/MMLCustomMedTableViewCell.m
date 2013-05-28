//
//  MMLCustomMedTableViewCell.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MMLCustomMedTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
#import "MedicationFrequency.h"
#import "MedicationAmount.h"
#import "MedicationInstruction.h"
#import "RemindersViewController.h"

@implementation MMLCustomMedTableViewCell
@synthesize medNameLabel;
@synthesize frequencyLabel;
@synthesize amountLabel;
@synthesize instructionLabel;
@synthesize medButton;
@synthesize startDate;
@synthesize stopDate;
@synthesize reminder;
@synthesize type;

- (void) dealloc {
    
    self.medButton = nil;
    self.instructionLabel = nil;
    self.amountLabel = nil;
    self.frequencyLabel = nil;
    self.medNameLabel = nil;
    self.stopDate = nil;
    self.startDate = nil;
    self.reminder = nil;
    self.type = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}
- (void)setMedicationData:(MMLMedication *)medication
{
    medNameLabel.text = [medication name];
     if(medication.medicationFrequency != nil)
        frequencyLabel.text = [NSString stringWithFormat:@"%@%@",@"Frequency: ",[MedicationFrequency frequencyStringForFrequency:[[medication.medicationFrequency valueForKey:@"frequency" ] intValue] ] ];
    else
        frequencyLabel.text = @"Frequency: ";
        
        if(medication.medicationInstruction != nil)
    {
        instructionLabel.text = [NSString stringWithFormat:@"Instructions: %@",[[[[MedicationInstruction alloc] initWithInstruction:[medication.medicationInstruction valueForKey:@"instruction" ]] autorelease] printInstruction]];
        
    }
    else
        instructionLabel.text = @"Instructions: ";
        
    
    if(medication.medicationAmount != nil)
    {
        amountLabel.text = [NSString stringWithFormat:@"%@%@",@"Amount: ", [[[[MedicationAmount alloc] initWithAmountType:[[medication.medicationAmount valueForKey:@"amountType"] intValue ] Quantity:[[medication.medicationAmount valueForKey:@"quantity"]  intValue]] autorelease] printAmount] ];

    }
    else
    {
        amountLabel.text = @"Amount: ";
    }
    if(medication.startDate != nil)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterMediumStyle;
        startDate.text = [NSString stringWithFormat:@"%@%@",@"Start Date: ",[df stringFromDate:medication.startDate]];;
        [df release];        
    }
    else
    {
        startDate.text = @"Start Date: ";
    }
    stopDate.textColor = [UIColor blackColor];

    if ([self.type isEqualToString:@"DISCONTINUED"]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterMediumStyle;
        stopDate.text = [NSString stringWithFormat:@"%@%@",@"Stop Date: ",[df stringFromDate:medication.stopDate]];
        [df release];
    }else if(medication.stopDate != nil)
    {
        NSDate *endDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
        endDate = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:endDate]];

        if ([medication.stopDate compare:endDate] == NSOrderedAscending) {
            stopDate.text = @"Stop Date: EXPIRED";
            stopDate.textColor = [UIColor redColor];
        } else if ([medication.stopDate compare:medication.startDate] == NSOrderedAscending) {
            stopDate.text = @"Stop Date:Less than Start Date";
            stopDate.textColor = [UIColor redColor];
        } else  {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterMediumStyle;
            stopDate.text = [NSString stringWithFormat:@"%@%@",@"Stop Date: ",[df stringFromDate:medication.stopDate]];
            [df release];
        }
    }
    else
    {
        stopDate.text = @"Stop Date: ";
    }
    if ([RemindersViewController hasReminders:[medication.creationID intValue]]) {
        reminder.text = @"Reminder: On";
    } else
        reminder.text = @"Reminder: Off";
}
@end
