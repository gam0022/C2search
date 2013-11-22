//
//  C2searchViewController.m
//  C2search
//
//  Created by gam0022 on 2013/11/15.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "C2searchViewController.h"

@implementation C2searchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.queryText.delegate = self;
    
    CGRect rect = self.view.bounds;
    rect.origin.y = 200;
    rect.size.height -= 300;
    
    /// カメラのpreview画面をsubviewに追加
    NSString *const url = @"http://demo.yipr.multimedia.yahooapis.jp/MultimediaService/V1/recognition";
    self.recognizeView = [[YIPRImageRecognizeView alloc] initWithFrame:rect url:url];
    self.recognizeView.delegate = self;
    self.recognizeView.applicationID = appidYahooYIPR;
    [self.view addSubview:self.recognizeView];
    
    self.capturing = NO;
    self.recognizeButton.enabled = NO;
    //self.recognizeView.opaque
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (IBAction)search:(id)sender {
    [self performSegueWithIdentifier:@"showResult" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showResult"]) {
        //遷移先のViewControllerインスタンスを取得
        ResultViewController *rvc = segue.destinationViewController;
        NSString *query = self.queryText.text;
        rvc.query = query;
    }
}


- (IBAction)recognize:(id)sender {
    if (self.recognizeView.recognizing == YES) {
        NSLog(@"stop recognizing");
        [self.recognizeView stopRecognize];
    } else {
        NSLog(@"start recognizing");
        NSError* error = nil;
        [self.recognizeView startRecognize:&error];
        if (error) {
            NSLog(@"%@ ", error);
        }
    }
}

- (IBAction)switch_capture:(id)sender {
    UISwitch *capture_switch = sender;
    self.capturing = self.recognizeButton.enabled = capture_switch.on;
    
    if (self.capturing) {
        NSLog(@"start capturing");
        NSError* error = nil;
        [self.recognizeView startCapture:&error];
        if (error) {
            NSLog(@"%@", error);
        } else {
            self.capturing = YES;
        }
    } else {
        NSLog(@"stop capturing");
        self.capturing = NO;
        [self.recognizeView stopCapture];
    }
}

///YIPRImageRecognizeDelegateの認識成功時のデリゲートメソッドの実装
- (void)yiprDidImageRecognition:(YIPRImageRecognizeView *)view didRecognitionResult:(NSMutableArray *)result
{
    NSLog(@"成功");
    for (YIPRRecognitionResult* obj in result) {
        /*ModalViewController* mvc = [[ModalViewController alloc] init];
        
        // Modalで結果を表示(1つ目だけ)
        if (obj.clickURL) {
            NSLog(@"clickURL = %@", obj.clickURL);
            NSLog(@"title = %@", obj.title);
            [self presentViewController:mvc animated:YES completion:^(void) {
                [mvc.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:obj.clickURL]]];
            }];
            break;
        }*/
        _queryText.text = obj.title;
    }
}

///YIPRImageRecognizeDelegateの認識失敗時のデリゲートメソッドの実装
- (void)yiprFailedImageRecognition:(YIPRImageRecognizeView *)view error:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
