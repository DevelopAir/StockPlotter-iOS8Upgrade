//
//  SPFundamentalValue.m
//  Stock Plotter
//
//  Created by Paul Duncanson on 9/29/13.
//  Change History:
//

#import "SPFundamentalValue.h"

@implementation NSDictionary(SPFundamentalValue)

// Parses Comma Separated Values of collected Yahoo fundamentals into a key-value dictionary entry
+(id)dictionaryWithCSVLine:(NSString *)csvLine
{
    NSArray *csvChunks = [csvLine componentsSeparatedByString:@","];
    
    NSMutableDictionary *csvDict = [NSMutableDictionary dictionaryWithCapacity:11];
    
    // http://finance.yahoo.com/d/quotes.csv?s=VOO,VB,VWO,VNQ,CORP,GOVT&f=snl1cjkpovb4s6 will generate:

    // Symbol, "Name", last trade value, "change - percent change", 52 Week Low, 52 Week High, Previous Close, Open, Volume, Book Value (i.e. Net Assetts), Revenue (i.e. YTD return)
    //
    /*
    "VOO","Vanguard S&P 500 ",77.43,"-0.33 - -0.42%",61.69,79.52,77.76,77.35,2811899,0.00,0
    "VB","Vanguard Small-Ca",102.54,"-0.42 - -0.41%",74.48,103.68,102.96,102.39,304970,0.00,0
    "VWO","Vanguard Emerging",40.515,"-0.585 - -1.42%",36.02,45.54,41.10,40.72,17579718,0.00,0
    "VNQ","Vanguard REIT ETF",66.85,"-0.28 - -0.42%",61.66,78.86,67.13,66.94,3412327,0.00,0
    "CORP","Pimco Investment ",102.76,"-0.079 - -0.08%",100.05,110.02,102.839,102.75,4112,0.00,0
    "GOVT","iShares U.S. Trea",24.54,"+0.02 - +0.08%",23.82,25.49,24.52,24.5177,28056,0.00,0
    */
    
    NSString *theSymbol = [NSString stringWithString:(NSString *)[csvChunks objectAtIndex:0]];
    [csvDict setObject:theSymbol forKey:@"symbol"];
    NSString *theNameOfEFS = [NSString stringWithString:(NSString *)[csvChunks objectAtIndex:1]];
    [csvDict setObject:theNameOfEFS forKey:@"nameOfEFS"];
    NSDecimalNumber *theCurrentValue = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:2]];
    [csvDict setObject:theCurrentValue forKey:@"currentValue"];
    NSString *theChangeAndPercentOfChange = [NSString stringWithString:(NSString *)[csvChunks objectAtIndex:3]];
    [csvDict setObject:theChangeAndPercentOfChange forKey:@"changeAndPercentOfChange"];
    NSDecimalNumber *theFiftyTwoWeekLow = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:4]];
    [csvDict setObject:theFiftyTwoWeekLow forKey:@"fiftyTwoWeekLow"];
    NSDecimalNumber *theFiftyTwoWeekHigh = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:5]];
    [csvDict setObject:theFiftyTwoWeekHigh forKey:@"fiftyTwoWeekHigh"];
    NSDecimalNumber *thePreviousClose = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:6]];
    [csvDict setObject:thePreviousClose forKey:@"previousClose"];
    NSDecimalNumber *theOpenValue = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:7]];
    [csvDict setObject:theOpenValue forKey:@"openValue"];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    NSNumber *theVolumeAmount = [f numberFromString:(NSString *)[csvChunks objectAtIndex:8]];
    [csvDict setObject:theVolumeAmount forKey:@"volumeAmount"];
    NSNumber *theNetAssetts = [f numberFromString:(NSString *)[csvChunks objectAtIndex:9]];
    [csvDict setObject:theNetAssetts forKey:@"netAssetts"];
    NSDecimalNumber *theReturnYTD = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:10]];
    [csvDict setObject:theReturnYTD forKey:@"returnYTD"];
    
    //non-mutable autoreleased dict
    return [NSDictionary dictionaryWithDictionary:csvDict];
}

@end



