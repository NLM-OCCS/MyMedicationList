//
//  RemindersViewController.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "RemindersViewController.h"
#import "ELCTextFieldCell.h"
#import "CustomELCTextViewCell.h"
#import "MMLCustomSubTitleTableViewCell.h"
#import "MedSigViewController.h"
#import "MMLPersonData.h"

@interface RemindersViewController ()<ELCTextFieldDelegate,MedSigProtocol,ELCTextViewDelegate>
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSArray *placeholders;
@property (nonatomic,retain)  NSArray *labelPlaceholders;
@property(nonatomic,retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;
- (IBAction) cancelReminder:(id)sender;
- (IBAction) scheduleReminder:(id)sender;
- (IBAction) resignDatePicker:(id)sender;
@end

@implementation RemindersViewController
@synthesize labels,placeholders,medication,datePicker,toolBar,person;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    self.labelPlaceholders = nil;
    self.placeholders = nil;
    self.datePicker = nil;
    self.toolBar = nil;
    self.labels = nil;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.labels = [NSArray arrayWithObjects:@"Reminder Text",
                  @"Reminder Date",
                  @"Repeat Interval",
                  nil];
	
	self.placeholders = [NSArray arrayWithObjects:@"Enter Reminder Text",
                         @"Enter Reminder Date",
                         @"Enter Repeat Interval",
                         nil];
    
    self.title = @"Reminders";
    if (!self.readOnly) {
    UIBarButtonItem *rightbarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(scheduleReminder:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightbarButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    self.navigationItem.hidesBackButton = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{ 
    if ([RemindersViewController hasReminders:[medication.creationID unsignedIntValue]]) {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==0) {
        return 90.0f;
    } else if (indexPath.section == 3) {
        return 44.0f;
    } else
        return 55.0f;
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Reminder Text";
    } else if (section == 1) {
        return @"Reminder Date and Time";
    } else if (section ==2 ) {
        return @"Reminder Frequency";
    } else
        return @"";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.section == 0) {
        CustomELCTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1"];
        if (cell == nil) {
            cell = [[[CustomELCTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell1"] autorelease];
        }
        NSString *name = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName ];
        if (indexPath.section == 0) {
            if (self.medication.medicationAmount == nil) {
          
                cell.rightTextField.text = [NSString stringWithFormat:@"%@: Take %@", name,medication.name];
            } else {
                MedicationAmount *medAmount = [[MedicationAmount alloc] initWithAmountType:[[medication.medicationAmount valueForKey:@"amountType"] intValue] Quantity:[[medication.medicationAmount valueForKey:@"quantity"] intValue]];
                cell.rightTextField.text = [NSString stringWithFormat:@"%@: Take %@ of %@", name,[medAmount displayAmount], medication.name];
            }
            NSString *repeatText = [ self getReminderText:[medication.creationID unsignedIntValue]];
            if (repeatText != nil && ![repeatText isEqualToString:@""]) {
                cell.rightTextField.text = repeatText;
            }
            
        }
        cell.delegate = self;
        return cell;
    }
    
    if (indexPath.section == 1) {
        ELCTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[ELCTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    // Configure the cell...
    
    if (indexPath.section == 2) {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OtherCellIdentifier1"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OtherCellIdentifier1"] autorelease];
        }
        cell.textLabel.text = @"Reminder Frequency";
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString *repeatText = [ self getRepeatInterValText:[medication.creationID unsignedIntValue]];
        if (repeatText != nil && ![repeatText isEqualToString:@""]) {
            cell.textLabel.text = repeatText;
            cell.textLabel.textColor = [UIColor darkTextColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
    
    if (indexPath.section == 3) {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"deleteButon"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deleteButon"] autorelease];
        }
        UIView *btn1 = [cell.contentView viewWithTag:50000];
        [btn1 removeFromSuperview];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"Delete Reminder" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelReminder:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[[UIImage imageNamed:@"iphone_delete_button.png"]
                                 stretchableImageWithLeftCapWidth:8.0f
                   topCapHeight:0.0f] forState:UIControlStateNormal];
        btn.tag = 50000;
        [cell.contentView addSubview:btn];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
        
    }
return nil;
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        UIView *btn = [cell.contentView viewWithTag:50000];
        btn.frame = CGRectMake (0,0,cell.contentView.frame.size.width,cell.contentView.frame.size.height);;
       
    }
}
- (void)configureCell:(ELCTextFieldCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	cell.rightTextField.placeholder = [self.placeholders objectAtIndex:indexPath.section];
    
    if (indexPath.section == 0) {
       
        
    }
    if (indexPath.section == 1) {
            cell.rightTextField.inputView  = self.datePicker;
            cell.rightTextField.inputAccessoryView = toolBar;
            if ([RemindersViewController hasReminders:[medication.creationID unsignedIntValue]]) {
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"EEEE MMMM d, YYYY  HH:mm zzz"];
              cell.rightTextField.text = [dateFormat stringFromDate:[(UILocalNotification *) [RemindersViewController retrieveReminder:[medication.creationID unsignedIntValue]] fireDate]];
                [dateFormat release];

            }else {
                cell.rightTextField.text = @"";
            }
    }
	cell.indexPath = indexPath;
	cell.delegate = self;
    
    //Disables UITableViewCell from accidentally becoming selected.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        MedSigViewController *freqController = [[MedSigViewController alloc] initWithNibName:@"MedSigViewController" bundle:nil];
        freqController.readOnly = self.readOnly;
        freqController.delegate = self;
        freqController.type = @"Repeat Interval";
        freqController.selectedValue = [self getRepeatInterValText:[medication.creationID unsignedIntValue]];
      //  if ([medDataDict valueForKey:@"Repeat Interval"]) {
           // freqController.selectedIndex = [(MedicationFrequency *)[medDataDict valueForKey:@"Frequency"] frequency];
    //    } else {(NSString *) getReminderText:(int) medicationId
            freqController.selectedIndex = -1;
   //     }
        [[self navigationController] pushViewController:freqController animated:YES];
        [freqController release];
    }
}
+(UILocalNotification *) retrieveReminder:(int) medicationId {
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotify in localNotifications) {
        NSDictionary *userInfo = localNotify.userInfo;
        NSNumber *medId = (NSNumber *)[userInfo objectForKey:@"MedicationID"];
        if ([medId intValue] == medicationId) {
            NSLog(@"Reminder is %@ for %@", medId, localNotify.alertBody);
            return localNotify;
        } else
            NSLog(@"Reminder is %@ for %@", medId, localNotify.alertBody);
        
    }
    return nil;
}
+(BOOL) hasReminders:(int) medicationId {
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotify in localNotifications) {
        NSDictionary *userInfo = localNotify.userInfo;
        NSNumber *medId = (NSNumber *)[userInfo objectForKey:@"MedicationID"];
        if ([medId intValue] == medicationId) {
            return YES;
        }
        
    }
    return NO;
}
- (NSString *) getReminderText:(int) medicationId {
    UILocalNotification *notification =   [RemindersViewController retrieveReminder:[medication.creationID unsignedIntValue]];
    NSDictionary *dict = notification.userInfo;
    if (dict != nil) {
        return [dict valueForKey:@"kRemindMeNotificationDataKey"];
    }
    return @"";
}
- (NSString *) getRepeatInterValText:(int) medicationId {
    UILocalNotification *notification =   [RemindersViewController retrieveReminder:[medication.creationID unsignedIntValue]];
    NSDictionary *dict = notification.userInfo;
    if (dict != nil) {
        return [dict valueForKey:@"RepeatInterval"];
    }
    return @"";
}


- (void) createReminder:(NSDate *) fireDate withText:(NSString *) text repeatIntervalText:(NSString *) intervalText
                      numberofNotifications:(int)num recur:(BOOL)recurring withUnit:(NSCalendarUnit) cal {
    
    Class cls = NSClassFromString(@"UILocalNotification");
    if (num == 0)
        return;
    int increment = 24/num;
    NSDate *tmpDate;
    if (cls != nil) {
        for (int i=0; i < num;i++) {
            UILocalNotification *notif = [[cls alloc] init];
            notif.timeZone = [NSTimeZone defaultTimeZone];
            if (recurring) {
                notif.repeatInterval = cal;
            }
            if (i != 0) {
                notif.fireDate = [tmpDate dateByAddingTimeInterval:increment*3600];
                
            } else {
                notif.fireDate = fireDate;
            }
            tmpDate = notif.fireDate;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"EEEE MMMM d, YYYY  HH:mm zzz"];
            
            NSString *dateString = [dateFormat stringFromDate:notif.fireDate];
            NSLog(@"Creating a notification at %@",dateString );
            [dateFormat release];
            notif.alertBody = text;
            notif.hasAction = NO;
            //notif.alertAction = @"OK";
            notif.soundName = UILocalNotificationDefaultSoundName;
            notif.applicationIconBadgeNumber = 1;
            
            NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:text, @"kRemindMeNotificationDataKey", [NSNumber numberWithUnsignedInt:[medication.creationID unsignedIntValue]]  ,@"MedicationID", intervalText, @"RepeatInterval",nil];
            
            notif.userInfo = userDict;
            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            [notif release];
        }
        // return notif;
    }
    //return  nil;
}
-(void) cancelReminderForMedicationId:(int) medicationId {
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotify in localNotifications) {
        NSDictionary *userInfo = localNotify.userInfo;
        NSNumber *medId = (NSNumber *)[userInfo objectForKey:@"MedicationID"];
        if ([medId intValue] == medicationId) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotify];
        }
        
    }
}
- (void)cancelReminder:(id) sender {
	
	// Close the view and return
    [self cancelReminderForMedicationId:[medication.creationID unsignedIntValue]];
    [self.tableView reloadData];
}

- (void) resignDatePicker:(id)sender {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setDateFormat:@"EEEE MMMM d, YYYY  HH:mm zzz"];

    NSString *dateString = [dateFormat stringFromDate:[datePicker date]];
    [dateFormat release];  // delete this line if your project uses ARC
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        ELCTextFieldCell *cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.rightTextField resignFirstResponder];
        cell.rightTextField.text = dateString;
    }
    
   
}
- (void)scheduleReminder:(id)sender {
	int repeatInterval = -1;
    NSString *text =@"";
    NSString *repeatText = @"";
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self cancelReminderForMedicationId:[medication.creationID unsignedIntValue]];
    if((MMLCustomSubTitleTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        MMLCustomSubTitleTableViewCell *cell = (MMLCustomSubTitleTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
         repeatInterval = [self repeatInterval:cell.textLabel.text];
        repeatText = cell.textLabel.text;
    }
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if((ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        ELCTextFieldCell *cell = (ELCTextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        text = cell.rightTextField.text;
        [cell.rightTextField resignFirstResponder];
    }
    NSDate *date = [self.datePicker date];
    if (repeatInterval < 100) {
        [self createReminder:date withText:text repeatIntervalText:repeatText numberofNotifications:repeatInterval recur:YES withUnit:NSDayCalendarUnit];
    }
    if (repeatInterval == 101) {
        [self createReminder:date withText:text repeatIntervalText:repeatText numberofNotifications:1 recur:YES withUnit:NSMonthCalendarUnit];
    }
    if (repeatInterval == 102) {
        [self createReminder:date withText:text repeatIntervalText:repeatText numberofNotifications:1 recur:YES withUnit:NSWeekCalendarUnit];
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

+ (void) cancelAllReminders:(int)medicationId {
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotify in localNotifications) {
        NSDictionary *userInfo = localNotify.userInfo;
        NSNumber *medId = (NSNumber *)[userInfo objectForKey:@"MedicationID"];
        if ([medId intValue] == medicationId) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotify];
        }
        
    }
}

//self.intervalArray = [NSArray arrayWithObjects:@"Every One Hour", @"Every Two Hours", @"Every Three Hours",
  //                    @"Every Four Hours", @"Every Six Hours", @"Every Eight Hours", @"Twice Daily", @"Daily Once", @"Weekly Once", @"Monthly Once",nil];
- (int) repeatInterval:(NSString *)intervalString {
    if ([intervalString isEqualToString:@"Every One Hour"]) {
        return 24;
    } else if ([intervalString isEqualToString:@"Every Two Hours"]) {
        return 12;
    } else if ([intervalString isEqualToString:@"Every Three Hours"]) {
        return 8;
    } else if ([intervalString isEqualToString:@"Every Four Hours"]) {
        return 6;
    } else if ([intervalString isEqualToString:@"Every Six Hours"]) {
        return 4;
    } else if ([intervalString isEqualToString:@"Every Eight Hours"]) {
        return 3;
    } else if ([intervalString isEqualToString:@"Every Twelve Hours"]) {
        return 2;
    } else if ([intervalString isEqualToString:@"Daily"]) {
        return 1;
    } else if ([intervalString isEqualToString:@"Monthly"]) {
        return 101;
    } else if ([intervalString isEqualToString:@"Weekly"]) {
        return 102;
    }
    return 0;
}

- (void) medSigResponse:(MedSigViewController *)inView withRepeatInterval:(NSString *)interval {
    // set the third section subtitle value to interval
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    if((MMLCustomSubTitleTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath] != nil) {
        MMLCustomSubTitleTableViewCell *cell = (MMLCustomSubTitleTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = interval;
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
}
#pragma mark -
#pragma mark === Text View Delegate ===
#pragma mark -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark === Text Field Delegate ===
#pragma mark -

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextView *)textField {
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextView *)textField {
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextView *)textField {
    return ;
}
- (void)textFieldDidEndEditing:(UITextView *)textField {
    return;
}

- (void)textFieldCell:(CustomELCTextViewCell *)inCell updateTextLabelAtIndexPath:(NSIndexPath *)inIndexPath string:(NSString *)inValue {
    if([inValue isEqualToString:@"\n"]) {
        [inCell.rightTextField resignFirstResponder];
    }
    
}
@end
