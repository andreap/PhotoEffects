//
//  PhotoProcessController.h
//  PhotoEffects
//
//  Created by Vincenzo Romano on 29/11/12.
//  Copyright (c) 2012 Vincenzo Romano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoProcessingController : UIViewController<UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate>{
    UIImage *img;
    UIImageView *image;
    UIImageView *dotted;
    UIPopoverController *popover;
}

@end
