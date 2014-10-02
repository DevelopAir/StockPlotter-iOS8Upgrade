//
//  StockType.h
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Copyright (c) 2013 Paul Duncanson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StockType : NSManagedObject

@property (nonatomic, retain) NSString * stockType;
@property (nonatomic, retain) NSString * stockTypeName;
//@property (nonatomic, retain) NSManagedObject *newRelationship;

@end
