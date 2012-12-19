//
//  EditorViewController.h
//  JTPhotoEditing
//
//  Created by Joy Tao on 12/18/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditorViewController : UIViewController <UIScrollViewDelegate>

{
    bool isTappedInCropView;
	bool isTappedOnUpperLeftCorner;
	bool isTappedOnUpperRightCorner;
	bool isTappedOnLowerLeftCorner;
	bool isTappedOnLowerRightCorner;
}
@end
