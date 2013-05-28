//
//  PictureViewerViewController.h
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import <UIKit/UIKit.h>

@protocol PictureViewerDelegate;

@interface PictureViewerViewController : UIViewController<UIScrollViewDelegate>
@property (strong,nonatomic) UIImage *cardImage;
@property (assign,nonatomic) id<PictureViewerDelegate> delegate;
- (IBAction)dismiss:(id)sender;

@end


@protocol PictureViewerDelegate <NSObject>
@required
- (void)pictureViewerDidDismiss:(PictureViewerViewController *)pictureViewerViewController;

@end
