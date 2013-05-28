//
//  MMLCustomSubTitleTableViewCell.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MMLCustomSubTitleTableViewCell.h"

@implementation MMLCustomSubTitleTableViewCell

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
- (void)setFrame:(CGRect)frame {
    frame.origin.x += 80;
    frame.size.width -= 1 * 80;
    [super setFrame:frame];
}
@end
