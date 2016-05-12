//
//  ViewController.m
//  MicrosoftCalendarApp
//
//  Created by Pawan Agarwal on 10/05/16.
//  Copyright © 2016 Pawan Agarwal. All rights reserved.
//

#import "ViewController.h"
#import "DatesModel.h"
#import "DateDisplayCollectionCell.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "MicrosoftCustomCalendar.h"

NSString * const EventsCellIdentifier = @"eventsCell";
NSString * const EventViewControllerIdentifier = @"eventViewController";
NSString * const HeaderCellIdentifier = @"HeaderCell";
NSString * const NoEventsText = @"No Events";

#define ConstWidthOfCollectionViewCellRatio 7
#define ConstHeightOfCollectionViewCell 50
#define ConstZeroValue 0
#define ConstValueOne 1
#define ConstForColorValue .827
#define ConstForHeaderHeight 30

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource,EKEventEditViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewForEvents;
@property (weak, nonatomic) IBOutlet UICollectionView *dateCollectionView;
@property (weak, nonatomic) IBOutlet UIView *weekdaysContainerView;
@property (nonatomic, strong) NSArray *arrayOfDates;
@property (nonatomic, strong) NSArray *arrayOfEvents;
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) NSArray * weekDayNames;
@property (nonatomic , strong) NSDate *currentDate;
// Default calendar associated with the above event store
@property (nonatomic, strong) EKCalendar *defaultCalendar;
@property (nonatomic, strong) NSIndexPath *indexPathToBeScrolledForTableView;
@property (nonatomic, strong) NSIndexPath *indexPathToBeScrolledForCollectionView;

@property (nonatomic, assign) NSUInteger rowToBeScrolled;
// Array of all events happening within the next 24 hours
@property (nonatomic, strong) NSMutableArray *eventsList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, assign) BOOL isAccessGrantedForCalendar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MicrosoftCustomCalendar *calendar = [[MicrosoftCustomCalendar alloc]init];
    // initialize array of Dates and weekdays
    _currentDate = [NSDate date];
    _arrayOfDates = calendar.arrayOfDates;
    _weekDayNames = [calendar getArrayOfWeekdays];
    _rowToBeScrolled = calendar.positionOfTodayDate;
    
    self.eventStore = [[EKEventStore alloc] init];
    self.eventsList = [[NSMutableArray alloc] initWithCapacity:ConstZeroValue];
    [self requestCalendarAccess];
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    self.navigationController.toolbarHidden = YES;
}

#pragma mark Data Source Methods

// Displaying a collection view that contains dates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // return the count of dates array
    return [_arrayOfDates count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // creating a cell with dequeueReusableCellWithReuseIdentifier
    
    DateDisplayCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(DateDisplayCollectionCell.class) forIndexPath:indexPath];
    DatesModel *datesModel = [_arrayOfDates objectAtIndex:indexPath.row];
    
    // checking if the cell should be highlighted or not
    if (datesModel.isHighlighted) {
        cell.dateLabel.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.dateLabel.backgroundColor =[UIColor colorWithRed:ConstForColorValue green:ConstForColorValue blue:ConstForColorValue alpha:ConstValueOne];
    }
    cell.dateLabel.text = datesModel.dayInStringFormat;
    return cell;
}

// Displaying a Table view that contains dates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [_arrayOfDates count];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = collectionView.bounds.size.width;
    CGFloat widthToBeReturned = width/ConstWidthOfCollectionViewCellRatio;
    return (CGSize){widthToBeReturned, ConstHeightOfCollectionViewCell};
    
}

// Customizing the Header for the TableView

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
    DatesModel *datesModel = [_arrayOfDates objectAtIndex:section];
    cell.textLabel.text = datesModel.dateInStringFormat;
    return cell;
}

// height for the Header of the TableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ConstForHeaderHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isAccessGrantedForCalendar) {
        DatesModel *datesModel = [_arrayOfDates objectAtIndex:section];
        self.eventsList = [self fetchEventsWithdate:datesModel.date];
        if ([self.eventsList count]) {
            return [self.eventsList count];
        } else {
            return ConstValueOne;
        }
    }
    return ConstValueOne;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventsCellIdentifier];
    
    DatesModel *datesModel = [_arrayOfDates objectAtIndex:indexPath.section];
    if (_isAccessGrantedForCalendar) {
        self.eventsList = [self fetchEventsWithdate:datesModel.date];
        if ([self.eventsList count]) {
            cell.textLabel.text = [(self.eventsList)[indexPath.row] title];
            cell.textLabel.textColor = [UIColor blueColor];
        } else {
            // displaying the NoEvents Cell  with Text Color as LightGray
            cell.textLabel.text = NoEventsText;
            cell.textLabel.textColor = [UIColor darkGrayColor];
        }
    } else {
        cell.textLabel.text = NoEventsText;
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    return cell;
}

#pragma mark Delegate Methods

// delegate method for selecting the collection view cell

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _indexPathToBeScrolledForTableView = [NSIndexPath indexPathForRow:ConstZeroValue inSection:indexPath.row];
    [_tableViewForEvents scrollToRowAtIndexPath:_indexPathToBeScrolledForTableView atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DatesModel *datesModel = [_arrayOfDates objectAtIndex:indexPath.section];
    self.eventsList = [self fetchEventsWithdate:datesModel.date];
    
    if ([self.eventsList count]) {
        [self performSegueWithIdentifier:EventViewControllerIdentifier sender:self];
        
    } else {
        EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
        
        // Set addController's event store to the current event store
        EKEventStore *eventStoreToBeEdited = self.eventStore;
        EKEvent *event  = [EKEvent eventWithEventStore:eventStoreToBeEdited];
        // setting the start date based on the cell which was clicked
        event.startDate = datesModel.date;
        event.endDate = datesModel.date;
        addController.eventStore = eventStoreToBeEdited;
        addController.event = event;
        addController.editViewDelegate = self;
        // Modally Present the View Controller
        [self presentViewController:addController animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*!
 * @discussion delegate method for EKEventEditViewDelegate protocol.
 * @param controller Object
 * @param Edit action
 */
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    
    ViewController * __weak weakSelf = self;
    // Dismiss the modal presented view controller
    [self dismissViewControllerAnimated:YES completion:^{
        if (action != EKEventEditViewActionCanceled) {
            // get the main queue as we wish to update the UI
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI with the above events
                [weakSelf.tableViewForEvents reloadData];
            });
        }
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:EventViewControllerIdentifier]) {
        // Configure the destination event view controller
        EKEventViewController* eventViewController = (EKEventViewController *)segue.destinationViewController;
        // Fetch the index path associated with the selected event
        NSIndexPath *indexPath = (self.tableViewForEvents).indexPathForSelectedRow;
        // Set the view controller to display the selected event
        DatesModel *datesModel = [_arrayOfDates objectAtIndex:indexPath.section];
        self.eventsList = [self fetchEventsWithdate:datesModel.date];
        
        eventViewController.event = (self.eventsList)[indexPath.row];
        
        // Allow event editing
        eventViewController.allowsEditing = YES;
    }
}

#pragma mark UserPermission

/*!
 * @discussion A method to Ask user to grant access to the calendar.
 */
-(void)requestCalendarAccess {
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted) {
             _isAccessGrantedForCalendar = YES;
             dispatch_async(dispatch_get_main_queue(), ^{
                 // get main queue as the user has granted the access and we need to reload the data
                 
                 self.defaultCalendar = self.eventStore.defaultCalendarForNewEvents;
                 [_tableViewForEvents reloadData];
                 _indexPathToBeScrolledForTableView = [NSIndexPath indexPathForRow:ConstZeroValue inSection:_rowToBeScrolled];
                 _indexPathToBeScrolledForCollectionView = [NSIndexPath indexPathForRow:_rowToBeScrolled inSection:ConstZeroValue];
                 [_tableViewForEvents scrollToRowAtIndexPath:_indexPathToBeScrolledForTableView atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                 [_dateCollectionView scrollToItemAtIndexPath:_indexPathToBeScrolledForCollectionView atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                 
             });
             
         }
     }];
}


#pragma mark Fetch events

/*!
 * @discussion A method to return the Array of dates.
 * @param date object for which events are calculated
 * @return An array of fetched Dates.
 */

- (NSMutableArray *)fetchEventsWithdate : (NSDate*) date {
    
    //Create the end date components
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = ConstValueOne;
    
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:date
                                                                   options:ConstZeroValue];
    // Create the predicate for seraching default calendar
    NSPredicate *predicate;
    if (self.defaultCalendar) {
        NSArray *calendarArray = @[self.defaultCalendar];
        predicate  = [self.eventStore predicateForEventsWithStartDate:date
                                                              endDate:endDate
                                                            calendars:calendarArray];
    }
    // Fetch all events that match the predicate
    NSMutableArray *events ;
    if (predicate) {
        events = [NSMutableArray arrayWithArray:[self.eventStore eventsMatchingPredicate:predicate]];
    }
    
    self.eventsList = events;
    return events;
}

#pragma mark ADD event

/*!
 * @discussion Button Click Action to add a event and Present the EditViewController Screen.
 * @param object of type id
 */
- (IBAction)addEvent:(id)sender {
    // Create an instance of EKEventEditViewController
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    
    // Set addController's event store to the current event store
    addController.eventStore = self.eventStore;
    addController.editViewDelegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}

@end
