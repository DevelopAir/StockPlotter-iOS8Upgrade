//
//  SPAppDelegate.h
//  Stock Plotter
//
//  Created by Paul Duncanson.
//  Change History:
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SPMasterViewController.h"
#import "Stock.h"
#import "Exchange.h"
#import "Industry.h"
#import "StockType.h"
#import "Investments.h"

@interface SPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

