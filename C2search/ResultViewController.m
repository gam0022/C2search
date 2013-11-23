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
    
    queryEscaped = (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (CFStringRef)_query,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8));
    yahooOffset = 0;
    yahooTotalResultsAvailable = -1;
    
    rakutenOffsetPage = 1;
    rakutenAvailablePage = 100;
    
    results = [NSMutableArray array];
    [results addObjectsFromArray:[self getYahooResult]];
    [results addObjectsFromArray:[self getRakutenResult]];
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

-(NSMutableArray*)getYahooResult
{
    if (yahooTotalResultsAvailable != -1 && yahooOffset >= yahooTotalResultsAvailable) {
        return [NSMutableArray array];
    }
    
    @try {
        NSString *url = [NSString stringWithFormat:@"http://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch?appid=%@&query=%@&hits=10&offset=%d", appidYahoo, queryEscaped, yahooOffset];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *json_data = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:nil
                                                              error:nil];
        NSError *error=nil;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:json_data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&error];
        if (error != nil) {
            @throw @"error";
        }
        
        NSDictionary *resultSet = jsonObject[@"ResultSet"];
        NSDictionary *objs = resultSet[@"0"][@"Result"];
        NSInteger totalResultsReturned = [resultSet[@"totalResultsReturned"] integerValue];
        yahooTotalResultsAvailable = [resultSet[@"totalResultsAvailable"] integerValue];
        NSMutableArray *yahoo_results = [NSMutableArray array];
        
        for(int i = 0; i < totalResultsReturned; ++i)
        {
            NSDictionary *obj = objs[[NSString stringWithFormat:@"%d", i]];
            Result *result = [[Result alloc] initWithParams:obj[@"Name"]
                                                description:obj[@"Description"]
                                                      price:[obj[@"Price"][@"_value"] integerValue]
                                                        URL:obj[@"Url"]
                                                   imageURL:obj[@"Image"][@"Small"]
                                                       shop:@"Yahoo"];
            [yahoo_results addObject:result];
        }
        yahooOffset += totalResultsReturned;
        return yahoo_results;
    }
    
    @catch (id obj) {
        NSLog(@"Yahoo商品検索で例外発生");
        return [NSMutableArray array];
    }
}

-(NSMutableArray*)getRakutenResult
{
    if (rakutenOffsetPage >= rakutenAvailablePage) {
        return [NSMutableArray array];
    }
    
    @try {
        NSString *url = [NSString stringWithFormat:@"https://app.rakuten.co.jp/services/api/IchibaItem/Search/20130805?format=json&keyword=%@&applicationId=%@&hits=10&page=%d", queryEscaped, appidRakuten, rakutenOffsetPage];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *json_data = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:nil
                                                              error:nil];
        NSError *error=nil;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:json_data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&error];
        if (error != nil) {
            @throw @"error";
        }
        
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
                                                   imageURL:obj[@"smallImageUrls"][0][@"imageUrl"]
                                                       shop:@"楽天"];
            [rakuten_results addObject:result];
        }
        ++rakutenOffsetPage;
        return rakuten_results;
    }
    
    @catch (id obj) {
        NSLog(@"楽天商品検索で例外発生");
        return [NSMutableArray array];
    }
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d円 / %@", result.price, result.shop];
    cell.imageView.image = result.image;
    return cell;
}

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //一番下までスクロールしたかどうか
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    {
        @try {
            //まだ表示するコンテンツが存在するか判定し存在するなら○件分を取得して表示更新する
            [results addObjectsFromArray:[self getYahooResult]];
            [results addObjectsFromArray:[self getRakutenResult]];
            [self.tableView reloadData];
        }
        
        @catch (id obj) {
            NSLog(@"catched exception in scrollViewDidScroll()");
        }
    }
}

@end
