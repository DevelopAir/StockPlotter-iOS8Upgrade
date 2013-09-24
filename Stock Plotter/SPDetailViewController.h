//
//  SPDetailViewController.h
//  Stock Plotter
//
//  Created by Paul Duncanson on 9/23/13.
//  Copyright (c) 2013 Paul Duncanson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
