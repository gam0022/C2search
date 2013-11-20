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
    NSString *appid = @"dj0zaiZpPXJJR1hWVUZXeTY5biZzPWNvbnN1bWVyc2VjcmV0Jng9NGQ-";
    NSString *yahoo_url = [NSString stringWithFormat:@"http://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch?appid=%@&query=%@",appid, query_escaped];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:yahoo_url]];
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:nil
                                                          error:nil];
    NSError *error=nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:json_data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSDictionary *resultSet = [jsonObject objectForKey:@"ResultSet"];
    NSDictionary *result = [[resultSet objectForKey:@"0"] objectForKey:@"Result"];
    int totalResultsReturned = [[resultSet objectForKey:@"totalResultsReturned"] intValue];
    
    NSMutableArray *yahoo_results = [NSMutableArray array];
    
    for(int i = 0; i < totalResultsReturned; ++i)
    {
        [yahoo_results addObject:[result objectForKey:[NSString stringWithFormat:@"%d", i]]];
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
    NSDictionary *result = [results objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"Name"]];
    cell.detailTextLabel.text = [result objectForKey:@"Description"];
    
    NSURL *img_url = [NSURL URLWithString:[[result objectForKey:@"Image"] objectForKey:@"Small"]];
    NSData *data = [NSData dataWithContentsOfURL:img_url];
    cell.imageView.image = [[UIImage alloc] initWithData:data];
    return cell;
}

@end
