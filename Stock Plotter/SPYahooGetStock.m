//
//  SPYahooGetStock.m
//  StockPlotter
//
//  Created by Paul Duncanson.
//  Change History:
//

#import "SPStockValue.h"
#import "SPYahooGetStock.h"

NSTimeInterval timeIntervalForNumberOfWeeks(float numberOfWeeks)
{
    NSTimeInterval seconds = fabs(60.0 * 60.0 * 24.0 * 7.0 * numberOfWeeks);
    
    return seconds;
}

@interface SPYahooGetStock()

@property (nonatomic, copy) NSString *csvString;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL loadingData;

// Redeclare public readonly property's as writable
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallHigh;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallLow;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallLowestHigh;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallHighestLow;

@property (nonatomic, readwrite, retain) NSArray *tradingValue;

-(void)fetch;
-(NSString *)URL;
-(void)notifyPulledData;
-(void)parseCSVAndPopulate;

@end

@implementation SPYahooGetStock

@synthesize symbol;
@synthesize startDate;
@synthesize endDate;
@synthesize targetStartDate;
@synthesize targetEndDate;
@synthesize targetSymbol;
@synthesize overallLow;
@synthesize overallHigh;
@synthesize overallHighestLow;
@synthesize overallLowestHigh;
@synthesize csvString;
@synthesize tradingValue;

@synthesize receivedData;
@synthesize connection;
@synthesize loadingData;

-(id)delegate
{
    return delegate;
}

-(void)setDelegate:(id)aDelegate
{
    if ( delegate != aDelegate ) {
        delegate = aDelegate;
        if ( [self.tradingValue count] > 0 ) {
            [self notifyPulledData]; //loads cached data onto UI
        }
    }
}

-(NSDictionary *)plistRep
{
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:9];
    
    [rep setObject:[self symbol] forKey:@"symbol"];
    [rep setObject:[self startDate] forKey:@"startDate"];
    [rep setObject:[self endDate] forKey:@"endDate"];
    [rep setObject:[self overallHigh] forKey:@"overallHigh"];
    [rep setObject:[self overallLow] forKey:@"overallLow"];
    [rep setObject:[self overallLowestHigh] forKey:@"overallLowestHigh"];
    [rep setObject:[self overallHighestLow] forKey:@"overallHighestLow"];
    [rep setObject:[self tradingValue] forKey:@"tradingValue"];
    return [NSDictionary dictionaryWithDictionary:rep];
}

-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag
{
    NSLog(@"writeToFile:%@", path);
    BOOL success = [[self plistRep] writeToFile:path atomically:flag];
    return success;
}

-(id)initWithDictionary:(NSDictionary *)aDict targetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate
{
    self = [super init];
    if ( self != nil ) {
        self.symbol            = [aDict objectForKey:@"symbol"];
        self.startDate         = [aDict objectForKey:@"startDate"];
        self.overallLow        = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallLow"] decimalValue]];
        self.overallHigh       = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallHigh"] decimalValue]];
        self.overallLowestHigh = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallLowestHigh"] decimalValue]];
        self.overallHighestLow = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallHighestLow"] decimalValue]];
        self.endDate           = [aDict objectForKey:@"endDate"];
        self.tradingValue      = [aDict objectForKey:@"tradingValue"];
        
        self.targetSymbol      = aSymbol;
        self.targetStartDate   = aStartDate;
        self.targetEndDate     = anEndDate;
        self.csvString         = @"";
        [self performSelector:@selector(fetch) withObject:nil afterDelay:0.01];
    }
    return self;
}

-(NSString *)pathForSymbol:(NSString *)aSymbol
{
    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *docPath            = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    
    return docPath;
}

-(NSString *)faultTolerantPathForSymbol:(NSString *)aSymbol
{
    NSString *docPath = [self pathForSymbol:aSymbol];
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:docPath] ) {
        //if there isn't one in the user's documents directory, see if we ship with this data
        docPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    }
    return docPath;
}

//Always returns *something*
-(NSDictionary *)dictionaryForSymbol:(NSString *)aSymbol
{
    NSString *path                      = [self faultTolerantPathForSymbol:aSymbol];
    NSMutableDictionary *localPlistDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    return localPlistDict;
}

-(id)initWithTargetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate
{
    NSDictionary *cachedDictionary = [self dictionaryForSymbol:aSymbol];
    
    if ( nil != cachedDictionary ) {
        return [self initWithDictionary:cachedDictionary targetSymbol:aSymbol targetStartDate:aStartDate targetEndDate:anEndDate];
    }
    
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];
    [rep setObject:aSymbol forKey:@"symbol"];
    [rep setObject:aStartDate forKey:@"startDate"];
    [rep setObject:anEndDate forKey:@"endDate"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallHigh"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallLow"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallLowestHigh"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallHighestLow"];
    [rep setObject:[NSArray array] forKey:@"tradingValue"];
    return [self initWithDictionary:rep targetSymbol:aSymbol targetStartDate:aStartDate targetEndDate:anEndDate];
}

-(id)init
{
    NSTimeInterval secondsAgo = -timeIntervalForNumberOfWeeks(14.0f);
    NSDate *start             = [NSDate dateWithTimeIntervalSinceNow:secondsAgo];
    
    NSDate *end = [NSDate date];
    
    return [self initWithTargetSymbol:@"GOOG" targetStartDate:start targetEndDate:end];
}

-(void)dealloc
{
    [self setDelegate:nil];
}

//
-(NSString *)URL
{
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit;
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *compsStart = [gregorian components:unitFlags fromDate:targetStartDate];
    NSDateComponents *compsEnd   = [gregorian components:unitFlags fromDate:targetEndDate];
    
    NSString *url = [NSString stringWithFormat:@"http://ichart.yahoo.com/table.csv?s=%@&", [self targetSymbol]];
    url = [url stringByAppendingFormat:@"a=%d&", [compsStart month] - 1];
    url = [url stringByAppendingFormat:@"b=%d&", [compsStart day]];
    url = [url stringByAppendingFormat:@"c=%d&", [compsStart year]];
    
    url = [url stringByAppendingFormat:@"d=%d&", [compsEnd month] - 1];
    url = [url stringByAppendingFormat:@"e=%d&", [compsEnd day]];
    url = [url stringByAppendingFormat:@"f=%d&", [compsEnd year]];
    url = [url stringByAppendingString:@"g=d&"];
    
    url = [url stringByAppendingString:@"ignore=.csv"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

-(void)notifyPulledData
{
    if ( delegate && [delegate respondsToSelector:@selector(stockPullerDidFinishFetch:)] ) {
        [delegate performSelector:@selector(stockPullerDidFinishFetch:) withObject:self];
    }
}

#pragma mark -
#pragma mark Downloading of data

-(BOOL)shouldDownload
{
    BOOL shouldDownload = YES;
    
    return shouldDownload;
}

-(void)fetch
{
    if ( self.loadingData ) {
        return;
    }
    
    if ( [self shouldDownload] ) {
        self.loadingData = YES;
        NSString *urlString = [self URL];
        NSLog(@"Get Stock URL = %@", urlString);
        NSURL *url               = [NSURL URLWithString:urlString];
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
        
        // create connection with request and start loading
        self.connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
        if ( self.connection ) {
            self.receivedData = [NSMutableData data];
        }
        else {
            //TODO: Inform the user that the download failed
            self.loadingData = NO;
        }
    }
    else {
        NSLog(@"Chosen not to download Stock");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    [self.receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // When the server has determined that there's
    // enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [self.receivedData setLength:0];
}

-(void)cancelDownload
{
    if ( self.loadingData ) {
        [self.connection cancel];
        self.loadingData = NO;
        
        self.receivedData = nil;
        self.connection   = nil;
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.loadingData  = NO;
    self.receivedData = nil;
    self.connection   = nil;
    NSLog(@"err = %@", [error localizedDescription]);
    //TODO:report connection error to user
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.loadingData = NO;
    self.connection  = nil;
    
    NSString *csv = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    self.csvString = csv;
    
    self.receivedData = nil;
    [self parseCSVAndPopulate];
    
    [self writeToFile:[self pathForSymbol:self.symbol] atomically:YES];
}

-(void)parseCSVAndPopulate
{
    NSArray *csvLines                 = [self.csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *newTradingValues  = [NSMutableArray arrayWithCapacity:[csvLines count]];
    NSString *line                    = nil;
    NSDecimalNumber *high;
    NSDecimalNumber *low;
    
    self.startDate         = self.targetStartDate;
    self.endDate           = self.targetEndDate;
    self.symbol            = self.targetSymbol;
    
    self.overallHigh       = [[NSDecimalNumber alloc] initWithInt:0];
    
    self.overallLow        = [[NSDecimalNumber alloc] initWithInt:0];
    
    self.overallLowestHigh = [[NSDecimalNumber alloc] initWithInt:0];
    
    self.overallHighestLow = [[NSDecimalNumber alloc] initWithInt:0];

    // Skip first title row and collect valid entries
    for ( NSUInteger i = 1; i < [csvLines count]; i++ ) {
        line = (NSString *)[csvLines objectAtIndex:i];
        
        NSArray *fieldValues = [line componentsSeparatedByString:@","];
        
        if ([fieldValues count] == 7) {
            
            NSMutableDictionary *currentTradingValues = [[NSMutableDictionary alloc]initWithCapacity:7];
            [currentTradingValues setObject:fieldValues[0]  forKey:@"marketDate"];
            [currentTradingValues setObject:fieldValues[1]  forKey:@"openValue"];
            [currentTradingValues setObject:fieldValues[2]  forKey:@"high"];
            [currentTradingValues setObject:fieldValues[3]  forKey:@"low"];
            [currentTradingValues setObject:fieldValues[4]  forKey:@"closeValue"];
            [currentTradingValues setObject:fieldValues[5]  forKey:@"volumeAmount"];
            [currentTradingValues setObject:fieldValues[6]  forKey:@"adjClose"];
        
            high   = [currentTradingValues objectForKey:@"high"];
            low    = [currentTradingValues objectForKey:@"low"];
        
            // Prime limit values on first loop iteration
            if (i == 1) {
                self.overallHigh = [high copy];
                self.overallLowestHigh = [high copy];
                self.overallLow = [low copy];
                self.overallHighestLow = [low copy];
            }
            else { 
                if ( [self.overallHigh compare:high] == NSOrderedAscending ) {
                    self.overallHigh = [high copy];
                }
        
                if ( [self.overallLow compare:low] == NSOrderedDescending ) {
                    self.overallLow = [low copy];
                }
        
                if ( [self.overallLowestHigh compare:high] == NSOrderedDescending ) {
                    self.overallLowestHigh = [high copy];
                }
        
                if ( [self.overallHighestLow compare:low] == NSOrderedAscending ) {
                    self.overallHighestLow = [low copy];
                }
            }
            
            [newTradingValues addObject:currentTradingValues];
        }

    }
    [self setTradingValue:[NSArray arrayWithArray:newTradingValues]];
    [self notifyPulledData];
}
@end

