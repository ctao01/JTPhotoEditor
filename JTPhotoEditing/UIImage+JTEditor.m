//
//  UIImage+JTEditor.m
//  JTPhotoEditing
//
//  Created by Joy Tao on 12/18/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "UIImage+JTEditor.h"

@implementation UIImage (JTEditor)

-(UIImage*)autoEnhance
{
	/// No Core Image, return original image
	if (![CIImage class])
		return self;
    
	CIImage* ciImage = [[CIImage alloc] initWithCGImage:self.CGImage];
    
	NSArray* adjustments = [ciImage autoAdjustmentFiltersWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIImageAutoAdjustRedEye]];
    
	for (CIFilter* filter in adjustments)
	{
		[filter setValue:ciImage forKey:kCIInputImageKey];
		ciImage = filter.outputImage;
	}
    
	CIContext* ctx = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [ctx createCGImage:ciImage fromRect:[ciImage extent]];
	UIImage* final = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return final;
}

-(UIImage*)redEyeCorrection
{
	/// No Core Image, return original image
	if (![CIImage class])
		return self;
    
	CIImage* ciImage = [[CIImage alloc] initWithCGImage:self.CGImage];
    
	/// Get the filters and apply them to the image
	NSArray* filters = [ciImage autoAdjustmentFiltersWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIImageAutoAdjustEnhance]];
	for (CIFilter* filter in filters)
	{
		[filter setValue:ciImage forKey:kCIInputImageKey];
		ciImage = filter.outputImage;
	}
    
	/// Create the corrected image
	CIContext* ctx = [CIContext contextWithOptions:nil];
	CGImageRef cgImage = [ctx createCGImage:ciImage fromRect:[ciImage extent]];
	UIImage* final = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	return final;
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, imageToCrop.size.width, imageToCrop.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [imageToCrop drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize
{
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
        
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect: thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}
@end
