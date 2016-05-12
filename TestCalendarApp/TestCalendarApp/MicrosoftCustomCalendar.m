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
// Gregorian calendar
@property (nonatomic, strong) NSCalendar *gregorian;
@property (nonatomic, strong) NSArray * weekDayNames;
@property (nonatomic , strong) NSDate *currentDate;

@end
@implementation MicrosoftCustomCalendar

- (instancetype)init {

    if (self == [super init]) {
        [self initializeToDefaultVlues];
        [self createCalendar];
        return self;
    }
    return self;
}
-(void) initializeToDefaultVlues {
    _dayInfoUnits = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _currentDate = [NSDate date];
     NSArray * shortWeekdaySymbols = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    _weekDayNames  = @[shortWeekdaySymbols[1], shortWeekdaySymbols[2], shortWeekdaySymbols[3], shortWeekdaySymbols[4],shortWeekdaySymbols[5],shortWeekdaySymbols[6],shortWeekdaySymbols[0]];
    self.arrayOfDates = [[NSMutableArray alloc]init];
}

-(NSArray*) getArrayOfWeekdays {
    return _weekDayNames;
}

-(void) createCalendar {
  
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
    components.day = 1;
    
    NSDate *firstDayOfMonth = [_gregorian dateFromComponents:components];
    NSDateComponents *comps = [_gregorian components:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
    DatesModel *datesModel = [[DatesModel alloc]init];
    
    NSInteger weekdayBeginning = [comps weekday];  // Starts at 1 on Sunday
    weekdayBeginning -= 2;
    
    if(weekdayBeginning < 0)
        weekdayBeginning += 7;                          // Starts now at 0 on Monday
    
    NSRange days = [_gregorian rangeOfUnit:NSCalendarUnitDay
                                    inUnit:NSCalendarUnitMonth
                                   forDate:[NSDate date]];
    
    NSInteger monthLength = days.length;
    NSInteger remainingDays = (monthLength + weekdayBeginning) % 7;
    
    
    if(remainingDays == 0)
        return ;
    
    NSDateComponents *nextMonthComponents = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
    nextMonthComponents.month ++;
    
    // Previous month
    NSDateComponents *previousMonthComponents = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
    previousMonthComponents.month --;
    
    NSDate *previousMonthDate = [_gregorian dateFromComponents:previousMonthComponents];
    
    NSRange previousMonthDays = [_gregorian rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:previousMonthDate];
    
    NSInteger maxDate = previousMonthDays.length - weekdayBeginning;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    
    // get the previous months date and add it to an array
    for (int i=0; i<weekdayBeginning; i++) {
        
        previousMonthComponents.day = maxDate+i+1;
        
        NSDate *date = [_gregorian dateFromComponents:previousMonthComponents];
        NSString *dateInStringFormat = [dateFormatter stringFromDate:date];
        datesModel = [[DatesModel alloc]init];
        datesModel.dateInStringFormat =  dateInStringFormat;
        datesModel.date = date;
        datesModel.dayInStringFormat =  [NSString stringWithFormat:@"%ld",previousMonthComponents.day];
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
        datesModel.isHighlighted = YES;
        [self.arrayOfDates addObject:datesModel];
    }
    // get the Next months date and add it to an array
    
    for (NSInteger i=remainingDays; i<7; i++) {
        
        nextMonthComponents.day = (i+1)-remainingDays;
        NSDate *date = [_gregorian dateFromComponents:nextMonthComponents];
        NSString *dateInStringFormat = [dateFormatter stringFromDate:date];
        datesModel = [[DatesModel alloc]init];
        datesModel.dateInStringFormat =  dateInStringFormat;
        datesModel.dayInStringFormat =  [NSString stringWithFormat:@"%ld",nextMonthComponents.day];
        
        datesModel.date = date;
        [self.arrayOfDates addObject:datesModel];
    }
}

@end
