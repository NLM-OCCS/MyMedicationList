//
//  PictureEncasingView.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "PictureEncasingView.h"

@interface  PictureEncasingView (){
    UIImageView  *_encaseImageView;
}

@end


@implementation PictureEncasingView
@synthesize encasedImage = _encasedImage;
@synthesize interfaceOrientation = _interfaceOrientation;

static const CGRect PORTRAITFRAME = {{0,0},{320,480}};
static const CGRect PORTRAITFRAME_ENCASEDVIEW = {{0,120},{320,190}};
static const CGRect LANDSCAPEFRAME = {{0,0},{480,320}};

- (id)initWithEncasedImage:(UIImage *)encasedImage
{
    NSLog(@"initWithEncasedImage");
    self = [super initWithFrame:PORTRAITFRAME];
    if(self)
    {
        _encaseImageView = [[UIImageView alloc] initWithFrame:PORTRAITFRAME];
        self.encasedImage = encasedImage;
        _encaseImageView.image = self.encasedImage;
        [self addSubview:_encaseImageView];
    }
    
    return self;
}


- (void)dealloc {
    self.encasedImage = nil;
    [_encaseImageView release];
    [super dealloc];
}

- (void)setEncasedImage:(UIImage *)encasedImage
{
    if (_encasedImage != encasedImage) 
    {
        [_encasedImage release];
        _encasedImage = encasedImage;
        _encaseImageView.image = _encasedImage;
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == _interfaceOrientation)
        return;
    else
    {
        CGFloat landscapeWidth = 480.0f;
        CGFloat landscapeHeight = (((float)190)/320)*landscapeWidth;        
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            self.frame = LANDSCAPEFRAME;
            _encaseImageView.frame = CGRectMake(0, (320-landscapeHeight)/2.0, landscapeWidth, landscapeHeight);
        }
        else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
            self.frame = LANDSCAPEFRAME;            
            _encaseImageView.frame = CGRectMake(0, (320-landscapeHeight)/2.0, landscapeWidth, landscapeHeight);
        }
        else if (interfaceOrientation == UIInterfaceOrientationPortrait)
        {
            self.frame = PORTRAITFRAME;
            _encaseImageView.frame = PORTRAITFRAME_ENCASEDVIEW;
        }
        
        _interfaceOrientation = interfaceOrientation;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
