//
//  MicrosoftCustomCalendar.h
//  MicrosoftCalendarApp
//
//  Created by Pawan Agarwal on 12/05/16.
//  Copyright © 2016 Pawan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MicrosoftCustomCalendar : NSObject
@property (nonatomic, strong) NSMutableArray *arrayOfDates;
@property (nonatomic, assign) NSUInteger positionOfTodayDate;
-(NSArray*) getArrayOfWeekdays;
@end
