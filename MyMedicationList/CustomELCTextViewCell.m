//
//  CustomELCTextViewCell.m
//  MyMedicationList MODIFIED FOR MYMEDLIST
//  ELC Utility
//
//  Copyright 2012 ELC Tech. All rights reserved.
//
/*The MIT License
 
 Copyright (c) 2012 ELC Technologies
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import "CustomELCTextViewCell.h"

#pragma mark ELCInsetTextView

@implementation ELCInsetTextView

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, _inset);
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, _inset);
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, _inset);
}

- (CGRect) leftViewRectForBounds:(CGRect)bounds {
   return UIEdgeInsetsInsetRect(bounds, _leftViewInset);
}
@end

#pragma mark - ELCTextFieldCell

@implementation CustomELCTextViewCell

//using auto synthesizers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		_leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[_leftLabel setBackgroundColor:[UIColor clearColor]];
		[_leftLabel setTextColor:[UIColor colorWithRed:.285 green:.376 blue:.541 alpha:1]];
		//[_leftLabel setFont:[UIFont fontWithName:@"System" size:17]];
        [_leftLabel setFont:[UIFont boldSystemFontOfSize:17]];
		[_leftLabel setTextAlignment:UITextAlignmentRight];
		[self addSubview:_leftLabel];
		
		_rightTextField = [[ELCInsetTextView alloc] initWithFrame:CGRectZero];
		//_rightTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[_rightTextField setDelegate:self];
		[_rightTextField setFont:[UIFont systemFontOfSize:17]];
		[_rightTextField  setBackgroundColor:[UIColor clearColor]];
        //Use Done for all of them.
		[_rightTextField setReturnKeyType:UIReturnKeyDone];
		
		[self addSubview:_rightTextField];
    }
	
    return self;
}

//Layout our fields in case of a layoutchange (fix for iPad doing strange things with margins if width is > 400)
- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect origFrame = self.contentView.frame;
	if (_leftLabel.text != nil) {
        _leftLabel.hidden = NO;
		_leftLabel.frame = CGRectMake(origFrame.origin.x, origFrame.origin.y, 125, origFrame.size.height-1);
		_rightTextField.frame = CGRectMake(origFrame.origin.x+130, origFrame.origin.y, origFrame.size.width-140, origFrame.size.height);
	} else {
		_leftLabel.hidden = YES;
		NSInteger imageWidth = 0;
		if (self.imageView.image != nil) {
			imageWidth = self.imageView.image.size.width + 5;
		}
		_rightTextField.frame = CGRectMake(origFrame.origin.x+imageWidth+10, origFrame.origin.y, origFrame.size.width-imageWidth-20, origFrame.size.height-1);
	}
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (BOOL)textViewShouldReturn:(UITextView *)textField {
	
    BOOL ret = YES;
	if([_delegate respondsToSelector:@selector(textFieldCell:shouldReturnForIndexPath:withValue:)]) {
        ret = [_delegate textFieldCell:self shouldReturnForIndexPath:_indexPath withValue:self.rightTextField.text];
	}
    if(ret) {
        [textField resignFirstResponder];
    }
    return ret;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
	if([string isEqualToString:@"\n"]) {
        if([_delegate respondsToSelector:@selector(textFieldCell:updateTextLabelAtIndexPath:string:)]) {
            [_delegate textFieldCell:self updateTextLabelAtIndexPath:_indexPath string:string];
        }
    }
    
    NSString *textString = self.rightTextField.text;
	textString = [textString stringByReplacingCharactersInRange:range withString:string];
	
	if([_delegate respondsToSelector:@selector(textFieldCell:updateTextLabelAtIndexPath:string:)]) {
		[_delegate textFieldCell:self updateTextLabelAtIndexPath:_indexPath string:textString];
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextView *)textField
{
    if([_delegate respondsToSelector:@selector(updateTextLabelAtIndexPath:string:)]) {
		[_delegate performSelector:@selector(updateTextLabelAtIndexPath:string:) withObject:_indexPath withObject:nil];
	}
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textField
{
    if([_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
		return [_delegate textFieldShouldBeginEditing:(UITextView *)textField];
	}
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    if([_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
		return [_delegate textFieldShouldEndEditing:(UITextView *)textField];
	}
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textField
{
    if([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
		return [_delegate textFieldDidBeginEditing:(UITextView *)textField];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textField
{
    if([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_delegate textFieldDidEndEditing:(UITextView*)textField];
    }
}

- (void)dealloc
{
    _delegate = nil;
    [_rightTextField resignFirstResponder];
	[_leftLabel release];
	[_rightTextField release];
	[_indexPath release];
    [super dealloc];
}

@end

#pragma mark - ELCInsetTextFieldCell

@implementation ELCInsetTextViewCell
- (void)setFrame:(CGRect)frame
{
    [super setFrame:UIEdgeInsetsInsetRect(frame, _inset)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.rightTextField.frame = CGRectInset(self.rightTextField.frame, 0, 4);
}
@end
