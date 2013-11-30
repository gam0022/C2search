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
    
    NSMutableArray *loadingAnimation;
    
    ImageProcessing *imageProcessing;
    
    BOOL isGettingYahooResults;
    BOOL isGettingRakutenResults;
    
    UIImage *yahooIcon;
    UIImage *rakutenIcon;
    NSDictionary *shopIconDictionary;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollsToTop = YES;
    
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
    
    // ショップのアイコンを設定
    yahooIcon = [UIImage imageNamed:@"yahoo.png"];
    rakutenIcon = [UIImage imageNamed:@"rakuten.png"];
    shopIconDictionary = @{@"Yahoo":yahooIcon, @"楽天": rakutenIcon};
    
    results = [NSMutableArray array];
    
    @try {
        isGettingYahooResults = NO;
        isGettingRakutenResults = NO;
        [self getResults];
    }
    @catch (NSException *exception) {
        NSLog(@"getResults()で例外発生");
    }
    
    loadingAnimation = [self getLoadingImageView];
    imageProcessing = [ImageProcessing alloc];
}

-(NSMutableArray*)getLoadingImageView
{
    NSMutableArray *animation = [NSMutableArray array];
    for(int i = 0; i < 12; ++i) {
        [animation addObject:[UIImage imageNamed:[NSString stringWithFormat:@"load-%d.png", i]]];
    }
    return animation;
}

-(void)getResults
{
    if (isGettingYahooResults || isGettingRakutenResults) {
        NSLog(@"2重読み込み");
        return;
    }
    
    // 非同期で検索を行う
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    dispatch_async(q_global, ^{
        isGettingYahooResults = YES;
        NSMutableArray *yahooResults = [self getYahooResult];
        // UI操作はメインスレッドで行う
        dispatch_async(q_main, ^{
            if(yahooResults.count > 0) {
                [self forceRestoreResults];
                [results addObjectsFromArray:yahooResults];
                [self.tableView reloadData];
            } else {
                NSLog(@"Yahoo商品検索で検索結果なし");
            }
            isGettingYahooResults = NO;
        });
    });
    dispatch_async(q_global, ^{
        isGettingRakutenResults = YES;
        NSMutableArray *rakutenResults = [self getRakutenResult];
        // UI操作はメインスレッドで行う
        dispatch_async(q_main, ^{
            if(rakutenResults.count > 0) {
                [self forceRestoreResults];
                [results addObjectsFromArray:rakutenResults];
                [self.tableView reloadData];
            } else {
                NSLog(@"楽天商品検索で検索結果なし");
            }
            isGettingRakutenResults = NO;
        });
    });
}

- (void)forceRestoreResults
{
    // 意味の分からないことに、results が途中で NSArray になることがあるよう
    if([results isMemberOfClass:[NSArray class]]) {
        NSLog(@"怪奇現象><");
        results = [results mutableCopy];
    }
}

-(IBAction)sort:(id)sender {
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
            results = [[results sortedArrayUsingComparator:^(Result *a, Result *b) {
                return a.price > b.price;
            }]mutableCopy];
            lastSortedIndex = buttonIndex;
            [self.tableView reloadData];
            break;
        case 1:
            // sort by color
            results = [[results sortedArrayUsingComparator:^(Result *a, Result *b) {
                return a.hls.hue > b.hls.hue;
            }]mutableCopy];
            lastSortedIndex = buttonIndex;
            [self.tableView reloadData];
            break;
        case 2:
            // sort by reviewRate
            results = [[results sortedArrayUsingComparator:^(Result *a, Result *b) {
                return a.reviewRate < b.reviewRate;
            }]mutableCopy];
            lastSortedIndex = buttonIndex;
            [self.tableView reloadData];
            break;
        case 3:
            // sort by reviewCount
            results = [[results sortedArrayUsingComparator:^(Result *a, Result *b) {
                return a.reviewCount < b.reviewCount;
            }]mutableCopy];
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
    NSMutableArray *yahooResults = [NSMutableArray array];
    
    if (yahooOffset >= yahooTotal) {
        return yahooResults;
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
            NSLog(@"Yahoo商品検索のJSONのパースでエラー発生");
            return yahooResults;
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
            [yahooResults addObject:result];
        }
        yahooOffset += totalResultsReturned;
        NSLog(@"Yahoo商品検索に成功: %d件", yahooResults.count);
        return yahooResults;
    }
    
    @catch (NSException *e) {
        NSLog(@"Yahoo商品検索で例外発生");
        return yahooResults;
    }
}

-(NSMutableArray*)getRakutenResult
{
    NSMutableArray *rakutenResults = [NSMutableArray array];
    
    if (rakutenOffsetPage >= rakutenTotalPage) {
        return rakutenResults;
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
            NSLog(@"楽天商品検索のJSONのパースでエラー発生");
            return rakutenResults;
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
            [rakutenResults addObject:result];
        }
        ++rakutenOffsetPage;
        NSLog(@"楽天の検索が成功: %d件", rakutenResults.count);
        return rakutenResults;
    }
    
    @catch (NSException *e) {
        NSLog(@"楽天商品検索で例外発生");
        return rakutenResults;
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
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d円 / %@ / %1.1f(%d件)",
                                 result.price, result.shop, result.reviewRate, result.reviewCount];
    if (result.image) {
        cell.imageView.image = result.image;
    } else {
        // 画像読み込み中のアニメーションを設定
        cell.imageView.animationImages = loadingAnimation;
        cell.imageView.animationDuration = 1;
        cell.imageView.animationRepeatCount = 0;
        [cell.imageView startAnimating];
        
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        dispatch_async(q_global, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: result.imageURL]];
            // 商品画像の平均色のHLSを計算する
            result.hls = [imageProcessing getHLSColorFromUIImage: image];
            result.image = [imageProcessing gouseiImage:image
                                                   composeImage:shopIconDictionary[result.shop]
                                                          width:128
                                                         height:128];
            // UI操作はメインスレッドで行う
            dispatch_async(q_main, ^{
                [cell.imageView stopAnimating];
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
    //NSLog(@"indexPath.row: %d", indexPath.row);
    //NSLog(@"results.count: %d", results.count);
    //NSLog(@"results.class: %@", results.class);
    if(indexPath.row >= results.count - 1)
    {
        @try {
            //まだ表示するコンテンツが存在するか判定し存在するなら取得して表示更新する
            [self getResults];
        }
        @catch (NSException *e) {
            NSLog(@"catched exception in scrollViewDidScroll()");
            NSLog(@"results: %@", results);
        }
    }
}

@end
