//
//  Exchange.h
//  Stock Plotter
//
//  Created by Paul Duncanson on 11/2/13.
//  Copyright (c) 2013 Paul Duncanson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Exchange : NSManagedObject

@property (nonatomic, retain) NSDate * closeTime;
@property (nonatomic, retain) NSString * exchangeCode;
@property (nonatomic, retain) NSString * exchangeName;
@property (nonatomic, retain) NSDate * openTime;

@end
