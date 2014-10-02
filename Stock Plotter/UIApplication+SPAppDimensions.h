//
//  UIApplication+SPAppDimensions.h
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Change History:
//

#import <UIKit/UIKit.h>

@interface UIApplication (SPAppDimensions)
    +(CGSize) viewSize;
    +(CGSize) sizeInCurrentOrientation:(UIInterfaceOrientation)orientation;
@end
