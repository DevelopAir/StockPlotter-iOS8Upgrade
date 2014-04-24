//
//  Investments.h
//  Stock Plotter
//
//  Created by Paul Duncanson on 11/2/13.
//  Copyright (c) 2013 Paul Duncanson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Investments : NSManagedObject

@property (nonatomic, retain) NSDate * fromTimeStamp;
@property (nonatomic, retain) NSNumber * shares;
@property (nonatomic, retain) NSString * symbol;
@property (nonatomic, retain) NSDate * toTimeStamp;
@property (nonatomic, retain) NSSet *symbolR;
@end

@interface Investments (CoreDataGeneratedAccessors)

- (void)addSymbolRObject:(NSManagedObject *)value;
- (void)removeSymbolRObject:(NSManagedObject *)value;
- (void)addSymbolR:(NSSet *)values;
- (void)removeSymbolR:(NSSet *)values;

@end
