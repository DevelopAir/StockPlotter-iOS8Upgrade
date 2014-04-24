//
//  SPYahooGetFundamentals.h
//  Stock Plotter
//
//  Created by Paul Duncanson on 9/29/13.
//  Copyright (c) 2013 Paul Duncanson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPYahooGetFundamentals;

@protocol SPYahooGetFundamentalsDelegate
@optional
-(void)fundamentalsPullerDidFinishFetch:(SPYahooGetFundamentals *)dp;
-(void)fundamentalsPullerFundamentalsDidChange:(SPYahooGetFundamentals *)dp;
-(void)fundamentalsPuller:(SPYahooGetFundamentals *)dp downloadDidFailWithError:(NSError *)error;
@end

@interface SPYahooGetFundamentals : NSObject {

    id delegate;
    NSString *targetSymbol;
    NSArray *fundamentals; // Array of dictionaries with set of ETF fundamental values (i.e. Open, PreviousClose, ...)
    
@private
    NSString *csvString;
    BOOL loadingData;
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, copy) NSString *csvString;
@property (nonatomic, copy) NSString *targetSymbol;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, readonly) NSArray *fundamentals;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL loadingData;

-(id)initWithTargetSymbol:(NSString *)aSymbol;

@end

