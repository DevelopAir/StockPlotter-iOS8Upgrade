//
//  SPStockValue.h
//  StockPlotter
//
//  Created by Paul Duncanson.
//  Change History:
//

#import <Foundation/Foundation.h>

@interface NSDictionary(SPStockValue)

+(id)dictionaryWithCSVLine:(NSString *)csvLine;

@end

