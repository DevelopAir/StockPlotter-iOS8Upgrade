//
//  SPDetailViewController.m
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Change History:
//

#import "SPDetailViewController.h"

@interface SPDetailViewController ()

@end

@implementation SPDetailViewController

@synthesize stockPuller;
@synthesize activityPuller;

int instr(NSString *searchFor, NSString *searchIn, int startingAt) {
	NSRange searchRange;
	int retVal;
	
	searchRange.location = startingAt;
	searchRange.length = [searchIn length] - startingAt;
	
	NSRange foundRange = [searchIn rangeOfString:searchFor options:0  range:searchRange];
	if(foundRange.length > 0){
		retVal = (int)foundRange.location;
	}else{
		retVal = -1;
	}
	
	return retVal;
}

-(NSString *)subStrOf:(NSString *)fullString between:(NSString *)firstString andSecondString:(NSString *) secondString
{
    NSRange secondInstance;
    NSRange finalRange;
    
    NSRange firstInstance = [fullString rangeOfString:firstString];
    if (firstInstance.length > 0) {
        secondInstance = [[fullString substringFromIndex:(firstInstance.location + firstInstance.length)] rangeOfString:secondString];
    } else {
        NSLog(@"subStrOf couldn't find first string '%@' in '%@'", firstString, fullString);
        secondInstance = [fullString rangeOfString:secondString];
    }
    if (secondInstance.length > 0) {
        if (firstInstance.length > 0) {
            finalRange = NSMakeRange(firstInstance.location + firstString.length, secondInstance.location);
        } else {
            finalRange = NSMakeRange(0, secondInstance.location);
        }
    } else {
        if (firstInstance.length > 0) {
            NSLog(@"subStrOf couldn't find second string '%@' in '%@", secondString, fullString);
            finalRange = NSMakeRange(firstInstance.location + firstString.length, fullString.length - (firstInstance.location + firstInstance.length));
        } else {
            finalRange = NSMakeRange(0, 0);
        }
    }
    
    return [fullString substringWithRange:finalRange];
}

/*------------------ Sample of web page being scraped ----------------------
<table width="100%" class="yfnc_mod_table_title1" cellpadding="2" cellspacing="0" border="0"><tr><th align="left">Top 10 Holdings (18.04% of Total Assets)</th><th align="right">&nbsp;</th></tr></table>

<table class="yfnc_tableout1" width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td><table width="100%" cellpadding="3" cellspacing="1" border="0"><tr><th scope="col" class="yfnc_tablehead1" align="left">Company</th><th scope="col" class="yfnc_tablehead1" align="left">Symbol</th><th scope="col" class="yfnc_tablehead1" align="right">% Assets</th></tr>

<tr><td class="yfnc_tabledata1">Apple Inc.</td><td class="yfnc_tabledata1"><a href="/q?s=AAPL">AAPL</a></td><td class="yfnc_tabledata1" align="right">2.81</td></tr>
<tr><td class="yfnc_tabledata1">Exxon Mobil Corporation Common </td><td class="yfnc_tabledata1"><a href="/q?s=XOM">XOM</a></td><td class="yfnc_tabledata1" align="right">2.76</td></tr>
<tr><td class="yfnc_tabledata1">Johnson &amp; Johnson Common Stock</td><td class="yfnc_tabledata1"><a href="/q?s=JNJ">JNJ</a></td><td class="yfnc_tabledata1" align="right">1.74</td></tr>
<tr><td class="yfnc_tabledata1">General Electric Company Common</td><td class="yfnc_tabledata1"><a href="/q?s=GE">GE</a></td><td class="yfnc_tabledata1" align="right">1.67</td></tr>
<tr><td class="yfnc_tabledata1">Chevron Corporation Common Stoc</td><td class="yfnc_tabledata1"><a href="/q?s=CVX">CVX</a></td><td class="yfnc_tabledata1" align="right">1.62</td></tr>
<tr><td class="yfnc_tabledata1">Google Inc.</td><td class="yfnc_tabledata1"><a href="/q?s=GOOG">GOOG</a></td><td class="yfnc_tabledata1" align="right">1.58</td></tr>
<tr><td class="yfnc_tabledata1">Microsoft Corporation</td><td class="yfnc_tabledata1"><a href="/q?s=MSFT">MSFT</a></td><td class="yfnc_tabledata1" align="right">1.58</td></tr>
<tr><td class="yfnc_tabledata1">Procter &amp; Gamble Company (The) </td><td class="yfnc_tabledata1"><a href="/q?s=PG">PG</a></td><td class="yfnc_tabledata1" align="right">1.46</td></tr>
<tr><td class="yfnc_tabledata1">Wells Fargo &amp; Company Common St</td><td class="yfnc_tabledata1"><a href="/q?s=WFC">WFC</a></td><td class="yfnc_tabledata1" align="right">1.42</td></tr>
<tr><td class="yfnc_tabledata1">JP Morgan Chase &amp; Co. Common St</td><td class="yfnc_tabledata1"><a href="/q?s=JPM">JPM</a></td><td class="yfnc_tabledata1" align="right">1.40</td></tr>
</table>
----------------------------------------------------------------------------*/
// Note:  Never call scrapeHoldings from the main thread on account of web page retrieval delay.
//        Verify any web scraping maintenance issues with above sample listing and please keep this sample listing up to date.

-(void)scrapeHoldings:(NSString *)selectedETF {

    NSString *urlForHoldings;
        
    urlForHoldings = [NSString stringWithFormat:@"%@%@%@", @"http://finance.yahoo.com/q/hl?s=", selectedETF, @"+Holdings"];
    NSURL *holdingsUrl = [NSURL URLWithString:urlForHoldings];

    NSData *holdingsHtmlData = [NSData dataWithContentsOfURL:holdingsUrl];

    TFHpple *holdingsParser = [TFHpple hppleWithHTMLData:holdingsHtmlData];
    
    NSString *holdingsXpathQueryString = @"//div[@id='rightcol']//td[@class='yfnc_tabledata1']";

    NSArray *holdingsNodes = [holdingsParser searchWithXPathQuery:holdingsXpathQueryString];
    
    NSInteger iHoldingCount;
    
    NSMutableArray *newHoldings = [NSMutableArray arrayWithCapacity:0];
    
    if (holdingsNodes != nil && [holdingsNodes count] > 0) {
        
        TFHppleElement *element;
        
        NSInteger iLim;
        
        iLim = [holdingsNodes count] - 68;
        
        if ([holdingsNodes count] > 68) {
            for (NSInteger i = 0; i < iLim; i = i + 3) {
                element = [holdingsNodes objectAtIndex:i];
                NSString *holdingName = [[element firstChild] content];
    
                element = [holdingsNodes objectAtIndex:(i + 1)];
            
                //<td class="yfnc_tabledata1"><a href="/q?s=AAPL">AAPL</a></td> OR
                //<td class="yfnc_tabledata1">00941</td>
                
                NSString *holdingSymbol = @"";
                
                holdingSymbol = [[element firstChild] content];
                
                if (holdingSymbol.length < 1) {
                    NSString *rawSymbol = [element raw];
                    holdingSymbol = [self subStrOf:rawSymbol between:@"q?s=" andSecondString:@"\">"];
                }
            
                element = [holdingsNodes objectAtIndex:(i + 2)];
                NSString *holdingPercent = [[element firstChild] content];
            
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:holdingSymbol, @"holdingSymbol", holdingName, @"holdingName", holdingPercent, @"holdingPercent", nil];
            
                [newHoldings addObject:dict];
            }
        }
        
        iHoldingCount = iLim / 3;
        
    } else {
        iHoldingCount = 0;
    }
    
    NSDictionary *dict;
    
    // Make accomodations for stocks that do not have 10 holdings (e.g. GOVT has 9, Non ETF's have none)
    if (iHoldingCount > 9) {
        dict = [newHoldings objectAtIndex:9];
        
        self.tenthHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.tenthHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.tenthHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.tenthHoldingName.text = @"";
        [self.tenthHolding setTitle: @"" forState: UIControlStateNormal];
        self.tenthHoldingPercent.text = @"";
    }
        
    if (iHoldingCount > 8) {
        dict = [newHoldings objectAtIndex:8];
    
        self.ninthHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.ninthHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.ninthHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.ninthHoldingName.text = @"";
        [self.ninthHolding setTitle: @"" forState: UIControlStateNormal];
        self.ninthHoldingPercent.text = @"";
    }
        
    if (iHoldingCount > 7) {
        dict = [newHoldings objectAtIndex:7];
    
        self.eighthHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.eighthHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.eighthHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.eighthHoldingName.text = @"";
        [self.eighthHolding setTitle: @"" forState: UIControlStateNormal];
        self.eighthHoldingPercent.text = @"";
    }
    
    if (iHoldingCount > 6) {
        dict = [newHoldings objectAtIndex:6];
    
        self.seventhHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.seventhHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.seventhHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.seventhHoldingName.text = @"";
        [self.seventhHolding setTitle: @"" forState: UIControlStateNormal];
        self.seventhHoldingPercent.text = @"";
    }
    
    if (iHoldingCount > 5) {
        dict = [newHoldings objectAtIndex:5];
    
        self.sixthHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.sixthHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.sixthHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.sixthHoldingName.text = @"";
        [self.sixthHolding setTitle: @"" forState: UIControlStateNormal];
        self.sixthHoldingPercent.text = @"";
    }
    
    if (iHoldingCount > 4) {
        dict = [newHoldings objectAtIndex:4];
    
        self.fifthHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.fifthHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.fifthHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.fifthHoldingName.text = @"";
        [self.fifthHolding setTitle: @"" forState: UIControlStateNormal];
        self.fifthHoldingPercent.text = @"";
    }
    
    if (iHoldingCount > 3) {
        dict = [newHoldings objectAtIndex:3];
    
        self.fourthHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.fourthHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.fourthHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.fourthHoldingName.text = @"";
        [self.fourthHolding setTitle: @"" forState: UIControlStateNormal];
        self.fourthHoldingPercent.text = @"";
    }
    
    if (iHoldingCount > 2) {
        dict = [newHoldings objectAtIndex:2];
    
        self.thirdHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.thirdHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.thirdHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.thirdHoldingName.text = @"";
        [self.thirdHolding setTitle: @"" forState: UIControlStateNormal];
        self.thirdHoldingPercent.text = @"";
    }
    
    if (iHoldingCount > 1) {
        dict = [newHoldings objectAtIndex:1];
    
        self.secondHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.secondHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.secondHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.secondHoldingName.text = @"";
        [self.secondHolding setTitle: @"" forState: UIControlStateNormal];
        self.secondHoldingPercent.text = @"";
    }
    
    if (iHoldingCount > 0) {
        dict = [newHoldings objectAtIndex:0];
    
        self.firstHoldingName.text = [dict objectForKey:@"holdingName"];
        [self.firstHolding setTitle: [dict objectForKey:@"holdingSymbol"] forState: UIControlStateNormal];
        self.firstHoldingPercent.text = [dict objectForKey:@"holdingPercent"];
    } else {
        self.firstHoldingName.text = @"";
        [self.firstHolding setTitle: @"" forState: UIControlStateNormal];
        self.firstHoldingPercent.text = @"";
    }
}

-(NSString *) cleanUpHTML:(NSString *)webData {
    
    NSString *cleanedHTML;
    
    cleanedHTML = webData;
    
    cleanedHTML = [cleanedHTML stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    cleanedHTML = [cleanedHTML stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    cleanedHTML = [cleanedHTML stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    cleanedHTML = [cleanedHTML stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    cleanedHTML = [cleanedHTML stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    cleanedHTML = [cleanedHTML stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    cleanedHTML = [cleanedHTML stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    return cleanedHTML;
}

/*------------------ Sample of Yahoo web page being scraped ----------------------
 <div id="yfi_quote_summary_data" class="rtq_table">
 <table id="table1">
 <tbody>
 <tr><th scope="row" width="48%">Prev Close:</th><td class="yfnc_tabledata1">77.98</td></tr>
 <tr><th scope="row" width="48%">Open:</th><td class="yfnc_tabledata1">N/A</td></tr>
 <tr><th scope="row" width="48%">Bid:</th><td class="yfnc_tabledata1"><span id="yfs_b00_voo">76.50</span><small> x <span id="yfs_b60_voo">100</span></small></td></tr>
 <tr><th scope="row" width="48%">Ask:</th><td class="yfnc_tabledata1"><span id="yfs_a00_voo">80.39</span><small> x <span id="yfs_a50_voo">7500</span></small></td></tr>
 <tr><th scope="row" width="48%">NAV¹:</th><td class="yfnc_tabledata1">53.02</td></tr>
 <tr><th scope="row" width="48%">Net Assets²:</th><td class="yfnc_tabledata1">143.43B</td></tr>
 <tr class="end"><th scope="row" width="48%">YTD Return <span class="small">(Mkt)</span>²:</th>
 <td class="yfnc_tabledata1">19.88%</td></tr></tbody></table><table id="table2"><tbody><tr><th scope="row" width="48%">Day's Range:</th>
 <td class="yfnc_tabledata1"><span>N/A</span> - <span>N/A</span></td></tr>
 <tr><th scope="row" width="48%">52wk Range:</th>
 <td class="yfnc_tabledata1" nowrap=""><span>61.69</span> - <span>79.52</span></td></tr>
 <tr><th scope="row" width="48%">Volume:</th><td class="yfnc_tabledata1"><span id="yfs_v53_voo">0</span></td></tr>
 <tr><th scope="row" width="48%">Avg Vol <span class="small">(3m)</span>:</th>
 <td class="yfnc_tabledata1">1,806,870</td></tr>
 <tr><th scope="row" width="48%">P/E <span class="small">(ttm)</span>²:</th><td class="yfnc_tabledata1">15</td></tr>
 <tr class="end"><th scope="row" width="48%">Yield <span class="small">(ttm)</span>²:</th><td class="yfnc_tabledata1"><yield>2.04</yield></td>
 </tr></tbody></table></div>
---------------------------------------------------------------------------------*/
// Note:  Never call scrapeSummary from the main thread on account of web page retrieval delay.
//        Verify any web scraping maintenance issues with above sample listing and please keep this sample listing up to date.

-(void)scrapeSummary:(NSString *)selectedETF {
    
    NSString *urlForYahooSummary;
    
    NSString *selectedStockName;
    NSString *currentPrice;
    NSString *previousClose;
    NSString *openAmount;
    NSString *netAssetsOrBeta;
    NSString *returnYTDOrNextEarningsDate;
    NSString *daysInRangeRaw;
    NSString *daysRange;
    NSString *fiftyTwoWeekRange;
    NSString *volumeAmount;
    NSString *average3MVolume;
    NSString *priceToEarnings;
    NSString *marketCap;
    NSString *earningsPerShare;
    NSString *dividendAndYield;
    NSString *yieldOrPriceToEarnings;
    
    NSString *last3YReturn;
    NSString *beta3y;
    
    BOOL bNotAnETF = NO;
    
    // <div id="yfi_quote_summary_data" ...
    // class="yfnc_tabledata1"
    
    urlForYahooSummary = [NSString stringWithFormat:@"%@%@", @"http://finance.yahoo.com/q?s=", selectedETF];
    NSURL *summaryUrl = [NSURL URLWithString:urlForYahooSummary];
    
    NSData *summaryHtmlData = [NSData dataWithContentsOfURL:summaryUrl];
    
    TFHpple *summaryParser = [TFHpple hppleWithHTMLData:summaryHtmlData];
    
    NSString *summaryXpathQueryString = @"//div[@class='yfi_rt_quote_summary']";
    
    NSArray *headingNodes = [summaryParser searchWithXPathQuery:summaryXpathQueryString];
    
    TFHppleElement *element;
    
    if ([headingNodes count] > 0) {
        element = [headingNodes objectAtIndex:0];
        NSString *headingNodesRaw = [element raw];
        
        selectedStockName = headingNodesRaw;
        selectedStockName = [self subStrOf:selectedStockName between:@"<div class=\"title\"><h2>" andSecondString:@"</h2>"];
        selectedStockName = [self cleanUpHTML:selectedStockName];
        
        NSString *leftDelimiter;
        NSString *formatting;
        
        leftDelimiter = [NSString stringWithFormat:@"%@%@%@", @"<span id=\"yfs_l84_", [selectedETF lowercaseString], @"\">"];
        formatting = [self subStrOf:headingNodesRaw between:leftDelimiter andSecondString:@"</span>"];
        
        currentPrice = @"$";
        currentPrice = [currentPrice stringByAppendingString:formatting];
    }
    
    summaryXpathQueryString = @"//div[@id='yfi_quote_summary_data']//td[@class='yfnc_tabledata1']";
    
    NSArray *summaryNodes = [summaryParser searchWithXPathQuery:summaryXpathQueryString];
    
    // When "Market Cap" is provided then this is not an ETF implying that "Net Assetts"
    // and "YTD Return" values will be replaced with Beta and "Next Reporting Period" values.
    if ([summaryNodes count] > 11) {
        element = [summaryNodes objectAtIndex:11];
        NSString *marketCapRaw;
        marketCapRaw = [element raw];
        
        NSRange textRange;
        textRange =[[marketCapRaw lowercaseString] rangeOfString:[@"yfs_j10_" lowercaseString]];
        
        if(textRange.location == NSNotFound)
        {
            bNotAnETF = NO;
        } else {
            bNotAnETF = YES;
        }
    }
    
    if ([summaryNodes count] > 0) {
        element = [summaryNodes objectAtIndex:0];
    
        previousClose = [[element firstChild] content];
    }
    
    if ([summaryNodes count] > 1) {
        element = [summaryNodes objectAtIndex:1];
    
        openAmount = [[element firstChild] content];
    }
    
    // <td class="yfnc_tabledata1">143.43B</td> "Net Assetts" or
    // <td class="yfnc_tabledata1">0.58</td>    "Beta
    if ([summaryNodes count] > 5) {
        element = [summaryNodes objectAtIndex:5];
        netAssetsOrBeta = [[element firstChild] content];
    }
    
    if ([summaryNodes count] > 6) {
        element = [summaryNodes objectAtIndex:6];

        returnYTDOrNextEarningsDate = [[element firstChild] content];
    }

    if ([summaryNodes count] > 7) {
        // <td class="yfnc_tabledata1"><span><span id="yfs_g53_voo">77.88</span></span> - <span><span id="yfs_h53_voo">78.21</span></span></td> or
        // <td class="yfnc_tabledata1"><span>N/A</span> - <span>N/A</span></td>
        element = [summaryNodes objectAtIndex:7];
        daysInRangeRaw = [element raw];

        NSString *leftDelimiter = [NSString stringWithFormat:@"%@%@%@", @"id=\"yfs_g53_", [selectedETF lowercaseString], @"\">"];
        NSRange textRange;
        textRange =[[daysInRangeRaw lowercaseString] rangeOfString:leftDelimiter];
        
        if(textRange.location != NSNotFound)
        {
            daysRange = [self subStrOf:daysInRangeRaw between:leftDelimiter andSecondString:@"</span>"];
            daysRange = [daysRange stringByAppendingString:@" - "];
            NSString *secondLeftDelimiter = [NSString stringWithFormat:@"%@%@%@", @"id=\"yfs_h53_", [selectedETF lowercaseString], @"\">"];
            daysRange = [daysRange stringByAppendingString:[self subStrOf:daysInRangeRaw between:secondLeftDelimiter  andSecondString:@"</span>"]];
        } else {
            daysRange = @"N/A";
        }
    }
    
    // <td class="yfnc_tabledata1"><span>385.10</span> - <span>652.79</span></td>
    //
    if ([summaryNodes count] > 8) {
        element = [summaryNodes objectAtIndex:8];
        NSString *yearInRangeRaw = [element raw];
        
        fiftyTwoWeekRange = [self subStrOf:yearInRangeRaw between:@"<span>" andSecondString:@"</span>"];
        
        fiftyTwoWeekRange = [fiftyTwoWeekRange stringByAppendingString:@" - "];
        
        fiftyTwoWeekRange = [fiftyTwoWeekRange stringByAppendingString:[self subStrOf:yearInRangeRaw between:@" - <span>" andSecondString:@"</span>"]];
    }

    if ([summaryNodes count] > 9) {
        element = [summaryNodes objectAtIndex:9];
        volumeAmount = [element raw];
    
        NSLog(@"volumeAmount is %@", volumeAmount);
        volumeAmount = [self subStrOf:volumeAmount between:[NSString stringWithFormat:@"%@%@%@", @"id=\"yfs_v53_", [selectedETF lowercaseString], @"\">"] andSecondString:@"</span"];
    }
    
    if ([summaryNodes count] > 10) {
        // <td class="yfnc_tabledata1"><span id="yfs_v53_xxxx">28,336</span></td>" where: _xxxx is _symbol in lower case
        element = [summaryNodes objectAtIndex:10];
        average3MVolume = [[element firstChild] content];
    }
    
    if ([summaryNodes count] > 11) {
        // Market Cap or <td class="yfnc_tabledata1"><span id="yfs_j10_aapl">453.05B</span></td> where: _xxxx is _symbol in lower case
        // P/E           <td class="yfnc_tabledata1">15</td>

        element = [summaryNodes objectAtIndex:11];
        NSString *priceToEarningsOrMarketCapRaw = [element raw];
        
        if (bNotAnETF == YES)
        {
            marketCap = [self subStrOf:priceToEarningsOrMarketCapRaw between:[NSString stringWithFormat:@"%@%@%@", @"id=\"yfs_j10_", [selectedETF lowercaseString], @"\">"] andSecondString:@"</span"];
        } else {
            priceToEarnings = [[element firstChild] content];
        }
    }
    
    if ([summaryNodes count] > 12) {
        // Yield or <td class="yfnc_tabledata1"><yield>2.04</yield></td>
        // P/E      <td class="yfnc_tabledata1">12.48</td>
        // bNotAnETF will be true when Yield is present otherwise P/E
        element = [summaryNodes objectAtIndex:12];
        yieldOrPriceToEarnings = [element raw];

        if (bNotAnETF == YES)
        {
            yieldOrPriceToEarnings = [[element firstChild]content];
        } else {
            yieldOrPriceToEarnings = [self subStrOf:yieldOrPriceToEarnings between:@"<yield>" andSecondString:@"</yield>"];
        }
    }
    
    if ([summaryNodes count] > 13) {
        // EPS (ttm) <td class="yfnc_tabledata1">40.11</td>
        // bNotAnETF will be true when this element is present
        element = [summaryNodes objectAtIndex:13];
        earningsPerShare = [[element firstChild]content];
    }
    
    if ([summaryNodes count] > 14) {
        // Dividend and Yield <td class="yfnc_tabledata1">12.20 (2.50%) </td>
        // bNotAnETF will be true when this element is present
        element = [summaryNodes objectAtIndex:14];
        dividendAndYield = [[element firstChild]content];
    }

    self.descriptionETF.text = selectedStockName;
    
    self.currentValue.text = currentPrice;
    
    self.previousClose.text = previousClose;
    
    self.netAssetts.text = netAssetsOrBeta;
    
    if (bNotAnETF == YES) {
        _yieldOrMarketCapTitle.text = @"Market Cap:";
        _return5YOrDivAndYieldTitle.text = @"Div & Yield:";
        _return3YOrEPSTitle.text = @"EPS (ttm):";
        _ytdOrNextReportingTitle.text = @"Next Earnings Date:";
        _netAssettsOrBetaTitle.text = @"Beta:";
    } else {
        _yieldOrMarketCapTitle.text = @"Yield:";
        _return5YOrDivAndYieldTitle.text = @"Beta (3y):";
        _return3YOrEPSTitle.text = @"3y Avg Return:";
        _ytdOrNextReportingTitle.text = @"YTD return:";
        _netAssettsOrBetaTitle.text = @"Net assetts:";
    }

    self.volumeOfTrading.text = volumeAmount;
    
    self.openValue.text = openAmount;
    
    self.currentValue.text = currentPrice;
    
    self.daysRange.text = daysRange;
    
    self.fiftyTwoWeekRange.text = fiftyTwoWeekRange;
    
    self.ytdReturn.text = returnYTDOrNextEarningsDate;
    
    self.last3MAverageVolume.text = average3MVolume;
    
    if (bNotAnETF == YES) {
        self.priceToEarnings.text = yieldOrPriceToEarnings;
    } else {
        self.priceToEarnings.text = priceToEarnings;
    }
    
    if (bNotAnETF == YES) {
        self.marketCap.text = marketCap;
    } else {
        self.marketCap.text = yieldOrPriceToEarnings;
    }
    
    summaryXpathQueryString = @"//div[@id='yfi_perf_risk']//div[@class='bd']";
    
    summaryNodes = [summaryParser searchWithXPathQuery:summaryXpathQueryString];
    // <div class="bd"><table><tr><td class="yfnc_tablehead1">YTD Return:</td><td class="yfnc_tabledata1">19.88%</td></tr><tr><td class="yfnc_tablehead1">3y Avg Return:</td><td class="yfnc_tabledata1">16.24%</td></tr><tr><td class="yfnc_tablehead1">5y Avg Return:</td><td class="yfnc_tabledata1">N/A</td></tr><tr><td class="yfnc_tablehead1">Beta (3y):</td><td class="yfnc_tabledata1">1.00</td></tr></table></div>

    if ([summaryNodes count] > 0) {
        NSString *performanceRiskRaw = [[summaryNodes objectAtIndex:0] raw];
        
        last3YReturn = [self subStrOf:performanceRiskRaw between:@"3y Avg Return:</td><td class=\"yfnc_tabledata1\">" andSecondString:@"</td>"];
        beta3y = [self subStrOf:performanceRiskRaw between:@"Beta (3y):</td><td class=\"yfnc_tabledata1\">" andSecondString:@"</td>"];
    }
    else {
        last3YReturn = @"N/A";
        beta3y = @"N/A";
    }
    
    summaryXpathQueryString = @"//div[@id='yfi_business_summary']//div[@class='bd']";
    
    summaryNodes = [summaryParser searchWithXPathQuery:summaryXpathQueryString];
    
    if (summaryNodes !=nil && [summaryNodes count] > 0) {
        element = [summaryNodes objectAtIndex:0];
        NSString *summary = [[element firstChild] content];
        /*
        <div class="bd">The investment seeks to track the performance of a benchmark index that measures the investment return of large-capitalization stocks.
        The fund employs an indexing investment approach designed to track the performance of the Standard &amp; Poor&amp;#39;s 500 Index, a widely recognized benchmark of U.S. stock market performance that is dominated by the stocks of large U.S. companies. It attempts to replicate the target index by investing all, or substantially all, of its assets in the stocks that make up the index, holding each stock in approximately the same proportion as its weighting in the index. <a href="/q/pr?s=VOO" class="view_more">View More</a></div>
         */
        
        summary = [self cleanUpHTML:summary];
        
        self.summaryLabel.text = summary;
        self.summaryLabel.numberOfLines=0;
        self.summaryLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.summaryLabel sizeToFit];
    } else {
        self.summaryLabel.text = @"";
    }
    
    if (bNotAnETF == YES) {
        self.last3YReturn.text = earningsPerShare;
    } else {
        self.last3YReturn.text = last3YReturn;
    }
    
    if (bNotAnETF == YES) {
        self.betaOrDividendAndYield.text = dividendAndYield;
    } else {
        self.betaOrDividendAndYield.text = beta3y;
    }
}

-(void)reloadData
{
    NSUserDefaults *standardDefaults=[NSUserDefaults standardUserDefaults];
    NSString *selectedETF = [standardDefaults objectForKey:@"selectedETF"];
    
    // Pull trading values
    if (selectedETF.length > 0) {
        
        // If not intraday interrogation
        if ([graphZoomSelector selectedSegmentIndex] > 0) {
            
            endTime           = [NSDate date];
            
            switch ([graphZoomSelector selectedSegmentIndex])
            {
                case 1:  // "1w"
                    startTime = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 7.0];
                    break;
                case 2:  // "1m"
                    startTime = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 7.0 * 4.0];
                    break;
                case 3:  // "6m"
                    startTime = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 7.0 * 26.0];
                    break;
                case 4:  // "1yr"
                    startTime = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 7.0 * 52.0];
                    break;
                default: // "1w"
                    NSLog(@"||Invalid index for graph zoom selector is %ld", (long)[graphZoomSelector selectedSegmentIndex]);
                    startTime = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 7.0];
                    break;
            }
            // Retrieve Historical data
            stockPuller = [[SPYahooGetStock alloc] initWithTargetSymbol:selectedETF targetStartDate:startTime targetEndDate:endTime];
            [self setStockPuller:stockPuller];
            [stockPuller setDelegate:self];
            
        // Retrieve intraday values
        } else {
            activityPuller = [[SPYahooGetIntraDayActivity alloc] initWithTargetSymbol:selectedETF];
            [self setActivityPuller:activityPuller];
            [activityPuller setDelegate:self];
        }
    }
}

-(void)graphSelectionMade
{
    NSArray *buttonsInGraphSelector = [graphZoomSelector subviews];
    for (NSInteger i = 0; i < [buttonsInGraphSelector count]; i++)
    {
        if (graphZoomSelector.selectedSegmentIndex == i) {
            [[buttonsInGraphSelector objectAtIndex:i] setTintColor:[UIColor redColor]];
        } else {
            [[buttonsInGraphSelector objectAtIndex:i] setTintColor:[UIColor blueColor]];
        }
    }
}

-(bool) shouldAutorotateToInterfaceOrientation
{
    // All orientations supported
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateLayoutForNewOrientation: interfaceOrientation];
}

// set up ULO (Upper Left Orientation) mode graph boundaries
#define heightOfGraph 175
#define widthOfGraph 275.0
#define leftMost 20
#define topMost 75
#define bottomMost 250

- (void) drawDecorativeLines
{
    NSArray* sublayers = [NSArray arrayWithArray:self.scrollView.layer.sublayers];
    for (CAShapeLayer *layer in sublayers) {
        if ([layer.name isEqualToString:@"LineLayer"]) {
            [layer removeFromSuperlayer];
        }
    }
    
    CAShapeLayer *lineShape;
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable();
    lineShape = [CAShapeLayer layer];
    [lineShape setName:@"LineLayer"];
    [lineShape setFillColor:nil];
    
    lineShape.lineWidth = 1.5f;
    lineShape.strokeColor = [[UIColor colorWithRed:0x8c/255.0f green:0x8c/255.0f  blue:0x8c/255.0f  alpha:1.0f] CGColor];
    
    // Decorative line under the graph
    CGPathMoveToPoint(linePath, NULL, leftMost, bottomMost);
    CGPathAddLineToPoint(linePath, NULL, (leftMost + widthOfGraph), bottomMost);
    
    lineShape.lineWidth = 1.0f;
    // Decorative line under 'Fundamentals'
    CGPathMoveToPoint(linePath, NULL, 0, (bottomMost + 200));
    CGPathAddLineToPoint(linePath, NULL, 45, (bottomMost + 200));
    CGPathAddLineToPoint(linePath, NULL, 55, (bottomMost + 190));
    CGPathAddLineToPoint(linePath, NULL, 65, (bottomMost + 200));
    CGPathAddLineToPoint(linePath, NULL, 640, (bottomMost + 200));
    
    // Decorative line over 'Top Ten Holdings'
    CGPathMoveToPoint(linePath, NULL, 0, (bottomMost + 566));
    CGPathAddLineToPoint(linePath, NULL, 640, (bottomMost + 566));
    
    // Decorative line under 'Top Ten Holdings'
    CGPathMoveToPoint(linePath, NULL, 0, (bottomMost + 612));
    CGPathAddLineToPoint(linePath, NULL, 45, (bottomMost + 612));
    CGPathAddLineToPoint(linePath, NULL, 55, (bottomMost + 602));
    CGPathAddLineToPoint(linePath, NULL, 65, (bottomMost + 612));
    CGPathAddLineToPoint(linePath, NULL, 640, (bottomMost + 612));
    lineShape.path = linePath;
    
    // Decorative line over 'Business Summary'
    CGPathMoveToPoint(linePath, NULL, 0, (bottomMost + 909));
    CGPathAddLineToPoint(linePath, NULL, 640, (bottomMost + 909));
    
    // Decorative line under 'Business Summary'
    CGPathMoveToPoint(linePath, NULL, 0, (bottomMost + 957));
    CGPathAddLineToPoint(linePath, NULL, 45, (bottomMost + 957));
    CGPathAddLineToPoint(linePath, NULL, 55, (bottomMost + 947));
    CGPathAddLineToPoint(linePath, NULL, 65, (bottomMost + 957));
    CGPathAddLineToPoint(linePath, NULL, 640, (bottomMost + 957));
    lineShape.path = linePath;
    
    [self.scrollView.layer addSublayer:lineShape];
    CGPathRelease(linePath);
}

- (void) drawIntraDayGraph
{
    NSArray* sublayers = [NSArray arrayWithArray:self.scrollView.layer.sublayers];
    for (CAShapeLayer *layer in sublayers) {
        if ([layer.name isEqualToString:@"GraphLayer"] ||
            [layer.name isEqualToString:@"DotLayer"]) {
            [layer removeFromSuperlayer];
        }
    }
    
    CAShapeLayer *lineShape;
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable();
    lineShape = [CAShapeLayer layer];
    [lineShape setName:@"GraphLayer"];
    [lineShape setFillColor:nil];
    
    if ([activityPuller.activityValue count] < 3) {
        NSLog(@"Not enouph points to plot");
        return;
    } else {
        NSLog(@"In drawIntraDayGraph to plot %u points", [activityPuller.activityValue count] - 1);
    }
    
    lineShape.lineWidth = 2.0f;
    lineShape.lineCap = kCALineCapRound;
    lineShape.strokeColor = [[UIColor colorWithRed:0xa5/255.0f green:0xd7/255.0f  blue:0x6e/255.0f  alpha:1.0f] CGColor];
    
    double eachHigh;
    
    // Compute range of values to determine where to position first point
    double overallHigh;
    double overallLowestHigh;
    unsigned long limit = [activityPuller.activityValue count];
    eachHigh = [[[activityPuller.activityValue objectAtIndex:0] objectForKey:@"high"] doubleValue];
    overallHigh = eachHigh;
    overallLowestHigh = eachHigh;
    for (unsigned long j = 1; j < limit; j++) {
        eachHigh = [[[activityPuller.activityValue objectAtIndex:j] objectForKey:@"high"] doubleValue];
        
        if (overallHigh < eachHigh) {
            overallHigh = eachHigh;
        }
        if (overallLowestHigh > eachHigh) {
            overallLowestHigh = eachHigh;
        }
    }
    
    int i;
    
    double x;
    
    i = 0;
    
    double eachWidthOfPoint;
    if (limit <= widthOfGraph) {
        eachWidthOfPoint = widthOfGraph / limit;
    } else if (limit <= widthOfGraph) {
        eachWidthOfPoint = 1;
    } else if (limit <= (widthOfGraph * 2)) {
        eachWidthOfPoint = .5;
    } else {
        NSLog(@"Number of points exceed the available graph width");
        eachWidthOfPoint = .5;
    }
    
    double yRange = overallHigh - overallLowestHigh;
    
    double eachHeightOfPoint;
    
    eachHeightOfPoint = heightOfGraph / yRange;
    
    double firstYPointValue = [[[activityPuller.activityValue objectAtIndex:i] objectForKey:@"high"] doubleValue];
    i++;
    
    double firstYPosition;
    
    // Determine where "first" point is located in relation to the range of points to be plotted.
    firstYPosition = (firstYPointValue - overallLowestHigh) * eachHeightOfPoint;
    
    // The '(bottomMost - ' applied to each yPosition provides the transformation from LLO to ULO
    CGPathMoveToPoint(linePath, NULL, leftMost, (bottomMost - firstYPosition));

    double nextYPosition;
    for (x = (leftMost + eachWidthOfPoint); i < limit; i++, x = x + eachWidthOfPoint) {
        
        double nextYPointValue = [[[activityPuller.activityValue objectAtIndex:i] objectForKey:@"high"] doubleValue];
        
        nextYPosition = (nextYPointValue - overallLowestHigh) * eachHeightOfPoint;
        
        CGPathAddLineToPoint(linePath, NULL, x, (bottomMost - nextYPosition));
    }
    x = x - eachWidthOfPoint;
    
    lineShape.path = linePath;
    
    // Add drawn graph to the subLayer
    [self.scrollView.layer addSublayer:lineShape];
    
    // Get the last timeStamp value and format for display under the colored circle
    NSTimeInterval timeInterval = [[[activityPuller.activityValue objectAtIndex:[activityPuller.activityValue count] - 1] objectForKey:@"timeStamp"] doubleValue];

    NSDate *marketTime = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    self.currentTradeTime.text = [formatter stringFromDate:marketTime];
    CGRect frame;
    frame = self.currentTradeTime.frame;
    frame.origin.x = x - 20;
    self.currentTradeTime.frame = frame;
    
    CGPathRelease(linePath);
    
    // Draw the circle at the end of the graph line
    CAShapeLayer *circleShape;
    
    circleShape = [CAShapeLayer layer];
    // Create a circle with 5-point width/height.
    circleShape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 5, 5)].CGPath;
    
    [circleShape setName:@"DotLayer"];
    
    circleShape.position = CGPointMake(x, (bottomMost - nextYPosition));
    
    circleShape.fillColor = [UIColor lightGrayColor].CGColor;
    circleShape.strokeColor = [UIColor lightGrayColor].CGColor;
    circleShape.lineWidth = 1.0;

    [self.scrollView.layer addSublayer:circleShape];
}

- (void) drawGraph
{
    NSArray* sublayers = [NSArray arrayWithArray:self.scrollView.layer.sublayers];
    for (CAShapeLayer *layer in sublayers) {
        if ([layer.name isEqualToString:@"GraphLayer"] ||
            [layer.name isEqualToString:@"DotLayer"]) {
            [layer removeFromSuperlayer];
        }
    }
    
    CAShapeLayer *lineShape;
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable(); 
    lineShape = [CAShapeLayer layer];
    [lineShape setName:@"GraphLayer"];
    [lineShape setFillColor:nil];
    
    if ([stockPuller.tradingValue count] < 3) {
        NSLog(@"Not enouph points to plot");
        return;
    } else {
        NSLog(@"In drawGraph to plot %u points", [stockPuller.tradingValue count] - 1);
    }
    
    lineShape.lineWidth = 2.0f;
    lineShape.lineCap = kCALineCapRound;
    lineShape.strokeColor = [[UIColor colorWithRed:0xa5/255.0f green:0xd7/255.0f  blue:0x6e/255.0f  alpha:1.0f] CGColor];
    
    double eachHigh;
    
    // Compute range of values to determine where to position first point
    double overallHigh;
    double overallLowestHigh;
    int limit = (int)[stockPuller.tradingValue count];
    eachHigh = [[[stockPuller.tradingValue objectAtIndex:0] objectForKey:@"high"] doubleValue];
    overallHigh = eachHigh;
    overallLowestHigh = eachHigh;
    for (int j = 1; j < limit; j++) {
        eachHigh = [[[stockPuller.tradingValue objectAtIndex:j] objectForKey:@"high"] doubleValue];
        
        if (overallHigh < eachHigh) {
            overallHigh = eachHigh;
        }
        if (overallLowestHigh > eachHigh) {
            overallLowestHigh = eachHigh;
        }
    }
    
    int i, x;
    
    i = (int)[stockPuller.tradingValue count] - 1;

    double eachWidthOfPoint;
    if (limit <= widthOfGraph) {
        eachWidthOfPoint = widthOfGraph / limit;
    } else {
        // plot points to a off screen buffer that will be scaled to fit with transform
        eachWidthOfPoint = 1;
    }

    double yRange = overallHigh - overallLowestHigh;
    
    double eachHeightOfPoint;

    eachHeightOfPoint = heightOfGraph / yRange;
    
    double firstYPointValue = [[[stockPuller.tradingValue objectAtIndex:i] objectForKey:@"high"] doubleValue];
    i--;
    
    double firstYPosition;
    
     // Determine where "first" point is located in relation to the range of points to be plotted.
    firstYPosition = (firstYPointValue - overallLowestHigh) * eachHeightOfPoint;
    
    // The '(bottomMost - ' applied to each yPosition provides the transformation from LLO to ULO
    CGPathMoveToPoint(linePath, NULL, leftMost, (bottomMost - firstYPosition));
   
    for (x = (leftMost + eachWidthOfPoint); i > -1; i--, x = x + eachWidthOfPoint) {
        
        double nextYPointValue = [[[stockPuller.tradingValue objectAtIndex:i] objectForKey:@"high"] doubleValue];
        
        double nextYPosition = (nextYPointValue - overallLowestHigh) * eachHeightOfPoint;
        
        CGPathAddLineToPoint(linePath, NULL, x, (bottomMost - nextYPosition));
    }
     
    lineShape.path = linePath;
    
    self.currentTradeTime.text = @"";

    [self.scrollView.layer addSublayer:lineShape];
    CGPathRelease(linePath);
}

- (void)holdingTouchUp:(UIButton*)sender{
    
    if ([sender.titleLabel.text isEqualToString:@"N/A"]) {
        
    } else if (sender.titleLabel.text.length > 0) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:sender.titleLabel.text forKey:@"selectedETF"];
        [userDefault synchronize];
        
        NSString *selectedETF = [userDefault objectForKey:@"selectedETF"];
        NSLog(@"The new selected ETF is %@", selectedETF);
        
        [self reloadData];
    }
}

-(void)viewDidLoad
{
    NSUserDefaults *standardDefaults=[NSUserDefaults standardUserDefaults];
    NSString *selectedETF = [standardDefaults objectForKey:@"selectedETF"];
    
    // Retrieve Top Ten Holdings by scraping Yahoo financial page (e.g. http://finance.yahoo.com/q/hl?s=VOO+Holdings)
    [self performSelectorInBackground:@selector(scrapeHoldings:) withObject:selectedETF];
    
    // For YTD Return and Net Assetts scrape http://finance.yahoo.com/q?s=VOO
    [self performSelectorInBackground:@selector(scrapeSummary:) withObject:selectedETF];
    
    [self.firstHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.thirdHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.fourthHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.fifthHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.sixthHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.seventhHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.eighthHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.ninthHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.tenthHolding addTarget:self action:@selector(holdingTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
    _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight);
    
    _graphView.autoresizingMask =(UIViewAutoresizingFlexibleWidth |
                                  UIViewAutoresizingFlexibleHeight);
    
    // Retain aspect ratio of graph so findings will not be distorted on screen orientation change
    _scrollView.contentMode = UIViewContentModeScaleAspectFit;
    _graphView.contentMode = UIViewContentModeCenter;
        
    // Create horizontal graph time range selector (i.e. 1d, 1w, 1m...)
    NSArray *itemArray = [NSArray arrayWithObjects: @"1d", @"1w", @"1m", @"6m", @"1yr", nil];
    
    graphZoomSelector = [[UISegmentedControl alloc] initWithItems:itemArray];
    
    graphZoomSelector.backgroundColor = [UIColor colorWithRed:0xff/255.0 green:0xff/255.0  blue:0xff/255.0  alpha:1.0f];
    
    graphZoomSelector.tintColor = [UIColor colorWithRed:0xff/255.0 green:0xd2/255.0  blue:0x5a/255.0  alpha:1.0f];
    
    graphZoomSelector.segmentedControlStyle = 7;

    graphZoomSelector.selectedSegmentIndex = zoomSelection = 1;
    
    [graphZoomSelector addTarget:self
                         action:@selector(pickOne:)
               forControlEvents:UIControlEventValueChanged];
    
    [self.scrollView addSubview:graphZoomSelector];
    
    endTime   = [NSDate date];
    startTime = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 1.0 * 4.0];
    
    [self drawDecorativeLines];
    
    [self reloadData];
}

-(void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    [self updateLayoutForNewOrientation: self.interfaceOrientation];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = self.contentView.frame.size;
}

//Action method executes when user touches the graph zoom selector bar
-(void) pickOne:(id)sender
{
    if (zoomSelection != [sender selectedSegmentIndex]) {
        graphZoomSelector = (UISegmentedControl *)sender;
        zoomSelection = (int)[sender selectedSegmentIndex];
        [self reloadData];
    }
}

// Prior to iOS 6
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// For iOS 6 and up
- (BOOL)shouldAutorotate {
    
    return YES;
}

-(void)didReceiveMemoryWarning
{
    NSLog(@"Out of memory received");
}

-(void)viewDidUnload
{
}

#pragma mark activityPuller call backs

-(void)activityPuller:(SPYahooGetIntraDayActivity *)dp downloadDidFailWithError:(NSError *)error
{
    NSLog(@"Download failure");
}

-(void)activityPullerActivityDidChange:(SPYahooGetIntraDayActivity *)dp;
{
    [self reloadData];
}

-(SPYahooGetIntraDayActivity *)activityPuller
{
    //NSLog(@"in -activityPuller, returned activityPuller = %@", activityPuller);
    
    return activityPuller;
}

-(void)activityPullerDidFinishFetch:(SPYahooGetIntraDayActivity *)dp
{
    NSLog(@"activityPullerDidFinishFetch from thread %d", NSThread.isMainThread);
    [self drawIntraDayGraph];

    /*  To keep polling IntraDay activity uncomment the following
    NSUserDefaults *standardDefaults=[NSUserDefaults standardUserDefaults];
    NSString *selectedETF = [standardDefaults objectForKey:@"selectedETF"];
     
    double delayInSeconds = 20;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        activityPuller = [[SPYahooGetIntraDayActivity alloc] initWithTargetSymbol:selectedETF];
        [self setActivityPuller:activityPuller];
        [activityPuller setDelegate:self];
    });
     */
}

-(void)setActivityPuller:(SPYahooGetIntraDayActivity *)aActivityPuller
{
    if ( activityPuller != aActivityPuller ) {
        activityPuller = aActivityPuller;
    }
}

#pragma mark stockPuller call backs

-(void)stockPuller:(SPYahooGetStock *)dp downloadDidFailWithError:(NSError *)error
{
    NSLog(@"Download failure");
}

-(void)stockPullerStockDidChange:(SPYahooGetStock *)dp;
{
    [self reloadData];
}

-(SPYahooGetStock *)stockPuller
{
    //NSLog(@"in -stockPuller, returned stockPuller = %@", stockPuller);
    
    return stockPuller;
}

-(void)stockPullerDidFinishFetch:(SPYahooGetStock *)dp
{
    NSLog(@"stockPullerDidFinishFetch from thread %d", NSThread.isMainThread);
    [self drawGraph];
    
}

-(void)setStockPuller:(SPYahooGetStock *)aStockPuller
{   
    if ( stockPuller != aStockPuller ) {
        stockPuller = aStockPuller;
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self drawDecorativeLines];
}

#pragma mark iAd_Callbacks

- (void) bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:1];
    
    [banner setAlpha:1];
    
    [UIView commitAnimations];
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:1];
    
    [banner setAlpha:0];
    
    [UIView commitAnimations];
}

// Landscape/Portrait screen item oreintation

- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation
{
    CGSize viewAreaSize = [UIApplication viewSize];
    
    self.scrollView.contentSize = CGSizeMake(viewAreaSize.width, 1800);
    
    NSLog(@"updateLayoutForNewOrientation self.scrollView.contentSize width/height is %f/%f\n", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    graphZoomSelector.frame = CGRectMake(0, 285, viewAreaSize.width, 50);
    
    CGPoint c;
    
    if (orientation == UIDeviceOrientationPortrait ||
        orientation == UIDeviceOrientationPortraitUpsideDown) { // Width is 320
        c = _percentOfGrowth.center;
        c.x = 252;
        _percentOfGrowth.center = c;
        
        c = _daysRange.center;
        c.x = 230;
        _daysRange.center = c;
        
        c = _fiftyTwoWeekRange.center;
        c.x = 230;
        _fiftyTwoWeekRange.center = c;
        
        c = _previousClose.center;
        c.x = 230;
        _previousClose.center = c;
        
        c = _openValue.center;
        c.x = 230;
        _openValue.center = c;
        
        c = _volumeOfTrading.center;
        c.x = 230;
        _volumeOfTrading.center = c;
        
        c = _last3MAverageVolume.center;
        c.x = 230;
        _last3MAverageVolume.center = c;
        
        c = _marketCap.center;
        c.x = 230;
        _marketCap.center = c;
        
        c = _priceToEarnings.center;
        c.x = 230;
        _priceToEarnings.center = c;
        
        c = _netAssetts.center;
        c.x = 230;
        _netAssetts.center = c;
        
        c = _ytdReturn.center;
        c.x = 230;
        _ytdReturn.center = c;
        
        c = _last3YReturn.center;
        c.x = 230;
        _last3YReturn.center = c;
        
        c = _betaOrDividendAndYield.center;
        c.x = 230;
        _betaOrDividendAndYield.center = c;
        
        c = _firstHoldingPercent.center;
        c.x = 265;
        _firstHoldingPercent.center = c;
        
        c = _secondHoldingPercent.center;
        c.x = 265;
        _secondHoldingPercent.center = c;
        
        c = _thirdHoldingPercent.center;
        c.x = 265;
        _thirdHoldingPercent.center = c;
        
        c = _fourthHoldingPercent.center;
        c.x = 265;
        _fourthHoldingPercent.center = c;
        
        c = _fifthHoldingPercent.center;
        c.x = 265;
        _fifthHoldingPercent.center = c;
        
        c = _sixthHoldingPercent.center;
        c.x = 265;
        _sixthHoldingPercent.center = c;
        
        c = _seventhHoldingPercent.center;
        c.x = 265;
        _seventhHoldingPercent.center = c;
        
        c = _eighthHoldingPercent.center;
        c.x = 265;
        _eighthHoldingPercent.center = c;
        
        c = _ninthHoldingPercent.center;
        c.x = 265;
        _ninthHoldingPercent.center = c;
        
        c = _tenthHoldingPercent.center;
        c.x = 265;
        _tenthHoldingPercent.center = c;
        
        c = _firstHolding.center;
        c.x = 213;
        _firstHolding.center = c;
        
        c = _secondHolding.center;
        c.x = 213;
        _secondHolding.center = c;
        
        c = _thirdHolding.center;
        c.x = 213;
        _thirdHolding.center = c;
        
        c = _fourthHolding.center;
        c.x = 213;
        _fourthHolding.center = c;
        
        c = _fifthHolding.center;
        c.x = 213;
        _fifthHolding.center = c;
        
        c = _sixthHolding.center;
        c.x = 213;
        _sixthHolding.center = c;
        
        c = _seventhHolding.center;
        c.x = 213;
        _seventhHolding.center = c;
        
        c = _eighthHolding.center;
        c.x = 213;
        _eighthHolding.center = c;
        
        c = _ninthHolding.center;
        c.x = 213;
        _ninthHolding.center = c;
        
        c = _tenthHolding.center;
        c.x = 213;
        _tenthHolding.center = c;
        
        c = _summaryLabel.center;
        c.x = 160;
        _summaryLabel.center = c;
        
    } else {  // Landscape mode (i.e. width is 480)
        
        c = _percentOfGrowth.center;
        c.x = 412;
        _percentOfGrowth.center = c;
        
        c = _daysRange.center;
        c.x = 470;
        _daysRange.center = c;
        
        c = _fiftyTwoWeekRange.center;
        c.x = 470;
        _fiftyTwoWeekRange.center = c;
        
        c = _previousClose.center;
        c.x = 470;
        _previousClose.center = c;
        
        c = _openValue.center;
        c.x = 470;
        _openValue.center = c;
        
        c = _volumeOfTrading.center;
        c.x = 470;
        _volumeOfTrading.center = c;
        
        c = _last3MAverageVolume.center;
        c.x = 470;
        _last3MAverageVolume.center = c;
        
        c = _marketCap.center;
        c.x = 470;
        _marketCap.center = c;
        
        c = _priceToEarnings.center;
        c.x = 470;
        _priceToEarnings.center = c;
        
        c = _daysRange.center;
        c.x = 470;
        _daysRange.center = c;
        
        c = _netAssetts.center;
        c.x = 470;
        _netAssetts.center = c;
        
        c = _ytdReturn.center;
        c.x = 470;
        _ytdReturn.center = c;
        
        c = _last3YReturn.center;
        c.x = 470;
        _last3YReturn.center = c;
        
        c = _betaOrDividendAndYield.center;
        c.x = 470;
        _betaOrDividendAndYield.center = c;
        
        c = _firstHoldingPercent.center;
        c.x = 440;
        _firstHoldingPercent.center = c;
        
        c = _secondHoldingPercent.center;
        c.x = 440;
        _secondHoldingPercent.center = c;
        
        c = _thirdHoldingPercent.center;
        c.x = 440;
        _thirdHoldingPercent.center = c;
        
        c = _fourthHoldingPercent.center;
        c.x = 440;
        _fourthHoldingPercent.center = c;
        
        c = _fifthHoldingPercent.center;
        c.x = 440;
        _fifthHoldingPercent.center = c;
        
        c = _sixthHoldingPercent.center;
        c.x = 440;
        _sixthHoldingPercent.center = c;
        
        c = _seventhHoldingPercent.center;
        c.x = 440;
        _seventhHoldingPercent.center = c;
        
        c = _eighthHoldingPercent.center;
        c.x = 440;
        _eighthHoldingPercent.center = c;
        
        c = _ninthHoldingPercent.center;
        c.x = 440;
        _ninthHoldingPercent.center = c;
        
        c = _tenthHoldingPercent.center;
        c.x = 440;
        _tenthHoldingPercent.center = c;
        
        c = _firstHolding.center;
        c.x = 293;
        _firstHolding.center = c;
        
        c = _secondHolding.center;
        c.x = 293;
        _secondHolding.center = c;
        
        c = _thirdHolding.center;
        c.x = 293;
        _thirdHolding.center = c;
        
        c = _fourthHolding.center;
        c.x = 293;
        _fourthHolding.center = c;
        
        c = _fifthHolding.center;
        c.x = 293;
        _fifthHolding.center = c;
        
        c = _sixthHolding.center;
        c.x = 293;
        _sixthHolding.center = c;
        
        c = _seventhHolding.center;
        c.x = 293;
        _seventhHolding.center = c;
        
        c = _eighthHolding.center;
        c.x = 293;
        _eighthHolding.center = c;
        
        c = _ninthHolding.center;
        c.x = 293;
        _ninthHolding.center = c;
        
        c = _tenthHolding.center;
        c.x = 293;
        _tenthHolding.center = c;
        
        c = _summaryLabel.center;
        c.x = 280;
        _summaryLabel.center = c;
    }
}

@end

