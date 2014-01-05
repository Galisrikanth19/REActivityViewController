//
//  REInstagramActivity.m
//  Pods
//
//  Created by Admin on 1/3/14.
//
//

#import "REInstagramActivity.h"

@implementation REInstagramActivity

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    self = [super initWithTitle:NSLocalizedStringFromTable(@"activity.Instagram.title", @"REActivityViewController", @"Instagram")
                          image:[UIImage imageNamed:@"REActivityViewController.bundle/Icon_Instagram"]
                    actionBlock:nil];
    if (!self)
        return nil;
    
    _consumerKey = consumerKey;
    _consumerSecret = consumerSecret;
    
    
    __typeof(&*self) __weak weakSelf = self;
    self.actionBlock = ^(REActivity *activity, REActivityViewController *activityViewController) {
        NSDictionary *userInfo = weakSelf.userInfo ? weakSelf.userInfo : activityViewController.userInfo;
        
        
        if (![self canOpenInstagram]) {
            
            
            [weakSelf showAuthErrorAlert];
        } else {
            
            
            [activityViewController dismissViewControllerAnimated:YES completion:^{
                NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"RETumblrActivity_Email"];
                NSString *password = [SFHFKeychainUtils getPasswordForUsername:email andServiceName:@"RETumblrActivity" error:nil];
                
                NSLog(@"email = %@",email);
                NSLog(@"password = %@",password);
                
                
                [weakSelf authenticateWithUsername:email
                                          password:password success:^(AFXAuthClient *client) {
                                              [weakSelf shareUserInfo:userInfo client:client];
                                          } failure:^(NSError *error) {
                                              [weakSelf showAuthDialogWithActivityViewController:activityViewController];
                                              [weakSelf showAuthErrorAlert];
                                          }];
            }];
        }
    };
    
    return self;

}

//- (BOOL)canOpenInstagram {
//    
//    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
//    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) return NO; // no instagram.
//    
////    for (UIActivityItemProvider *item in activityItems) {
////        if ([item isKindOfClass:[UIImage class]]) {
////            if ([self imageIsLargeEnough:(UIImage *)item]) return YES; // has image, of sufficient size.
////            else NSLog(@"DMActivityInstagam: image too small %@",item);
////        }
////    }
//    return YES;
//}



- (void)showAuthErrorAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"activity.Tumblr.authentication.title", @"REActivityViewController", @"Tumblr")
                                                        message:NSLocalizedStringFromTable(@"activity.Tumblr.authentication.error", @"REActivityViewController", @"Please check your e-mail and password. If you're sure they're correct, Tumblr may be temporarily experiencing problems. Please try again in a few minutes.")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedStringFromTable(@"button.dismiss", @"REActivityViewController", @"Dismiss")
                                              otherButtonTitles:nil];
    [alertView show];
}

/// ****************************

-(void)ShareInstagram
{
    [self storeimage];
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        
        CGRect rect = CGRectMake(0 ,0 , 612, 612);
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/15717.ig"];
        
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
        dic.UTI = @"com.instagram.photo";
        dic.delegate=self;
        dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
        dic=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        dic.delegate=self;
        [dic presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
        //  [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else
    {
        //   NSLog(@"instagramImageShare");
        UIAlertView *errorToShare = [[UIAlertView alloc] initWithTitle:@"Instagram unavailable " message:@"You need to install Instagram in your device in order to share this image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        errorToShare.tag=3010;
        [errorToShare show];
    }
}


- (void) storeimage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"15717.ig"];
    UIImage *NewImg=[self resizedImage:imageCapture :CGRectMake(0, 0, 612, 612) ];
    NSData *imageData = UIImagePNGRepresentation(NewImg);
    [imageData writeToFile:savedImagePath atomically:NO];
}

-(UIImage*) resizedImage:(UIImage *)inImage: (CGRect) thumbRect
{
    CGImageRef imageRef = [inImage CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    
    // There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
    // see Supported Pixel Formats in the Quartz 2D Programming Guide
    // Creating a Bitmap Graphics Context section
    // only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
    // and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
    // The images on input here are likely to be png or jpeg files
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    // Build a bitmap context that's the size of the thumbRect
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,       // width
                                                thumbRect.size.height,      // height
                                                CGImageGetBitsPerComponent(imageRef),   // really needs to always be 8
                                                4 * thumbRect.size.width,   // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, thumbRect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    
    return result;
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    
    
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    interactionController.delegate = self;
    
    return interactionController;
}

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action
{
    //    NSLog(@"5dsklfjkljas");
    return YES;
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller performAction:(SEL)action
{ 
    //    NSLog(@"dsfa");
    return YES;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    //    NSLog(@"fsafasd;");
}


@end
