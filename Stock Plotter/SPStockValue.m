//
//  SPStockValue.m
//  StockGrapher
//
//  Created by Paul Duncanson.
//  Change History:
//

#import "SPStockValue.h"

@interface NSDateFormatter(yahooCSVDateFormatter)

+(NSDateFormatter *)yahooCSVDateFormatter;

@end

@implementation NSDateFormatter(yahooCSVDateFormatter)

+(NSDateFormatter *)yahooCSVDateFormatter
{
    static NSDateFormatter *df = nil;
    
    if ( !df ) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
    }
    return df;
}

@end

@implementation NSDictionary(SPStockValue)

// Parses Comma Separated Values of collected Yahoo stock data into a key-value dictionary entry
+(id)dictionaryWithCSVLine:(NSString *)csvLine
{
    NSArray *csvChunks = [csvLine componentsSeparatedByString:@","];
    
    NSMutableDictionary *csvDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    // Date,Open,High,Low,Close,Volume,Adj Close
    // 2013-09-08,143.82,144.23,139.43,143.85,33255400,143.85
    NSDate *theDate = [[NSDateFormatter yahooCSVDateFormatter] dateFromString:(NSString *)[csvChunks objectAtIndex:0]];
    [csvDict setObject:theDate forKey:@"marketDate"];
    NSDecimalNumber *theOpen = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:1]];
    [csvDict setObject:theOpen forKey:@"openValue"];
    NSDecimalNumber *theHigh = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:2]];
    [csvDict setObject:theHigh forKey:@"high"];
    NSDecimalNumber *theLow = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:3]];
    [csvDict setObject:theLow forKey:@"low"];
    NSDecimalNumber *theClose = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:4]];
    [csvDict setObject:theClose forKey:@"closeValue"];
    NSDecimalNumber *theVolume = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:5]];
    [csvDict setObject:theVolume forKey:@"volumeAmount"];
    NSDecimalNumber *theAdjClose = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:6]];
    [csvDict setObject:theAdjClose forKey:@"adjClose"];
    
    //non-mutable autoreleased dict
    return [NSDictionary dictionaryWithDictionary:csvDict];
}

@end



