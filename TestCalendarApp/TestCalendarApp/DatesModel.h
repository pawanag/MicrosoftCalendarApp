//
//  DatesModel.h
//  MicrosoftCalendarApp
//
//  Created by Pawan Agarwal on 11/05/16.
//  Copyright © 2016 Pawan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatesModel : NSObject

@property (nonatomic, strong) NSString * dateInStringFormat;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * dayInStringFormat;
@property (nonatomic, assign) BOOL isHighlighted;
@end
