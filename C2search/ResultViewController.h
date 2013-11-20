//
//  ResultViewController.h
//  C2search
//
//  Created by gam0022 on 2013/11/15.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ResultViewController : UITableViewController {
    NSMutableArray *results;
    //NSDictionary *results;
}
@property (nonatomic) NSString *query;

+(NSMutableArray*)getYahooResult: (NSString *)query_escaped;

@end
