//
//  MicrosoftCustomCalendar.m
//  MicrosoftCalendarApp
//
//  Created by Pawan Agarwal on 12/05/16.
//  Copyright © 2016 Pawan Agarwal. All rights reserved.
//

#import "MicrosoftCustomCalendar.h"
#import "DatesModel.h"

@interface MicrosoftCustomCalendar()

@property (nonatomic, strong) NSDate * firstOfCurrentMonth;
@property (nonatomic, strong) NSCalendar * calendar;
@property (nonatomic, assign) NSCalendarUnit dayInfoUnits;
@property (nonatomic, strong) NSCalendar *gregorian;
@property (nonatomic, strong) NSArray * weekDayNames;
@property (nonatomic , strong) NSDate *currentDate;
@property (nonatomic, assign) NSRange days;
@property (nonatomic, strong) NSDateComponents *nextMonthComponents;
@property (nonatomic, strong) NSDateComponents *previousMonthComponents;
@end

@implementation MicrosoftCustomCalendar

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeToDefaultVlues];
        [self createCalendar];
        return self;
    }
    return self;
}

/*!
 * @discussion init to default values
 */

-(void) initializeToDefaultVlues {
    
    _dayInfoUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _currentDate = [NSDate date];
    NSArray * shortWeekdaySymbols = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    _weekDayNames  = @[shortWeekdaySymbols[1], shortWeekdaySymbols[2], shortWeekdaySymbols[3], shortWeekdaySymbols[4],shortWeekdaySymbols[5],shortWeekdaySymbols[6],shortWeekdaySymbols[0]];
    self.arrayOfDates = [[NSMutableArray alloc]init];
    _days = [_gregorian rangeOfUnit:NSCalendarUnitDay
                             inUnit:NSCalendarUnitMonth
                            forDate:[NSDate date]];
    _nextMonthComponents = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
    _previousMonthComponents = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
    
}
/*!
 * @discussion A method which array of weekdays.
 * @return The array of weekdays.
 */

-(NSArray*) getArrayOfWeekdays {
    
    return _weekDayNames;
}

-(void) createCalendar {
    
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
    components.day = 1;
    
    NSDate *firstDayOfMonth = [_gregorian dateFromComponents:components];
    NSDateComponents *dateComponent = [_gregorian components:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
    DatesModel *datesModel = [[DatesModel alloc]init];
    
    NSInteger weekdayBeginning = [dateComponent weekday];
    weekdayBeginning -= 2;
    // Find the beginning of the weekday
    if(weekdayBeginning < 0) weekdayBeginning += 7;
    
    NSInteger monthLength = _days.length;
    NSInteger remainingDays = (monthLength + weekdayBeginning) % 7;
    
    if(remainingDays == 0)
        return ;
    
    _nextMonthComponents.month ++;
    // Previous month
    _previousMonthComponents.month --;
    NSDate *previousMonthDate = [_gregorian dateFromComponents:_previousMonthComponents];
    NSRange previousMonthDays = [_gregorian rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:previousMonthDate];
    NSInteger maxDate = previousMonthDays.length - weekdayBeginning;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    // get the previous months date and add it to an array
    
    for (int i=0; i<weekdayBeginning; i++) {
        _previousMonthComponents.day = maxDate+i+1;
        NSDate *date = [_gregorian dateFromComponents:_previousMonthComponents];
        NSString *dateInStringFormat = [dateFormatter stringFromDate:date];
        datesModel = [[DatesModel alloc]init];
        datesModel.dateInStringFormat =  dateInStringFormat;
        datesModel.date = date;
        datesModel.dayInStringFormat =  [NSString stringWithFormat:@"%ld",_previousMonthComponents.day];
        [self.arrayOfDates addObject:datesModel];
    }
    
    NSDateComponents *componentsToBeCompared = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSUInteger componentsToBeComparedDay = [componentsToBeCompared day];
    NSUInteger componentsToBeComparedMonth = [componentsToBeCompared month];
    // get the Current months date and add it to an array
    
    for (NSInteger i= 0; i<monthLength; i++) {
        components.day = i+1;
        NSDate *date = [_gregorian dateFromComponents:components];
        NSString *dateInStringFormat = [dateFormatter stringFromDate:date];
        datesModel = [[DatesModel alloc]init];
        datesModel.dateInStringFormat =  dateInStringFormat;
        datesModel.dayInStringFormat =  [NSString stringWithFormat:@"%ld",components.day];
        datesModel.date = date;
        // find the position of current date in the Array
        if (componentsToBeComparedDay == [components day] && componentsToBeComparedMonth == [components month]) {
            self.positionOfTodayDate = [_arrayOfDates count];
        }
        // setting the isHighlighted Bool for the dates Model so as to display which cell to be highlighted in collection view
        datesModel.isHighlighted = YES;
        [self.arrayOfDates addObject:datesModel];
    }
    
    // get the Next months date and add it to an array
    for (NSInteger i=remainingDays; i<7; i++) {
        
        _nextMonthComponents.day = (i+1)-remainingDays;
        NSDate *date = [_gregorian dateFromComponents:_nextMonthComponents];
        NSString *dateInStringFormat = [dateFormatter stringFromDate:date];
        datesModel = [[DatesModel alloc]init];
        datesModel.dateInStringFormat =  dateInStringFormat;
        datesModel.dayInStringFormat =  [NSString stringWithFormat:@"%ld",_nextMonthComponents.day];
        datesModel.date = date;
        [self.arrayOfDates addObject:datesModel];
    }
}

@end
