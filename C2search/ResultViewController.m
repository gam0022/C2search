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
    
    NSString *query_escaped = (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (CFStringRef)_query,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8));
    
    results = [NSMutableArray array];
    [results addObjectsFromArray:[ResultViewController getYahooResult:query_escaped]];
    [results addObjectsFromArray:[ResultViewController getRakutenResult:query_escaped]];
}

- (IBAction)sort:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
    as.title = @"ソートの種類を選択してください。";
    [as addButtonWithTitle:@"価格"];
    [as addButtonWithTitle:@"色"];
    [as addButtonWithTitle:@"キャンセル"];
    as.cancelButtonIndex = 2;
    //as.destructiveButtonIndex = 0;
    [as showInView:self.view];
}

-(void)actionSheet:(UIActionSheet*)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            // sort by price
            results = (NSMutableArray*)[results sortedArrayUsingComparator:^(Result *a, Result *b) {
                return a.price > b.price;
            }];
            [self.tableView reloadData];
            break;
        case 1:
            // sort by color
            NSLog(@"ボタン2");
            break;
        case 2:
            // cancel
            NSLog(@"ボタン3");
            break;
    }
    
}

+(NSMutableArray*)getYahooResult: (NSString *)query_escaped
{
    NSString *url = [NSString stringWithFormat:@"http://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch?appid=%@&query=%@", appidYahoo, query_escaped];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:nil
                                                          error:nil];
    NSError *error=nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:json_data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSDictionary *resultSet = jsonObject[@"ResultSet"];
    NSDictionary *objs = resultSet[@"0"][@"Result"];
    NSInteger totalResultsReturned = [resultSet[@"totalResultsReturned"] integerValue];
    
    NSMutableArray *yahoo_results = [NSMutableArray array];
    
    for(int i = 0; i < totalResultsReturned; ++i)
    {
        NSDictionary *obj = objs[[NSString stringWithFormat:@"%d", i]];
        Result *result = [[Result alloc] initWithParams:obj[@"Name"]
                                            description:obj[@"Description"]
                                                  price:[obj[@"Price"][@"_value"] integerValue]
                                                    URL:obj[@"Url"]
                                               imageURL:obj[@"Image"][@"Small"]];
        [yahoo_results addObject:result];
    }
    return yahoo_results;
}

+(NSMutableArray*)getRakutenResult: (NSString *)query_escaped
{
    NSString *url = [NSString stringWithFormat:@"https://app.rakuten.co.jp/services/api/IchibaItem/Search/20130805?format=json&keyword=%@&applicationId=%@", query_escaped, appidRakuten];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:nil
                                                          error:nil];
    NSError *error=nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:json_data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSArray *objs = jsonObject[@"Items"];
    NSInteger hits = [jsonObject[@"hits"] integerValue];
    
    NSMutableArray *rakuten_results = [NSMutableArray array];
    
    for(int i = 0; i < hits; ++i)
    {
        NSDictionary *obj = objs[i][@"Item"];
        Result *result = [[Result alloc] initWithParams:obj[@"itemName"]
                                            description:obj[@"itemCaption"]
                                                  price:[obj[@"itemPrice"] integerValue]
                                                    URL:obj[@"itemUrl"]
                                               imageURL:obj[@"smallImageUrls"][0][@"imageUrl"]];
        [rakuten_results addObject:result];
    }
    return rakuten_results;
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
    Result *result = results[indexPath.row];
    cell.textLabel.text = result.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d円", result.price];//result.description;
    cell.imageView.image = result.image;
    return cell;
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Result *result = results[indexPath.row];
        NSURL *url = result.itemURL;
        
        DetailViewController *dvc = segue.destinationViewController;
        dvc.detailItem = url;
    }
}

@end
