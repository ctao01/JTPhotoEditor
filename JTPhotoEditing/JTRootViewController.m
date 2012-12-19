//
//  JTRootViewController.m
//  JTPhotoEditing
//
//  Created by Joy Tao on 12/19/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "JTRootViewController.h"
#import "EditorViewController.h"
#import "UIImage+JTEditor.h"

@interface JTRootViewController ()

@property (nonatomic , strong) UIImageView * imageView;

@end

@implementation JTRootViewController
@synthesize jtImage = _jtImage;
@synthesize imageView = _imageView;

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
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(presentPhotoEditor)];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 240.0f)];
//    self.imageView.backgroundColor = [UIColor grayColor];
//    self.imageView.layer.borderWidth = 2.0f;
//    self.imageView.layer.borderColor = [[UIColor whiteColor]CGColor];
//    self.imageView.layer.shadowColor = [[UIColor lightGrayColor]CGColor];
//    self.imageView.layer.shadowOffset= CGSizeMake(3.0f, 3.0f);
//    self.imageView.layer.shadowRadius = 3.0f;
//    self.imageView.layer.shadowOpacity = 1.0f;
    
    
    [self.view addSubview:self.imageView];
    
    CGPoint center = self.view.center;
    CGPoint newCenter = CGPointMake(center.x, center.y - 44.0f);
    
    [self.imageView setCenter:newCenter];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewController Set Up

- (void) presentPhotoEditor
{
    EditorViewController * vc = [[EditorViewController alloc]init];

    [self.navigationController pushViewController:vc animated:YES];
    [vc.view setBackgroundColor:[UIColor blackColor]];
//    [self presentViewController:nc animated:YES completion:^{
//        vc.view.backgroundColor = [UIColor blackColor];
//    }];
}

#pragma mark -

- (void) setJtImage:(UIImage *)newJTImage
{
    [self.imageView setImage:[newJTImage imageByScalingProportionallyToSize:self.imageView.frame.size]];
    [self.imageView setNeedsDisplay];

    self.navigationItem.title = @"Result";
}

@end
