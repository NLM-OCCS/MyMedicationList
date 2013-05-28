/*
     File: OverlayViewController.m 
 Abstract: The secondary view controller managing the overlap view to the camera.
  
  Version: 1.2 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "OverlayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GKImageCropViewController.h"
@interface OverlayViewController ()<GKImageCropControllerDelegate>   // Modified to suits our needs.
@property (nonatomic, retain) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *toggleCameraButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)done:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction) toggleCamera:(id)sender;
- (UIImageView *)blankImageView;

@end

@implementation OverlayViewController

@synthesize delegate,cancelButton,takePictureButton,toggleCameraButton,imagePickerController,imageSize;

#pragma mark -
#pragma mark OverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        
        self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
        self.imagePickerController.delegate = self;
    }
    return self;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)viewDidUnload
{
    self.takePictureButton = nil;
    self.toggleCameraButton = nil;
    self.cancelButton = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    self.takePictureButton = nil;
    self.cancelButton = nil;
    self.toggleCameraButton = nil;
    self.imagePickerController = nil;
    [super dealloc];
}

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController.sourceType = sourceType;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        self.imagePickerController.showsCameraControls = NO;
        self.imagePickerController.editing = YES;
        
        if ([[self.imagePickerController.cameraOverlayView subviews] count] == 0)
        {
            CGRect overlayViewFrame = self.imagePickerController.cameraOverlayView.frame;
            CGRect newFrame = CGRectMake(0.0,
                                         CGRectGetHeight(overlayViewFrame) -
                                         self.view.frame.size.height - 10.0,
                                         CGRectGetWidth(overlayViewFrame),
                                         self.view.frame.size.height + 10.0);
            self.view.frame = newFrame;
            [self.imagePickerController.cameraOverlayView addSubview:self.view];
        }
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    NSLog(@"I am in OverlayViewController View DidLoad1 warning.....");

}
- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
    NSLog(@"I am in OverlayViewController memory warning.....");
}
#pragma mark -

- (void)finishAndUpdate
{
    [self.delegate didFinishWithCamera];
    self.cancelButton.enabled = YES;
    self.takePictureButton.enabled = YES;
}
- (void) flipCamera:(UIImageView *) imgView {
    [UIView transitionWithView:self.imagePickerController.view duration:1.25f
                       options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        imgView.alpha = 0;
                        self.imagePickerController.cameraViewTransform =
                        CGAffineTransformScale(self.imagePickerController.cameraViewTransform, -1,     1);
                    } completion:^(BOOL finished) {
                        [imgView removeFromSuperview];
                        self.imagePickerController.view.userInteractionEnabled = YES;
                    } ];
}

- (UIImageView *)blankImageView {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIImageView *imageView = [[[UIImageView alloc]initWithFrame:rect] autorelease];
    UIGraphicsBeginImageContext(rect.size);
    [imageView.image drawInRect:imageView.bounds];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageView;
    
}

#pragma mark -
#pragma mark Camera Actions

- (IBAction)done:(id)sender
{
    [self finishAndUpdate];
}

- (IBAction)takePhoto:(id)sender
{
    [self.imagePickerController takePicture];
}

- (void) toggleCamera:(id)sender {     
    UIImageView *imgView = [self blankImageView] ;
    if(self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    [self.imagePickerController.view addSubview:imgView];
    [self.imagePickerController.view setNeedsDisplay];
    [self performSelector:@selector(flipCamera:) withObject:imgView afterDelay:0.5]; // THis is not good but cannot help....:)
    self.imagePickerController.view.userInteractionEnabled = NO;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    int tag = picker.view.tag;
    UIImage *picture = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (picture.imageOrientation == UIImageOrientationUp)  {
         
//            if (self.delegate) {
//                [self.delegate didTakePicture:dict];
//                [self.delegate didFinishWithCamera];
//                return;
//            }
            GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
          //  cropController.contentSizeForViewInPopover = picker.contentSizeForViewInPopover;
            cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            cropController.resizeableCropArea = YES;
            cropController.cropSize = CGSizeMake(300,300);
            cropController.delegate = self;
            cropController.view.tag  = tag;
            [picker pushViewController:cropController animated:YES];
            [cropController release];
            return;
        }
        CGAffineTransform transform = CGAffineTransformIdentity;
        switch (picture.imageOrientation) {
            case UIImageOrientationUpMirrored:
                transform = CGAffineTransformTranslate(transform, picture.size.width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, picture.size.width, picture.size.height);
                transform = CGAffineTransformRotate(transform, M_PI);
                if (picture.imageOrientation == UIImageOrientationDownMirrored) {
                    transform = CGAffineTransformTranslate(transform, picture.size.width, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                }
                break;
                
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                transform = CGAffineTransformTranslate(transform, picture.size.width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
                if (picture.imageOrientation == UIImageOrientationLeftMirrored) {
                    transform = CGAffineTransformTranslate(transform, picture.size.height, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                }
                break;
                
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, picture.size.height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
                if (picture.imageOrientation == UIImageOrientationRightMirrored) {
                    transform = CGAffineTransformTranslate(transform, picture.size.height, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                }
                break;
            default:
                break;
        }
        CGContextRef ctx = CGBitmapContextCreate(NULL, picture.size.width, picture.size.height,
                                                 CGImageGetBitsPerComponent(picture.CGImage), 0,
                                                 CGImageGetColorSpace(picture.CGImage),
                                                 CGImageGetBitmapInfo(picture.CGImage));
        CGContextConcatCTM(ctx, transform);
        switch (picture.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                CGContextDrawImage(ctx, CGRectMake(0,0,picture.size.height,picture.size.width), picture.CGImage);
                break;
                
            default:
                CGContextDrawImage(ctx, CGRectMake(0,0,picture.size.width,picture.size.height), picture.CGImage);
                break;
        }       
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
       // UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
    //    cropController.contentSizeForViewInPopover = picker.contentSizeForViewInPopover;
        cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        cropController.resizeableCropArea = YES;
        cropController.cropSize = CGSizeMake(300,300);
        cropController.delegate = self;
        cropController.view.tag  = tag;
        [picker pushViewController:cropController animated:YES];
        [cropController release];

        return;
//        if (self.delegate) {
//            [self.delegate didTakePicture:dict];
//            [self.delegate didFinishWithCamera];
//            return;
//        }
    } else {
        GKImageCropViewController *cropController = [[GKImageCropViewController alloc] init];
    //    cropController.contentSizeForViewInPopover = picker.contentSizeForViewInPopover;
        cropController.sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        cropController.resizeableCropArea = YES;
        cropController.cropSize = CGSizeMake(300,300);
        cropController.delegate = self;
        cropController.view.tag  = tag;
        [picker pushViewController:cropController animated:YES];
        [cropController release];
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:(UIImage *)picture,UIImagePickerControllerOriginalImage,
//                              [NSString stringWithFormat:@"%d",tag], @"tag", nil];
//        if (self.delegate)
//            [self.delegate didTakePicture:dict];
//        [self.delegate didFinishWithCamera];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate didFinishWithCamera];
}



#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    int tag = imageCropController.view.tag;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:(UIImage *)croppedImage,UIImagePickerControllerOriginalImage,
                          [NSString stringWithFormat:@"%d",tag], @"tag",imageCropController.sourceImage, @"OriginalPicture", nil];

    [self.delegate didTakePicture:dict];
    [self.delegate didFinishWithCamera];

}

@end

