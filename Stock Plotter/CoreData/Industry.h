//
//  Industry.h
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Copyright (c) 2013 Paul Duncanson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Industry : NSManagedObject

@property (nonatomic, retain) NSString * industryCode;
@property (nonatomic, retain) NSString * industryName;

@end
