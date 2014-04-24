//
//  SPActivityValue.m
//  Stock Plotter
//
//  Created by Paul Duncanson on 10/3/13.
//  Change History:
//

#import "SPActivityValue.h"

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


/*
 uri:/instrument/1.0/GOOG/chartdata;type=quote;range=1d/csv
 ticker:goog
 unit:MIN
 timezone:EDT
 currency:USD
 gmtoffset:-14400
 previous_close:887.0040
 Timestamp:1380720600,1380744000
 labels:1380722400,1380726000,1380729600,1380733200,1380736800,1380740400,1380744000
 values:Timestamp,close,high,low,open,volume
 close:878.2500,889.3500
 high:878.3700,889.3550
 low:877.8200,888.8416
 open:877.8450,889.3550
 volume:100,65500
 1380720652,881.6100,882.8000,881.0400,882.7300,44700
 1380720716,883.9800,884.2300,882.2210,882.6800,9800
 1380720776,883.6000,884.0700,882.5000,883.9500,24400
 1380720828,882.3740,883.6100,882.2500,883.2900,6000
 1380720898,883.5000,883.6200,882.4100,882.7800,5900
 1380720959,884.1614,884.3600,882.5500,883.4800,16400
...
 
  values:Timestamp,close,high,low,open,volume
 
*/

@implementation NSDictionary(SPActivityValue)

// Parses Comma Separated Values of collected Yahoo stock data into a key-value dictionary entry
+(id)dictionaryWithCSVLine:(NSString *)csvLine
{
    NSArray *csvChunks = [csvLine componentsSeparatedByString:@","];
    
    NSMutableDictionary *csvDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    // values:Timestamp,close,high,low,open,volume
    // 1380720652,881.6100,882.8000,881.0400,882.7300,44700
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



