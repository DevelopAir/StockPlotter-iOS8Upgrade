//
//  Stock.h
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Copyright (c) 2013 Paul Duncanson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Exchange, Industry;

@interface Stock : NSManagedObject

@property (nonatomic, retain) NSString * industryCode;
@property (nonatomic, retain) NSString * marketCode;
@property (nonatomic, retain) NSString * stockName;
@property (nonatomic, retain) NSNumber * stockType;
@property (nonatomic, retain) NSString * symbol;
@property (nonatomic, retain) Exchange * exchangeCodeR;
@property (nonatomic, retain) Industry * industryCodeR;

@end
