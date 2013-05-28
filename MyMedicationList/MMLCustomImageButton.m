//
//  MMLCustomImageButton.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "MMLCustomImageButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation MMLCustomImageButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) removeLayer:(NSString *)layerName {
    NSArray *layers = [NSArray arrayWithArray:[[self layer] sublayers]];
    
    for (int i = 0; i < [layers count] ; i++) {
        CALayer *layer = [layers objectAtIndex:i];
        if ([layer.name isEqualToString:layerName]) {
            [layer removeFromSuperlayer];
        }
    }
}

- (void) addImageLayer:(NSString *)name withImage:(UIImage *)image {
    CALayer *layer1 = [CALayer layer];
    [layer1 setName:name];
    layer1.contents = (id)image.CGImage;
    layer1.frame =  CGRectMake(0,0, image.size.width , image.size.height);
    [layer1 setBounds:layer1.frame];
    [self.layer addSublayer:layer1];
}

- (void) addBottomTextLayer:(NSString *)layerName withText:(NSString *)text {
    CATextLayer *label = [[CATextLayer alloc] init];
    [label setName:layerName];
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    CGFontRef font1 = CGFontCreateWithFontName((CFStringRef)font.fontName);
    [label setFont:font1];
    CGFontRelease(font1);
    [label setFontSize:13];
    [label setFrame:CGRectMake(0.0f, self.frame.size.height-15.0f, self.frame.size.width , 15.0f)];
    [label setString:text];
    [label setAlignmentMode:kCAAlignmentCenter];
    [label setWrapped:YES];
    [label setForegroundColor:[[UIColor blackColor] CGColor]];
    [label setBackgroundColor:[[UIColor grayColor] CGColor]];
    label.opacity = 0.7f;
    label.cornerRadius = 10.0f;
    [[self layer] addSublayer:label];
    [label release];

}

- (void) addTextLayer:(NSString *)layerName withText:(NSString *)text {
    CATextLayer *label = [[CATextLayer alloc] init];
    [label setName:layerName];
    UIFont *font = [UIFont systemFontOfSize:14];
    CGFontRef font1 = CGFontCreateWithFontName((CFStringRef)font.fontName);
    [label setFont:font1];
    CGFontRelease(font1);
    [label setFontSize:14];
    CGSize constraint = CGSizeMake(self.frame.size.width, MAXFLOAT);
    CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    //CGFloat midPointY = self.frame.size.height/2.0f;
    CGFloat textLayerY = (self.frame.size.height - size.height)/2.0f;
    CGFloat textLayerX = (self.frame.size.width - size.width)/2.0f;
    [label setFrame:CGRectMake(textLayerX, textLayerY, size.width,size.height)];
    [label setString:text];
    [label setAlignmentMode:kCAAlignmentCenter];
    [label setWrapped:YES];
    [label setForegroundColor:[[UIColor grayColor] CGColor]];
    [[self layer] addSublayer:label];
    [label release];
}

- (void) addDashedBorderLayer:(NSString *) layerName withDashDistance:(int)spacing {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setName:layerName];
    CGRect shapeRect = CGRectMake(0,0, self.frame.size.width , self.frame.size.height);
    [shapeLayer setBounds:shapeRect];
    // [shapeLayer setPosition:[addPhotoBtn center]];
    [shapeLayer setFrame:shapeRect];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor grayColor] CGColor]];
    [shapeLayer setLineWidth:1.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:spacing],
      [NSNumber numberWithInt:spacing],
      nil]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:10.0];
    [shapeLayer setPath:path.CGPath];
    [[self layer] addSublayer:shapeLayer];

    
}
@end
