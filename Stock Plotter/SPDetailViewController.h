//
//  SPDetailViewController.h
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Change History:
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TFHpple.h"
#import "SPAppDelegate.h"
#import "SPYahooGetStock.h"
#import "SPStockValue.h"
#import "SPYahooGetIntraDayActivity.h"

@interface SPDetailViewController : UIViewController <SPYahooGetStockDelegate, SPYahooGetIntraDayActivityDelegate, ADBannerViewDelegate>
{
    SPYahooGetStock *stockPuller;
    SPYahooGetIntraDayActivity *activityPuller;
@private
    CGPoint startPoint;
    CGPoint endPoint;
    NSDate *startTime;
    NSDate *endTime;
    UISegmentedControl *graphZoomSelector;
    int zoomSelection;
}

@property (nonatomic, retain) SPYahooGetStock *stockPuller;

// Protocol compliance from SPYahooGetStockDelegate
-(void)stockPullerDidFinishFetch:(SPYahooGetStock *)dp;
-(void)stockPullerStockDidChange:(SPYahooGetStock *)dp;
-(void)stockPuller:(SPYahooGetStock *)dp downloadDidFailWithError:(NSError *)error;

-(NSString *)subStrOf:(NSString *)fullString between:(NSString *)firstString andSecondString:(NSString *) secondString;

-(void)scrapeHoldings:(NSString *)selectedETF;
-(void)scrapeSummary:(NSString *)selectedETF;

@property (nonatomic, retain) SPYahooGetIntraDayActivity *activityPuller;

// Protocol compliance from SPYahooGetIntraDayActivityDelegate
-(void)activityPullerDidFinishFetch:(SPYahooGetIntraDayActivity *)dp;
-(void)activityPullerActivityDidChange:(SPYahooGetIntraDayActivity *)dp;
-(void)activityPuller:(SPYahooGetIntraDayActivity *)dp downloadDidFailWithError:(NSError *)error;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *descriptionETF;

@property (weak, nonatomic) IBOutlet UIView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *currentValue;
@property (weak, nonatomic) IBOutlet UILabel *percentOfGrowth;

@property (weak, nonatomic) IBOutlet UILabel *currentTradeTime;
@property (weak, nonatomic) IBOutlet UILabel *daysRange;
@property (weak, nonatomic) IBOutlet UILabel *fiftyTwoWeekRange;
@property (weak, nonatomic) IBOutlet UILabel *previousClose;
@property (weak, nonatomic) IBOutlet UILabel *openValue;
@property (weak, nonatomic) IBOutlet UILabel *volumeOfTrading;
@property (weak, nonatomic) IBOutlet UILabel *last3MAverageVolume;

@property (weak, nonatomic) IBOutlet UILabel *yieldOrMarketCapTitle;
@property (weak, nonatomic) IBOutlet UILabel *marketCap;

@property (weak, nonatomic) IBOutlet UILabel *priceToEarnings;

@property (weak, nonatomic) IBOutlet UILabel *netAssettsOrBetaTitle;
@property (weak, nonatomic) IBOutlet UILabel *netAssetts;

@property (weak, nonatomic) IBOutlet UILabel *ytdOrNextReportingTitle;
@property (weak, nonatomic) IBOutlet UILabel *ytdReturn;

@property (weak, nonatomic) IBOutlet UILabel *return3YOrEPSTitle;
@property (weak, nonatomic) IBOutlet UILabel *last3YReturn;

@property (weak, nonatomic) IBOutlet UILabel *return5YOrDivAndYieldTitle;
@property (weak, nonatomic) IBOutlet UILabel *betaOrDividendAndYield;

@property (weak, nonatomic) IBOutlet UILabel *firstHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *secondHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *thirdHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *fourthHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *fifthHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *sixthHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *seventhHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *eighthHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *ninthHoldingName;
@property (weak, nonatomic) IBOutlet UILabel *tenthHoldingName;

@property (weak, nonatomic) IBOutlet UIButton *firstHolding;
@property (weak, nonatomic) IBOutlet UIButton *secondHolding;
@property (weak, nonatomic) IBOutlet UIButton *thirdHolding;
@property (weak, nonatomic) IBOutlet UIButton *fourthHolding;
@property (weak, nonatomic) IBOutlet UIButton *fifthHolding;
@property (weak, nonatomic) IBOutlet UIButton *sixthHolding;
@property (weak, nonatomic) IBOutlet UIButton *seventhHolding;
@property (weak, nonatomic) IBOutlet UIButton *eighthHolding;
@property (weak, nonatomic) IBOutlet UIButton *ninthHolding;
@property (weak, nonatomic) IBOutlet UIButton *tenthHolding;
 
@property (weak, nonatomic) IBOutlet UILabel *firstHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *secondHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *thirdHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *fourthHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *fifthHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *sixthHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *seventhHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *eighthHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *ninthHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *tenthHoldingPercent;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@end
