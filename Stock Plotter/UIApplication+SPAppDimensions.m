//
//  UIApplication+SPAppDimensions.m
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Change History:
//

// #import "UIApplication+SPAppDimensions.h"  //  Not needed as declarations' in app's plist

@implementation UIApplication (SPAppDimensions)

+(CGSize) viewSize
{
    return [UIApplication sizeInCurrentOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(CGSize) sizeInCurrentOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];

    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

@end