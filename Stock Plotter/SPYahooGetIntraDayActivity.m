//
//  SPYahooGetIntraDayActivity.m
//  Stock Plotter
//
//  Created by Paul Duncanson on 10/2/13.
//  Change History:
//

#import "SPActivityValue.h"
#import "SPYahooGetIntraDayActivity.h"

@interface SPYahooGetIntraDayActivity()

@property (nonatomic, copy) NSString *csvString;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL loadingData;

// Redeclare public readonly property's as writable
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallHigh;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallLow;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallLowestHigh;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallHighestLow;

@property (nonatomic, readwrite, retain) NSArray *activityValue;

-(void)fetch;
-(NSString *)URL;
-(void)notifyPulledData;
-(void)parseCSVAndPopulate;

@end

@implementation SPYahooGetIntraDayActivity

@synthesize symbol;
@synthesize targetSymbol;
@synthesize overallLow;
@synthesize overallHigh;
@synthesize overallHighestLow;
@synthesize overallLowestHigh;
@synthesize csvString;
@synthesize activityValue;

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
        if ( [self.activityValue count] > 0 ) {
            [self notifyPulledData]; //loads cached data onto UI
        }
    }
}

-(NSDictionary *)plistRep
{
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:9];
    
    [rep setObject:[self symbol] forKey:@"symbol"];
    [rep setObject:[self overallHigh] forKey:@"overallHigh"];
    [rep setObject:[self overallLow] forKey:@"overallLow"];
    [rep setObject:[self overallLowestHigh] forKey:@"overallLowestHigh"];
    [rep setObject:[self overallHighestLow] forKey:@"overallHighestLow"];
    [rep setObject:[self activityValue] forKey:@"activityValue"];
    return [NSDictionary dictionaryWithDictionary:rep];
}

-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag
{
    NSLog(@"writeToFile:%@", path);
    BOOL success = [[self plistRep] writeToFile:path atomically:flag];
    return success;
}

-(id)initWithDictionary:(NSDictionary *)aDict targetSymbol:(NSString *)aSymbol
{
    self = [super init];
    if ( self != nil ) {
        self.symbol            = [aDict objectForKey:@"symbol"];
        self.overallLow        = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallLow"] decimalValue]];
        self.overallHigh       = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallHigh"] decimalValue]];
        self.overallLowestHigh = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallLowestHigh"] decimalValue]];
        self.overallHighestLow = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallHighestLow"] decimalValue]];
        self.activityValue      = [aDict objectForKey:@"activityValue"];
        
        self.targetSymbol      = aSymbol;
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

-(id)initWithTargetSymbol:(NSString *)aSymbol
{
    NSDictionary *cachedDictionary = [self dictionaryForSymbol:aSymbol];
    
    if ( nil != cachedDictionary ) {
        return [self initWithDictionary:cachedDictionary targetSymbol:aSymbol];
    }
    
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];
    [rep setObject:aSymbol forKey:@"symbol"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallHigh"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallLow"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallLowestHigh"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallHighestLow"];
    [rep setObject:[NSArray array] forKey:@"activityValue"];
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
    NSString *url = [NSString stringWithFormat:@"http://chartapi.finance.yahoo.com/instrument/1.0/%@/chartdata;type=quote;range=1d/csv", [self targetSymbol]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

-(void)notifyPulledData
{
    if ( delegate && [delegate respondsToSelector:@selector(activityPullerDidFinishFetch:)] ) {
        [delegate performSelector:@selector(activityPullerDidFinishFetch:) withObject:self];
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
        NSLog(@"Get Activity URL = %@", urlString);
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
    NSMutableArray *newActivityValues = [NSMutableArray arrayWithCapacity:[csvLines count]];
    NSString *line                    = nil;
    
    self.symbol            = self.targetSymbol;
    
    self.overallHigh       = [[NSDecimalNumber alloc] initWithInt:0];
    self.overallLow        = [[NSDecimalNumber alloc] initWithInt:0];
    self.overallLowestHigh = [[NSDecimalNumber alloc] initWithInt:0];
    self.overallHighestLow = [[NSDecimalNumber alloc] initWithInt:0];
    
    // Skip first title row and collect valid entries
    for ( NSUInteger i = 15; i < [csvLines count]; i++ ) {
        line = (NSString *)[csvLines objectAtIndex:i];
        
        NSArray *fieldValues = [line componentsSeparatedByString:@","];
        
        if ([fieldValues count] == 6) {
            
            NSMutableDictionary *currentActivityValues = [[NSMutableDictionary alloc]initWithCapacity:7];
            [currentActivityValues setObject:fieldValues[0]  forKey:@"timeStamp"];
            [currentActivityValues setObject:fieldValues[1]  forKey:@"closeValue"];
            [currentActivityValues setObject:fieldValues[2]  forKey:@"high"];
            [currentActivityValues setObject:fieldValues[3]  forKey:@"low"];
            [currentActivityValues setObject:fieldValues[4]  forKey:@"openValue"];
            [currentActivityValues setObject:fieldValues[5]  forKey:@"volumeAmount"];
            
            [newActivityValues addObject:currentActivityValues];
        }
        
    }
    [self setActivityValue:[NSArray arrayWithArray:newActivityValues]];
    [self notifyPulledData];
}
@end


