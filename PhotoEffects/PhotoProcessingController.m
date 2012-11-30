//
//  PhotoProcessController.m
//  PhotoEffects
//
//  Created by Vincenzo Romano on 29/11/12.
//  Copyright (c) 2012 Vincenzo Romano. All rights reserved.
//

#import "PhotoProcessingController.h"
#import <QuartzCore/QuartzCore.h>

@interface PhotoProcessingController ()

@end

@implementation PhotoProcessingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    img = [UIImage imageNamed:@"heart.jpg"];
    image = [[UIImageView alloc] initWithImage:img];
    
    UIScreen *screen = [UIScreen mainScreen];
    float _x = (screen.bounds.size.width - image.bounds.size.width)/2;
    float _y = (screen.bounds.size.height - image.bounds.size.height)/2;
    image.frame = CGRectMake(_x, _y, image.bounds.size.width, image.bounds.size.height);
    
    [self.view addSubview:image];
    
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, 44)];
    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, 44)];
    [toolbar setBarStyle: UIBarStyleBlackTranslucent];

    UIBarButtonItem *choose = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStyleBordered target:self action:@selector(chooseImage:)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveImage:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:choose, save, nil] animated:NO];
    
    [bar addSubview:toolbar];
    
    UIButton *apply = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [apply setTitle:@"Apply" forState:UIControlStateNormal];
    [apply addTarget:self action:@selector(setFilter:) forControlEvents:UIControlEventTouchUpInside];
    apply.frame = CGRectMake(screen.bounds.size.width/2-75, screen.bounds.size.height-85, 150, 50);
    
    [self.view addSubview:bar];
    [self.view addSubview:apply];
    
    [bar release];
    [toolbar release];
    [choose release];
    [save release];
}

- (void)chooseImage:(id)sender {
    if(popover){
        [popover dismissPopoverAnimated:YES];
        [popover release];
        popover = nil;
        return;
    }
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    popover = [[UIPopoverController alloc] initWithContentViewController:picker];
    popover.delegate = self;
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	img = [info objectForKey:UIImagePickerControllerOriginalImage];
	[image setImage:img];
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)saveImage:(id)sender{
    UIImageWriteToSavedPhotosAlbum(image.image, nil, nil, nil);
}

- (void)setFilter:(id)sender{
    CGImageRef imageRef = [img CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
	
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
	
    int byteIndex = 0;
    
    dotted = [[UIImageView alloc] initWithFrame:image.frame];
    
    int cell = 9;
    for (int y = 0; y<height; y+=cell){
        byteIndex = y*(width*4);
        for(int x = 0; x<width; x+=cell){
            CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
            CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
            CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
            
            
            CGPathRef circlePath = CGPathCreateMutable();
            int tmpIndex = (x + (y * width))*4;
            float brightness = (0.299*rawData[tmpIndex] + 0.587*rawData[tmpIndex+1] + 0.114*rawData[tmpIndex+2]);
            float radius =  cell * (brightness/255);
            
            CGPathAddEllipseInRect(circlePath , NULL , CGRectMake( x,y,radius*2,radius*2 ) );
            CAShapeLayer *circle = [[CAShapeLayer alloc] init];
            circle.path = circlePath;
            circle.opacity = 1.0;
            circle.fillColor = [[UIColor colorWithRed:red green:green blue:blue alpha:1.0] CGColor];
            [dotted.layer addSublayer:circle];
            CGPathRelease(circlePath);
            [circle release];
            
            
            byteIndex+=(cell*4);
        }
    }
    
    UIGraphicsBeginImageContext(image.frame.size);
    context = UIGraphicsGetCurrentContext();
    [dotted.layer renderInContext:context];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image setImage:img];
    [dotted release];

    [self.view addSubview:image];
    
	free(rawData);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
