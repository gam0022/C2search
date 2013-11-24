//
//  ResultViewController.m
//  C2search
//
//  Created by gam0022 on 2013/11/15.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "ResultViewController.h"

@implementation ResultViewController
{
    NSMutableArray *results;
    NSString *queryEscaped;
    
    NSInteger yahooOffset;
    NSInteger yahooTotal;
    
    NSInteger rakutenOffsetPage;
    NSInteger rakutenTotalPage;
    
    NSInteger lastSortedIndex;
    
    UIImage *imagePlaceholder;
    ImageProcessing *imageProcessing;
}

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
    yahooTotal = 1;
    
    rakutenOffsetPage = 1;
    rakutenTotalPage = 2;
    
    lastSortedIndex = -1;
    
    results = [NSMutableArray array];
    [results addObjectsFromArray:[self getYahooResult]];
    [results addObjectsFromArray:[self getRakutenResult]];
    
    imagePlaceholder = [UIImage imageNamed:@"gam0022_kanji.png"];
    imageProcessing = [ImageProcessing alloc];
}

- (IBAction)sort:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
    as.title = @"ソートの種類を選択してください。";
    [as addButtonWithTitle:@"価格"];
    [as addButtonWithTitle:@"色"];
    [as addButtonWithTitle:@"評価平均"];
    [as addButtonWithTitle:@"評価件数"];
    [as addButtonWithTitle:@"キャンセル"];
    as.cancelButtonIndex = 4;
    if (lastSortedIndex != -1) {
        as.destructiveButtonIndex = lastSortedIndex;
    }
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
            lastSortedIndex = buttonIndex;
            [self.tableView reloadData];
            break;
        case 1:
            // sort by color
            results = (NSMutableArray*)[results sortedArrayUsingComparator:^(Result *a, Result *b) {
                return a.hls.hue > b.hls.hue;
            }];
            lastSortedIndex = buttonIndex;
            [self.tableView reloadData];
            break;
        case 2:
            // sort by reviewRate
            results = (NSMutableArray*)[results sortedArrayUsingComparator:^(Result *a, Result *b) {
                return a.reviewRate < b.reviewRate;
            }];
            lastSortedIndex = buttonIndex;
            [self.tableView reloadData];
            break;
        case 3:
            // sort by reviewCount
            results = (NSMutableArray*)[results sortedArrayUsingComparator:^(Result *a, Result *b) {
                return a.reviewCount < b.reviewCount;
            }];
            lastSortedIndex = buttonIndex;
            [self.tableView reloadData];
            break;
            
        case 4:
            // cancel
            break;
    }
    
}

-(NSMutableArray*)getYahooResult
{
    if (yahooOffset >= yahooTotal) {
        return [NSMutableArray array];
    }
    
    @try {
        NSMutableArray *yahoo_results = [NSMutableArray array];
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
        yahooTotal = [resultSet[@"totalResultsAvailable"] integerValue];
        
        for(int i = 0; i < totalResultsReturned; ++i)
        {
            NSDictionary *obj = objs[[NSString stringWithFormat:@"%d", i]];
            Result *result = [[Result alloc] initWithParams:obj[@"Name"]
                                                       shop:@"Yahoo"
                                                description:obj[@"Description"]
                                                      price:[obj[@"Price"][@"_value"] integerValue]
                                                        URL:obj[@"Url"]
                                                   imageURL:obj[@"Image"][@"Small"]
                                                 reviewRate:[obj[@"Store"][@"Ratings"][@"Rate"] floatValue]
                                                reviewCount:[obj[@"Store"][@"Ratings"][@"Count"] integerValue]];
            [yahoo_results addObject:result];
        }
        yahooOffset += totalResultsReturned;
        return yahoo_results;
    }
    
    @catch (NSException *e) {
        NSLog(@"Yahoo商品検索で例外発生");
        return [NSMutableArray array];
    }
}

-(NSMutableArray*)getRakutenResult
{
    if (rakutenOffsetPage >= rakutenTotalPage) {
        return [NSMutableArray array];
    }
    
    @try {
        NSMutableArray *rakuten_results = [NSMutableArray array];
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
        rakutenTotalPage = [jsonObject[@"pageCount"] integerValue];
        
        for(int i = 0; i < hits; ++i)
        {
            NSDictionary *obj = objs[i][@"Item"];
            Result *result = [[Result alloc] initWithParams:obj[@"itemName"]
                                                       shop:@"楽天"
                                                description:obj[@"itemCaption"]
                                                      price:[obj[@"itemPrice"] integerValue]
                                                        URL:obj[@"itemUrl"]
                                                   imageURL:obj[@"smallImageUrls"][0][@"imageUrl"]
                                                 reviewRate:[obj[@"reviewAverage"] floatValue]
                                                reviewCount:[obj[@"reviewCount"] integerValue]];
            [rakuten_results addObject:result];
        }
        ++rakutenOffsetPage;
        return rakuten_results;
    }
    
    @catch (NSException *e) {
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
    return results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Result *result = results[indexPath.row];
    cell.textLabel.text = result.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d円 / %@ / %1.1f(%d件)",
                                 result.price, result.shop, result.reviewRate, result.reviewCount];
    if (result.image) {
        cell.imageView.image = result.image;
    } else {
        cell.imageView.image = imagePlaceholder;
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        dispatch_async(q_global, ^{
            result.image = [UIImage imageWithData:[NSData dataWithContentsOfURL: result.imageURL]];
            // 商品画像の平均色のHLSを計算する
            result.hls = [imageProcessing getHLSColorFromUIImage: result.image];
            // UI操作はメインスレッドで行う
            dispatch_async(q_main, ^{
                cell.imageView.image = result.image;
                [cell setNeedsLayout];
            });
        });
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Result *result = results[indexPath.row];
        NSURL *url = result.itemURL;
        
        DetailViewController *dvc = segue.destinationViewController;
        dvc.itemURL = url;
    }
}

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //一番下までスクロールしたかどうか
    if(!isAllItemLoaded && self.tableView.contentOffset.y > (self.tableView.contentSize.height - self.tableView.bounds.size.height + 50))
    {
        @try {
            //まだ表示するコンテンツが存在するか判定し存在するなら取得して表示更新する
            NSInteger pre_count = results.count;
            [results addObjectsFromArray:[self getYahooResult]];
            [results addObjectsFromArray:[self getRakutenResult]];
            if (results.count > pre_count) {
                [self.tableView reloadData];
            } else {
                isAllItemLoaded = YES;
            }
        }
        
        @catch (NSException *e) {
            NSLog(@"catched exception in scrollViewDidScroll()");
        }
    }
}*/

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    //一番下までスクロールしたかどうか
    NSLog(@"indexPath.row: %d", indexPath.row);
    NSLog(@"results.count: %d", results.count);
    if(indexPath.row >= results.count - 1)
    {
        @try {
            //まだ表示するコンテンツが存在するか判定し存在するなら取得して表示更新する
            NSInteger pre_count = results.count;
            [results addObjectsFromArray:[self getYahooResult]];
            if (results.count > pre_count) {
                [self.tableView reloadData];
            }
            pre_count = results.count;
            [results addObjectsFromArray:[self getRakutenResult]];
            if (results.count > pre_count) {
                [self.tableView reloadData];
            }
        }
        
        @catch (NSException *e) {
            NSLog(@"catched exception in scrollViewDidScroll()");
            NSLog(@"results: %@", results);
        }
    }
}

@end
