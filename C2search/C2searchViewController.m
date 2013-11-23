//
//  C2searchViewController.m
//  C2search
//
//  Created by gam0022 on 2013/11/15.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "C2searchViewController.h"

@implementation C2searchViewController {
    UIColor *buttonTintDefault;
    UIColor *buttonTintSelected;
    NSString *recognizeLabelTextDefault;
    NSString *recogniziLabelTextSelected;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.queryText.delegate = self;
    
    CGRect rect = self.view.bounds;
    rect.origin.y = 180;
    rect.size.height = rect.size.width;
    
    /// カメラのpreview画面をsubviewに追加
    NSString *const url = @"http://demo.yipr.multimedia.yahooapis.jp/MultimediaService/V1/recognition";
    self.recognizeView = [[YIPRImageRecognizeView alloc] initWithFrame:rect url:url];
    self.recognizeView.delegate = self;
    self.recognizeView.applicationID = appidYahooYIPR;
    [self.view addSubview:self.recognizeView];
    
    self.capturing = NO;
    self.recognizeButton.enabled = NO;
    
    buttonTintDefault = self.recognizeButton.tintColor;
    buttonTintSelected = [UIColor grayColor];
    recognizeLabelTextDefault = @"Recognize";
    recogniziLabelTextSelected = @"Recognizing";
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
    if (self.recognizeView.recognizing) {
        [self.recognizeButton setTintColor:buttonTintSelected];
        [self.recognizeButton setTitle:recogniziLabelTextSelected forState:UIControlStateNormal];
    } else {
        [self.recognizeButton setTintColor:buttonTintDefault];
        [self.recognizeButton setTitle:recognizeLabelTextDefault forState:UIControlStateNormal];
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
            self.capturing = NO;
        }
    } else {
        NSLog(@"stop capturing");
        [self.recognizeView stopCapture];
    }
    self.recognizeView.hidden = !self.capturing;
}

///YIPRImageRecognizeDelegateの認識成功時のデリゲートメソッドの実装
- (void)yiprDidImageRecognition:(YIPRImageRecognizeView *)view didRecognitionResult:(NSMutableArray *)result
{
    NSLog(@"成功");
    
    if(result.count > 0) {
        for (YIPRRecognitionResult *obj in result) {
            NSLog(@"title: %@", obj.title);
        }
        YIPRRecognitionResult *obj = result[0];
        self.queryText.text = obj.title;
    } else {
        NSLog(@"結果なし");
    }
    [self.recognizeButton setTintColor:buttonTintDefault];
    [self.recognizeButton setTitle:recognizeLabelTextDefault forState:UIControlStateNormal];
}

///YIPRImageRecognizeDelegateの認識失敗時のデリゲートメソッドの実装
- (void)yiprFailedImageRecognition:(YIPRImageRecognizeView *)view error:(NSError *)error
{
    NSLog(@"%@", error);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"認識失敗"
                          message:@"画像の認識に失敗しました。"
                          delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
    [alert show];
    [self.recognizeButton setTintColor:buttonTintDefault];
    [self.recognizeButton setTitle:recognizeLabelTextDefault forState:UIControlStateNormal];
}

@end
