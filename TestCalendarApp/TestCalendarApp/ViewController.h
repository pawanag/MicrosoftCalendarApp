//
//  ViewController.h
//  MicrosoftCalendarApp
//
//  Created by Pawan Agarwal on 10/05/16.
//  Copyright © 2016 Pawan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController : UIViewController


@end

