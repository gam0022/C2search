//
//  ResultViewController.m
//  C2search
//
//  Created by gam0022 on 2013/11/15.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "ResultViewController.h"

@implementation ResultViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *query_escaped = [_query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    results = [NSMutableArray array];
    [results addObjectsFromArray:[ResultViewController getYahooResult:query_escaped]];
}

+(NSMutableArray*)getYahooResult: (NSString *)query_escaped
{
    NSString *yahoo_url = [NSString stringWithFormat:@"http://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch?appid=%@&query=%@", appidYahoo, query_escaped];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:yahoo_url]];
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:nil
                                                          error:nil];
    NSError *error=nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:json_data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSDictionary *resultSet = jsonObject[@"ResultSet"];
    NSDictionary *result = resultSet[@"0"][@"Result"];
    int totalResultsReturned = [resultSet[@"totalResultsReturned"] intValue];
    
    NSMutableArray *yahoo_results = [NSMutableArray array];
    
    for(int i = 0; i < totalResultsReturned; ++i)
    {
        [yahoo_results addObject: result[[NSString stringWithFormat:@"%d", i]] ];
    }
    
    //NSLog(@"yahoo_results = %@", yahoo_results);
    return yahoo_results;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *result = results[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",result[@"Name"]];
    cell.detailTextLabel.text = result[@"Description"];
    
    NSURL *img_url = [NSURL URLWithString:result[@"Image"][@"Small"]];
    NSData *data = [NSData dataWithContentsOfURL:img_url];
    cell.imageView.image = [[UIImage alloc] initWithData:data];
    return cell;
}

@end
