//
//  MMLPicker.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

@class Date;

enum PickerType {
	DatePicker//,
//	AmountPicker,
//	FrequencyPicker
};
typedef enum PickerType PickerType;


@interface MMLPickerView : UIPickerView
@property (assign, nonatomic) PickerType pickerType; // Default is DatePicker

- (id)init;
- (id)initWithPickerType:(PickerType)pickerType;

- (Date *)selectedDate;

@end

