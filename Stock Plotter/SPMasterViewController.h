//
//  SPMasterViewController.h
//  Stock Plotter
//
//  Created by Paul Duncanson on 9/22/13.
//  Change History:
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <iAd/iAd.h>
#import "SPYahooGetFundamentals.h"

@interface SPMasterViewController : UITableViewController <SPYahooGetFundamentalsDelegate, NSFetchedResultsControllerDelegate>
{
    SPYahooGetFundamentals *fundamentalsPuller;
    UIBarButtonItem *addButton;
    UIBarButtonItem *editButton;
}

@property (nonatomic, retain) SPYahooGetFundamentals *fundamentalsPuller;
@property (strong, nonatomic) NSMutableArray *investments;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Protocol compliance from corresponding delegate
-(void)fundamentalsPullerDidFinishFetch:(SPYahooGetFundamentals *)dp;
-(void)fundamentalsPullerFundamentalsDidChange:(SPYahooGetFundamentals *)dp;
-(void)fundamentalsPuller:(SPYahooGetFundamentals *)dp downloadDidFailWithError:(NSError *)error;
@end
