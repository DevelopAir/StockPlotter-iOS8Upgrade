//
//  UIApplication+SPAppDimensions.h
//  Stock Plotter
//
//  Created by Paul Duncanson on 9/28/13.
//  Change History:
//

#import <UIKit/UIKit.h>

@interface UIApplication (SPAppDimensions)
    +(CGSize) viewSize;
    +(CGSize) sizeInCurrentOrientation:(UIInterfaceOrientation)orientation;
@end
