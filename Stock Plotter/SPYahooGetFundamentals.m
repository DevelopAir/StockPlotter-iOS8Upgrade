//
//  SPYahooGetFundamentals.m
//  Stock Plotter
//
//  Created by Paul Duncanson on 9/29/13.
//  Change History:
//

#import "SPFundamentalValue.h"
#import "SPYahooGetFundamentals.h"

@interface SPYahooGetFundamentals()

-(void)fetch;
-(NSString *)URL;
-(void)notifyPulledData;
-(void)parseCSVAndPopulate;

// Redeclare public readonly property's as writable
@property (nonatomic, readwrite, retain) NSArray *fundamentals;
/*
@property (nonatomic, readwrite, retain) NSString *nameOfETF;
@property (nonatomic, readwrite, retain) NSDecimalNumber *currentValue;
@property (nonatomic, readwrite, retain) NSString *changeAndPercentChange;
@property (nonatomic, readwrite, retain) NSDecimalNumber *fiftyTwoWeekLow;
@property (nonatomic, readwrite, retain) NSDecimalNumber *fiftyTwoWeekHigh;
@property (nonatomic, readwrite, retain) NSDecimalNumber *previousClose;
@property (nonatomic, readwrite, retain) NSDecimalNumber *openValue;
@property (nonatomic, readwrite, retain) NSNumber *volumeAmount;
@property (nonatomic, readwrite, retain) NSString *netAssetts;
@property (nonatomic, readwrite, retain) NSDecimalNumber *returnYTD;
*/
@end

@implementation SPYahooGetFundamentals

@synthesize targetSymbol;

@synthesize symbol;
/*
@synthesize nameOfETF;
@synthesize currentValue;
@synthesize changeAndPercentChange;
@synthesize fiftyTwoWeekLow;
@synthesize fiftyTwoWeekHigh;
@synthesize previousClose;
@synthesize openValue;
@synthesize volumeAmount;
@synthesize netAssetts;
@synthesize returnYTD;
*/
@synthesize fundamentals;
@synthesize csvString;

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
        if ( [self.fundamentals count] > 0 ) {
            [self notifyPulledData]; //loads cached data onto UI
        }
    }
}

-(NSDictionary *)plistRep
{
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:11];
    [rep setObject:[self symbol] forKey:@"symbol"];
    return [NSDictionary dictionaryWithDictionary:rep];
}

-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag
{
    BOOL success = [[self plistRep] writeToFile:path atomically:flag];
    // NSLog(@"writeToFile:%@ returned %c", path, success);
    return success;
}

-(id)initWithDictionary:(NSDictionary *)aDict targetSymbol:(NSString *)aSymbol
{
    self = [super init];
    if ( self != nil ) {
        self.symbol                 = aSymbol;
        self.csvString              = @"";
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

-(id)initWithTargetSymbol:(NSString *)aSymbol
{
    NSDictionary *cachedDictionary = [self dictionaryForSymbol:aSymbol];
    
    if ( nil != cachedDictionary ) {
        return [self initWithDictionary:cachedDictionary targetSymbol:aSymbol];
    }
        
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:11];
    [rep setObject:aSymbol forKey:@"symbol"];
    return [self initWithDictionary:rep targetSymbol:aSymbol];
}

-(id)init
{
    return [self initWithTargetSymbol:@"GOOG"];
}

-(void)dealloc
{
    [self setDelegate:nil];
}

//
-(NSString *)URL
{
    NSArray *tableViewItems = [symbol componentsSeparatedByString:@"|"];
    
    NSString *symbolURL;
    NSString *eachItem;
    
    // Extract ETF symbol (i.e. first word) from each table view cell.
    for (NSUInteger i = 0; i < [tableViewItems count]; i++)
    {
        eachItem = tableViewItems[i];
        NSArray *arr = [eachItem componentsSeparatedByString:@" "];
        
        if ([arr count] > 0) {
            eachItem = arr[0];

            if (symbolURL.length > 0) {
                symbolURL = [NSString stringWithFormat:@"%@, %@", symbolURL, eachItem];
            } else {
                symbolURL = eachItem;
            }
        }
    }

    NSString *url = [NSString stringWithFormat:@"http://finance.yahoo.com/d/quotes.csv?s=%@%@", symbolURL, @"&f=snl1cjkpovb4s6"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

-(void)notifyPulledData
{
    if ( delegate && [delegate respondsToSelector:@selector(fundamentalsPullerDidFinishFetch:)] ) {
        [delegate performSelector:@selector(fundamentalsPullerDidFinishFetch:) withObject:self];
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
        NSLog(@"Get Fundamentals URL = %@", urlString);
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
        NSLog(@"Chosen not to download Fundamentals");
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
    NSArray *csvLines               = [self.csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *newFundamentals = [NSMutableArray arrayWithCapacity:[csvLines count]];
    NSString *line;
    
    for ( NSUInteger i = 0; i < [csvLines count]; i++ ) {
        line = (NSString *)[csvLines objectAtIndex:i];

        line                 = [line stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSArray *fieldValues = [line componentsSeparatedByString:@","];

        if ([fieldValues count] == 11) {
        
            NSMutableDictionary *currentFundamentals = [[NSMutableDictionary alloc]initWithCapacity:11];
            [currentFundamentals setObject:fieldValues[0]  forKey:@"symbol"];
            [currentFundamentals setObject:fieldValues[1]  forKey:@"nameOfETF"];
            [currentFundamentals setObject:fieldValues[2]  forKey:@"currentValue"];
            [currentFundamentals setObject:fieldValues[3]  forKey:@"changeAndPercentChange"];
            [currentFundamentals setObject:fieldValues[4]  forKey:@"fiftyTwoWeekLow"];
            [currentFundamentals setObject:fieldValues[5]  forKey:@"fiftyTwoWeekHigh"];
            [currentFundamentals setObject:fieldValues[6]  forKey:@"previousClose"];
            [currentFundamentals setObject:fieldValues[7]  forKey:@"openValue"];
            [currentFundamentals setObject:fieldValues[8]  forKey:@"volumeAmount"];
            [currentFundamentals setObject:fieldValues[9]  forKey:@"netAssetts"];
            [currentFundamentals setObject:fieldValues[10] forKey:@"returnYTD"];
        
            [newFundamentals addObject:currentFundamentals];
            
        } else if ([fieldValues count] > 11) {
            int numberOfCommasInName = [fieldValues count] - 11;
            
            NSMutableDictionary *currentFundamentals = [[NSMutableDictionary alloc]initWithCapacity:11];
            [currentFundamentals setObject:fieldValues[10+numberOfCommasInName] forKey:@"returnYTD"];
            [currentFundamentals setObject:fieldValues[9+numberOfCommasInName]  forKey:@"netAssetts"];
            [currentFundamentals setObject:fieldValues[8+numberOfCommasInName]  forKey:@"volumeAmount"];
            [currentFundamentals setObject:fieldValues[7+numberOfCommasInName]  forKey:@"openValue"];
            [currentFundamentals setObject:fieldValues[6+numberOfCommasInName]  forKey:@"previousClose"];
            [currentFundamentals setObject:fieldValues[5+numberOfCommasInName]  forKey:@"fiftyTwoWeekHigh"];
            [currentFundamentals setObject:fieldValues[4+numberOfCommasInName]  forKey:@"fiftyTwoWeekLow"];
            [currentFundamentals setObject:fieldValues[3+numberOfCommasInName]  forKey:@"changeAndPercentChange"];
            [currentFundamentals setObject:fieldValues[2+numberOfCommasInName]  forKey:@"currentValue"];
            [currentFundamentals setObject:fieldValues[0]  forKey:@"symbol"];
            
            NSString *nameWithCommas = @"";
            for (int j = 1; j <= (numberOfCommasInName + 1); j++) {
                if (nameWithCommas.length > 0) {
                    nameWithCommas = [nameWithCommas stringByAppendingString:@","];
                }
                nameWithCommas = [nameWithCommas stringByAppendingString:fieldValues[j]];
            }
            
            [currentFundamentals setObject:nameWithCommas forKey:@"nameOfETF"];
            [newFundamentals addObject:currentFundamentals];
        }
        
    }
    
    [self setFundamentals:[NSArray arrayWithArray:newFundamentals]];
    [self notifyPulledData];
}

@end

