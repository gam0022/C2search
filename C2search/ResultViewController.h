//
//  ResultViewController.h
//  C2search
//
//  Created by gam0022 on 2013/11/15.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Const.h"
#import "Result.h"
#import "DetailViewController.h"
#import "ImageProcessing.h"

@interface ResultViewController : UITableViewController
@property (nonatomic) NSString *query;
- (IBAction)sort:(id)sender;

-(NSMutableArray*)getYahooResult;
-(NSMutableArray*)getRakutenResult;

@end