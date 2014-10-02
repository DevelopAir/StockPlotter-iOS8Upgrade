//
//  SPYahooGetIntraDayActivity.h
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Change History:
//

@class SPYahooGetIntraDayActivity;

@protocol SPYahooGetIntraDayActivityDelegate
@optional
-(void)activityPullerDidFinishFetch:(SPYahooGetIntraDayActivity *)dp;
-(void)activityPullerStockDidChange:(SPYahooGetIntraDayActivity *)dp;
-(void)activityPuller:(SPYahooGetIntraDayActivity *)dp downloadDidFailWithError:(NSError *)error;
@end

@interface SPYahooGetIntraDayActivity : NSObject {
    NSString *symbol; 
    NSString *targetSymbol;
    
    id delegate;
    
    NSDecimalNumber *overallHigh;
    NSDecimalNumber *overallLow;
    NSDecimalNumber *overallLowestHigh;
    NSDecimalNumber *overallHighestLow;
    
    NSArray *activityValue; // dictionaries of stock activity
    
@private
    NSString *csvString;
    BOOL loadingData;
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *targetSymbol;
@property (nonatomic, readonly, retain) NSArray *activityValue;
@property (nonatomic, readonly, retain) NSDecimalNumber *overallHigh;
@property (nonatomic, readonly, retain) NSDecimalNumber *overallLow;
@property (nonatomic, readonly, retain) NSDecimalNumber *overallLowestHigh;
@property (nonatomic, readonly, retain) NSDecimalNumber *overallHighestLow;


-(id)initWithTargetSymbol:(NSString *)aSymbol;

@end

