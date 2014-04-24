//
//  SPMasterViewController.m
//  Stock Plotter
//
//  Created by Paul Duncanson on 9/22/13.
//  Change History:
//

#import "SPMasterViewController.h"
#import "SPDetailViewController.h"

@interface SPMasterViewController () {
    
@private
    NSMutableArray *_investments;
}
@end

@implementation SPMasterViewController

@synthesize fundamentalsPuller;
@synthesize investments = _investments;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Uncomment following to reset NSUsersDefaults for first time testing.
    //NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //[standardDefaults setObject:@"VOO|VB|VWO|VNQ|CORP|GOVT" forKey:@"investmentList"];
    //[standardDefaults synchronize];
    //return [[self.fetchedResultsController sections] count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    //return [sectionInfo numberOfObjects];
    return [_investments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell != nil) {
        cell.textLabel.numberOfLines = 0;
        [cell.textLabel setText:[_investments objectAtIndex:[indexPath row]]];
        [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (BOOL)tableView: (UITableView *)tableView canMoveRowAtIndexPath: (NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Your ETF Investments", @"Your ETF Investments");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSMutableArray *) investments
{
    if (!_investments) {
        _investments = [NSMutableArray new];
    }
    return _investments;
}

-(void)reloadData
{    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults registerDefaults:@{@"investmentList": @"VOO|VB|VWO|VNQ|CORP|GOVT"}];
    [standardDefaults synchronize];
    
    NSString *symbolParm = [standardDefaults stringForKey:@"investmentList"];
    
    // Pull Fundamentals from ETF's
    if (symbolParm.length > 0) {
        fundamentalsPuller = [[SPYahooGetFundamentals alloc] initWithTargetSymbol:symbolParm];
        [self setFundamentalsPuller:fundamentalsPuller];
        [fundamentalsPuller setDelegate:self];
    }
    _investments = [[symbolParm componentsSeparatedByString:@"|"] mutableCopy];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"Avenir Next" size:20.0];
        titleView.textColor = [UIColor colorWithRed:0x8c/255.0 green:0x8c/255.0 blue:0x8c/255.0 alpha:1.0f];
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

-(void)fundamentalsPullerFundamentalsDidChange:(SPYahooGetFundamentals *)dp;
{
    [self reloadData];
}

#pragma mark accessors

-(SPYahooGetFundamentals *)fundamentalsPuller
{
    return fundamentalsPuller;
}

-(void)fundamentalsPullerDidFinishFetch:(SPYahooGetFundamentals *)dp
{ 
    NSLog(@"in -fundamentalsPuller, returned = %@", dp);
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults registerDefaults:@{@"investmentList": @"VOO|VB|VWO|VNQ|CORP|GOVT"}];
    
    NSString *listOfETFs;
    NSDictionary *fundamentalsDict;
    if ([dp.fundamentals count] > 0)
    {
        fundamentalsDict = dp.fundamentals[0];
        listOfETFs = [NSString stringWithFormat:@"%@ %@\nValue %@", [fundamentalsDict objectForKey:@"symbol"],
                                                             [fundamentalsDict objectForKey:@"nameOfETF"],
                                                             [fundamentalsDict objectForKey:@"currentValue"]];
    }
    
    for (NSUInteger i = 1; i < [dp.fundamentals count]; i++)
    {
        fundamentalsDict = dp.fundamentals[i];
        listOfETFs = [NSString stringWithFormat:@"%@|%@ %@\nValue %@", listOfETFs,
                                                             [fundamentalsDict objectForKey:@"symbol"],
                                                             [fundamentalsDict objectForKey:@"nameOfETF"],
                                                             [fundamentalsDict objectForKey:@"currentValue"]];
    }
    
    // Clean up string by removing "'s
    listOfETFs = [listOfETFs stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:listOfETFs forKey:@"investmentList"];
    
    [[NSUserDefaults standardUserDefaults] setObject:dp.fundamentals forKey:@"fundamentals"];
        
    [standardDefaults synchronize];
    
    //[self reloadData];
}

-(void)setfundamentalsPuller:(SPYahooGetFundamentals *)afundamentalsPuller
{
    if ( fundamentalsPuller != afundamentalsPuller ) {
        fundamentalsPuller = afundamentalsPuller;
    }
}

-(void)fundamentalsPuller:(SPYahooGetFundamentals *)dp downloadDidFailWithError:(NSError *)error
{
    NSLog(@"Download failure");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *selectionOfInterest;
    
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:selectedRowIndexPath];
    selectionOfInterest = selectedCell.textLabel.text;
    
    NSArray *arr = [selectionOfInterest componentsSeparatedByString:@" "];
    selectionOfInterest = arr[0];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:selectionOfInterest forKey:@"selectedETF"];
    [userDefault synchronize];
    
    // Use segue for parameter passing after beta testing.
}

@end
