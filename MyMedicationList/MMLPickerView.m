//
//  MMLPicker.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MMLPickerView.h"
#import "Date.h"

static NSString *const monthStrings[] = {   @"January",
                                            @"February",
                                            @"March",
                                            @"April",
                                            @"May",
                                            @"June",
                                            @"July",
                                            @"August",
                                            @"September",
                                            @"October",
                                            @"November",
                                            @"December"    };


@interface MMLPickerView () <UIPickerViewDataSource,UIPickerViewDelegate>

@end


@implementation MMLPickerView
@synthesize pickerType = _pickerType;

static unsigned int FINALYEAR;
#define             BASEYEAR 1900

- (id)init
{
    return [self initWithPickerType:DatePicker];
}

- (id)initWithPickerType:(PickerType)pickerType
{
    self = [super init];
    if(self)
    {
        self.pickerType = pickerType;
        self.delegate = self;
        self.dataSource = self;
        
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSYearCalendarUnit;
        
        NSDate *date = [NSDate date];
        
        NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
        
        FINALYEAR = [comps year];

    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (Date *)selectedDate
{
    if(_pickerType != DatePicker)
        return nil;
    else
    {
        NSInteger month = [self selectedRowInComponent:0];
        NSInteger day = [self selectedRowInComponent:1];
        NSInteger year = [self selectedRowInComponent:2];        
        Date *currentSelectedDate = [[Date alloc] initWithDay:(day + 1) Month:(month + 1) Year:(BASEYEAR + year)];
        return [currentSelectedDate autorelease];
    }
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_pickerType == DatePicker)
		return 3;
    else 
        return 1;
}



// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(_pickerType == DatePicker)
	{
		// Return 12 months
		if(component == 0)
			return 12;
		// Return the number of days appropriate to a given month
		else if(component == 1)
		{
			int currentMonth = [pickerView selectedRowInComponent:0];
			if((currentMonth == 3)||(currentMonth == 5)||(currentMonth == 8)||(currentMonth == 10))
				return 30;
			else if (currentMonth == 1)
			{
				if((([pickerView selectedRowInComponent:2]+1)%4)==0)
					return 29;
				else
					return 28;
			}
			else
				return 31;
		}
		// Return a number of years
		else 
			return (FINALYEAR - BASEYEAR+1);
	}
    else
        return 1;

}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if(_pickerType == DatePicker)
    {
        if(component == 0)
            return 130.0f;
        else if(component == 1)
            return 50.0f;
        else
            return 75.0f;
    }
    else
        return 280.0f;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(_pickerType == DatePicker)
    {
        if(component == 0)
            return monthStrings[row];
        else if(component == 1)
            return [NSString stringWithFormat:@"%d",row+1];
        else
            return [NSString stringWithFormat:@"%d",row+BASEYEAR];	
    }
    else
        return @"Empty";
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(_pickerType == DatePicker)
        if((component == 0)||(component == 2))
            [pickerView reloadComponent:1];    
}

@end
