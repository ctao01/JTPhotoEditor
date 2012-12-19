//
//  EditorViewController.m
//  JTPhotoEditing
//
//  Created by Joy Tao on 12/18/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "EditorViewController.h"
#import "UIImage+JTEditor.h"
#import "JTRootViewController.h"

#define ktapDiff 10
#define kWidthDifference 30
#define kHeightDifference 30

@interface CropView : UIView

@property (nonatomic) CGRect cropFrame;
@property (nonatomic , strong) UIColor * rectColor;
@property (nonatomic , strong) UIColor * strokeColor;

- (id) initWithOuterFrame:(CGRect)outerFrame andInnerFrame:(CGRect)innerFrame;

@end

@implementation CropView
@synthesize cropFrame, strokeColor, rectColor;

- (id) initWithOuterFrame:(CGRect)outerFrame andInnerFrame:(CGRect)innerFrame
{
    self = [super initWithFrame:outerFrame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.rectColor = [UIColor colorWithWhite:0.0f alpha:0.75];
        self.strokeColor = [UIColor blackColor];
        self.cropFrame = innerFrame;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect outerRect = self.frame;
    CGRect innerRect  = self.cropFrame;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:outerRect cornerRadius:0.0f];
    
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:0.0f]];
    path.usesEvenOddFillRule = YES;
    
    [self.rectColor set];
    [path fill];
}

@end


@interface EditorViewController ()
{
    BOOL isAutoEnhance;
    int currentAngle;
    
    UIScrollView * scrollView;
    UIImageView * imageView;
    
    /******************************************************/ 
    
    UIView *overlayView;
    CropView * cropView;
    
    CGFloat cropTL_y; //top Left
    CGFloat cropTR_x; //top Right
    CGFloat cropBR_y; // Botton Right
    CGFloat cropBL_x;
    
    UIImageView * ivleftUp ;
	UIImageView * ivRightUp ;
	UIImageView * ivleftDown ;
	UIImageView * ivRightDown;
    /******************************************************/

}
@end

@implementation EditorViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isAutoEnhance = NO;
    currentAngle = 0;
    
    CGRect bounds = self.view.frame;
    UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, bounds.size.width, 44.0f)];

    toolBar.barStyle = UIBarStyleBlackOpaque;
    
     UIBarButtonItem * spaceItme = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
	UIBarButtonItem * rotateItem = [[UIBarButtonItem alloc]initWithTitle:@"Rotate" style:UIBarButtonItemStyleBordered target:self action:@selector(rotateLeft)];
    UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"Ehance:%@",isAutoEnhance?@"YES":@"NO"] style:UIBarButtonItemStyleBordered target:self action:@selector(autoEnhance:)];
    
    UIBarButtonItem * cropItem = [[UIBarButtonItem alloc]initWithTitle:@"Crop" style:UIBarButtonItemStyleBordered target:self action:@selector(cropPhoto)];
    
    [toolBar setItems:[NSArray arrayWithObjects:rotateItem, spaceItme, enhanceItem, spaceItme, cropItem, nil]];
    [toolBar setFrame:CGRectMake(bounds.origin.x,
                                 bounds.size.height - toolBar.frame.size.height - CGRectGetHeight(self.navigationController.navigationBar.frame),
                                 bounds.size.width,
                                 toolBar.frame.size.height)];
    [self.view addSubview:toolBar];

    
    scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    scrollView.delegate = self;
	scrollView.backgroundColor = [UIColor blackColor];
	imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MG_4916-Edit.jpg"]];
	[scrollView addSubview:imageView];
	scrollView.minimumZoomScale = scrollView.frame.size.width / imageView.frame.size.width;
	scrollView.maximumZoomScale = 2.0;
    
	[scrollView setZoomScale:scrollView.minimumZoomScale];
	[self.view addSubview:scrollView];
	[self.view sendSubviewToBack:scrollView];
    scrollView.frame = CGRectOffset(scrollView.frame, 0.0f, - 68.0f);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissEditor)];
    self.navigationItem.title = @"Editor";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissEditor
{    
    JTRootViewController * rvc = (JTRootViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    
    UIImage * newImage ;
    if (currentAngle == -90)
        newImage = [[UIImage alloc] initWithCGImage:[imageView image].CGImage scale:1 orientation:UIImageOrientationLeft];
    else if (currentAngle == -180)
        newImage = [[UIImage alloc] initWithCGImage:[imageView image].CGImage scale:1 orientation:UIImageOrientationDown];
    else if (currentAngle == -270)
        newImage = [[UIImage alloc] initWithCGImage:[imageView image].CGImage scale:1 orientation:UIImageOrientationRight];
    else
        newImage = [[UIImage alloc] initWithCGImage:[imageView image].CGImage scale:1 orientation:UIImageOrientationUp];

    
    [rvc setJtImage:newImage];
    
    [self.navigationController popToViewController:rvc animated:YES];
}

#pragma mark -

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
	CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
	
	return frameToCenter;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollV {
	imageView.frame = [self centeredFrameForScrollView:scrollV andUIView:imageView];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}
#pragma mark -

- (void) rotateLeft
{
    currentAngle = currentAngle - 90.0f;
    if (currentAngle == -360) currentAngle = 0.0;
    CGAffineTransform rotate = CGAffineTransformMakeRotation( currentAngle / 180.0 * 3.14 );
	[scrollView setTransform:rotate];
    
}

- (void) autoEnhance:(id)sender
{
    UIBarButtonItem * button = (UIBarButtonItem*)sender;
    UIImage * originImage = imageView.image;

    if (isAutoEnhance == NO)
    {
        UIImage * enhancedImage =[originImage autoEnhance];
        [imageView setImage:enhancedImage];
        isAutoEnhance = YES;
    }
    else
    {
        [imageView setImage:originImage];
        isAutoEnhance = NO;
    }
    [imageView setNeedsDisplay];
    button.title = [NSString stringWithFormat:@"Enhance:%@",isAutoEnhance?@"YES":@"NO"];
    
}

/******************************************************************************************/
- (void) cropPhoto
{
    CGRect cropFrame = CGRectMake(40.0f, 40.0f, 240, 320.0f);
    cropTL_y = cropFrame.origin.y;
    cropTR_x = cropFrame.origin.x + cropFrame.size.width;
    cropBR_y = cropFrame.origin.y + cropFrame.size.height;
    cropBL_x = cropFrame.origin.x;
    
    cropView = [[CropView alloc]initWithOuterFrame:self.view.frame andInnerFrame:cropFrame];
    [self.view addSubview:cropView];
    [cropView setNeedsDisplay];
    
    UIImage * cropPointImg = [UIImage imageNamed:@"cropPoint.png"];
	ivleftUp = [[UIImageView alloc]initWithImage:cropPointImg];
	ivRightUp = [[UIImageView alloc]initWithImage:cropPointImg];
	ivleftDown = [[UIImageView alloc]initWithImage:cropPointImg];
	ivRightDown = [[UIImageView alloc]initWithImage:cropPointImg];
	
	ivleftUp.center = CGPointMake(cropBL_x, cropTL_y);
	ivleftDown.center = CGPointMake(cropBL_x, cropBR_y);;
	ivRightUp.center = CGPointMake(cropTR_x, cropTL_y);
	ivRightDown.center = CGPointMake(cropTR_x, cropBR_y);;
	
	[cropView addSubview:ivleftUp];
	[cropView addSubview:ivleftDown];
	[cropView addSubview:ivRightUp];
	[cropView addSubview:ivRightDown];
    
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCrop)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCrop)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void) doneCrop
{
    CGRect rect = CGRectMake(cropBL_x, cropTL_y, cropTR_x - cropBL_x, cropBR_y - cropTL_y);
    CGSize imageViewSize = imageView.frame.size;
    
    UIImage * originImage = imageView.image;
    UIImage * image = [[UIImage alloc]imageByCropping:[originImage imageByScalingProportionallyToSize:imageViewSize] toRect:rect];
    imageView.image = image;
    [imageView setNeedsDisplay];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissEditor)];
    [cropView removeFromSuperview];
}

- (void) cancelCrop
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissEditor)];
    [cropView removeFromSuperview];
}
- (void)ControlCropView:(NSSet *)touches {
	
    
    CGPoint movedPoint = [[touches anyObject] locationInView:self.view];
    
    if ((fabs(movedPoint.x - cropBL_x)<=ktapDiff)&&(fabs(movedPoint.y -cropTL_y)<= ktapDiff))
        //    if ((abs(movedPoint.x - cropBL_x)<ktapDiff) && ((cropTL_y -movedPoint.y <= ktapDiff)||(cropTL_y -movedPoint.y <= ktapDiff)))
    {
        NSLog(@"Touched upper left corner");
        isTappedOnUpperLeftCorner = TRUE;
    }
    else if((fabs(movedPoint.x - cropTR_x)<=ktapDiff)&&(fabs(movedPoint.y -cropTL_y)<= ktapDiff))
        //    else if(((movedPoint.x - cropTR_x <= ktapDiff)||(cropTR_x - movedPoint.x <= ktapDiff)) && ((cropTL_y -movedPoint.y <= ktapDiff)||(cropTL_y -movedPoint.y <= ktapDiff)))
    {
        NSLog(@"Touched upper Right corner");
        isTappedOnUpperRightCorner = TRUE;
    }
    else if((fabs(movedPoint.x - cropTR_x)<=ktapDiff)&&(fabs(movedPoint.y -cropBR_y)<= ktapDiff))
        
        //    else if (((movedPoint.x - cropTR_x <= ktapDiff)||(cropTR_x -movedPoint.x <= ktapDiff)) && ((cropBR_y -movedPoint.y <= ktapDiff)||(cropBR_y -movedPoint.y <= ktapDiff)))
        
    {
        NSLog(@"Touched lower Right corner");
        isTappedOnLowerRightCorner = TRUE;
        
    }
    else if((fabs(movedPoint.x - cropBL_x)<=ktapDiff)&&(fabs(movedPoint.y -cropBR_y)<= ktapDiff))
        
        //    else if (((movedPoint.x - cropBL_x <= ktapDiff)||(cropBL_x -movedPoint.x <= ktapDiff)) && ((cropBR_y -movedPoint.y <= ktapDiff)||(cropBR_y -movedPoint.y <= ktapDiff)))
    {
        NSLog(@"Touched lower left corner");
        isTappedOnLowerLeftCorner = TRUE;
    }
}

-(void) updateCropPoints
{
	ivleftUp.center = CGPointMake(cropBL_x, cropTL_y);
	ivleftDown.center = CGPointMake(cropBL_x, cropBR_y);;
	ivRightUp.center = CGPointMake(cropTR_x, cropTL_y);
	ivRightDown.center = CGPointMake(cropTR_x, cropBR_y);;
}

#pragma mark -
#pragma mark UITOUCHES Stuff

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self ControlCropView:touches];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	isTappedOnLowerLeftCorner = FALSE;
	isTappedOnLowerRightCorner = FALSE;
	isTappedOnUpperLeftCorner = FALSE;
	isTappedOnUpperRightCorner = FALSE;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //    messageLabel.text = @"Touches Stopped.";
	isTappedOnLowerLeftCorner = FALSE;
	isTappedOnLowerRightCorner = FALSE;
	isTappedOnUpperLeftCorner = FALSE;
	isTappedOnUpperRightCorner = FALSE;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint movedPoint = [[touches anyObject] locationInView:self.view];
    
    CGRect viewFrame = imageView.frame;
    
    if ((movedPoint.x <= 10 && movedPoint.x >= 310))
		return;
	if ((movedPoint.y <= 10  && movedPoint.y >= viewFrame.size.height - 10)) {
		return;
	}
    
    
    if (isTappedOnUpperLeftCorner)
    {
        if (movedPoint.x >= cropView.frame.origin.x + cropView.frame.size.width) return;
        if (movedPoint.y >= cropView.frame.origin.y + cropView.frame.size.height) return;
        
        // TODO: move left
        
        if ((cropBL_x - movedPoint.x) >= kWidthDifference)
        {
            if ((cropTL_y - movedPoint.y)>=kHeightDifference) // move up
                cropTL_y = movedPoint.y;
            else if ((movedPoint.y -cropTL_y)>= kHeightDifference) // move down
                cropTL_y = movedPoint.y;
            else return;
            
            cropBL_x = movedPoint.x;
            
        }
        // TODO: move right
        else if ((movedPoint.x -cropBL_x) >= kWidthDifference)
        {
            if ((cropTL_y - movedPoint.y)>=kHeightDifference) // move up
                cropTL_y = movedPoint.y;
            else if ((movedPoint.y -cropTL_y)>= kHeightDifference) // move down
                cropTL_y = movedPoint.y;
            else return;
            
            cropBL_x = movedPoint.x;
        }
        else return;
    }
    
    else if (isTappedOnUpperRightCorner)
    {
        if (movedPoint.x <= cropView.frame.origin.x) return;
        if (movedPoint.y >= cropView.frame.origin.y + cropView.frame.size.height) return;
        
        if ((cropTR_x - movedPoint.x) >= kWidthDifference)
        {
            if ((cropTL_y - movedPoint.y)>=kHeightDifference) // move up
                cropTL_y = movedPoint.y;
            else if ((movedPoint.y -cropTL_y)>= kHeightDifference) // move down
                cropTL_y = movedPoint.y;
            else return;
            
            cropTR_x = movedPoint.x;
            
        }
        // TODO: move right
        else if ((movedPoint.x -cropTR_x) >= kWidthDifference)
        {
            if ((cropTL_y - movedPoint.y)>=kHeightDifference) // move up
                cropTL_y = movedPoint.y;
            else if ((movedPoint.y -cropTL_y)>= kHeightDifference) // move down
                cropTL_y = movedPoint.y;
            else return;
            
            cropTR_x = movedPoint.x;
        }
        else return;
    }
    
    else if (isTappedOnLowerRightCorner)
    {
        if (movedPoint.x <= cropView.frame.origin.x) return;
        if (movedPoint.y <=cropView.frame.origin.y) return;
        
        if ((cropTR_x - movedPoint.x) >= kWidthDifference)
        {
            if ((cropBR_y - movedPoint.y)>=kHeightDifference) // move up
                cropBR_y = movedPoint.y;
            else if ((movedPoint.y -cropBR_y)>= kHeightDifference) // move down
                cropBR_y = movedPoint.y;
            else return;
            
            cropTR_x = movedPoint.x;
            
        }
        // TODO: move right
        else if ((movedPoint.x -cropTR_x) >= kWidthDifference)
        {
            if ((cropBR_y - movedPoint.y)>=kHeightDifference) // move up
                cropBR_y = movedPoint.y;
            else if ((movedPoint.y -cropBR_y)>= kHeightDifference) // move down
                cropBR_y = movedPoint.y;
            else return;
            
            cropTR_x = movedPoint.x;
        }
        else return;
    }
    
    else if (isTappedOnLowerLeftCorner)
    {
        if (movedPoint.x >= cropView.frame.origin.x + cropView.frame.size.width) return;
        if (movedPoint.y <=cropView.frame.origin.y) return;
        
        
        if ((cropBL_x - movedPoint.x) >= kWidthDifference)
        {
            if ((cropBR_y - movedPoint.y)>=kHeightDifference) // move up
                cropBR_y = movedPoint.y;
            else if ((movedPoint.y -cropBR_y)>= kHeightDifference) // move down
                cropBR_y = movedPoint.y;
            else return;
            
            cropBL_x = movedPoint.x;
            
        }
        // TODO: move right
        else if ((movedPoint.x -cropBL_x) >= kWidthDifference)
        {
            if ((cropBR_y - movedPoint.y)>=kHeightDifference) // move up
                cropBR_y = movedPoint.y;
            else if ((movedPoint.y -cropBR_y)>= kHeightDifference) // move down
                cropBR_y = movedPoint.y;
            else return;
            
            cropBL_x = movedPoint.x;
        }
        else return;
    }
    cropView.cropFrame = CGRectMake(cropBL_x, cropTL_y, cropTR_x - cropBL_x, cropBR_y - cropTL_y);
    [self updateCropPoints];
    [cropView setNeedsDisplay];
    
}
/******************************************************************************************/

@end
