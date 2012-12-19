//
//  UIImage+JTEditor.h
//  JTPhotoEditing
//
//  Created by Joy Tao on 12/18/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JTEditor)

-(UIImage*)autoEnhance ; 
-(UIImage*)redEyeCorrection;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;

@end
