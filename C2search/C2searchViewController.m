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
    CGRect rect = self.view.bounds;
    rect.origin.y = 180;
    rect.size.height = rect.size.width;
    
    /// カメラのpreview画面をsubviewに追加
    NSString *const url = @"http://demo.yipr.multimedia.yahooapis.jp/MultimediaService/V1/recognition";
    self.recognizeView = [[YIPRImageRecognizeView alloc] initWithFrame:rect url:url];
    self.recognizeView.delegate = self;
    self.recognizeView.applicationID = appidYahooYIPR;
    
    // recognizeView をタップしたら、背景をタップしたことにする
    self.recognizeButton.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.recognizeView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.recognizeView];
    self.recognizeButton.enabled = NO;
    
    NSMutableArray *loadingAnimation = [self getLoadingImageView];
    self.recognizingProgress.animationImages = loadingAnimation;
    self.recognizingProgress.animationDuration = 1;
    self.recognizingProgress.animationRepeatCount = 0;
    [self.view bringSubviewToFront:self.recognizingProgress];
    //CGPoint center = self.recognizingProgress.center;
    //center.y = 180 + self.recognizeView.bounds.size.height / 2;
    //self.recognizingProgress.center = center;
    //[self.recognizingProgress setNeedsDisplay];
    self.recognizingProgress.hidden = YES;
    
    buttonTintDefault = self.recognizeButton.tintColor;
    buttonTintSelected = [UIColor grayColor];
    recognizeLabelTextDefault = @"画像認識";
    recogniziLabelTextSelected = @"認識中...";
    
    self.captureSwitch.on = YES;
    [self switch_capture:self.captureSwitch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray*)getLoadingImageView
{
    NSMutableArray *animation = [NSMutableArray array];
    for(int i = 0; i < 12; ++i) {
        [animation addObject:[UIImage imageNamed:[NSString stringWithFormat:@"load-%d.png", i]]];
    }
    return animation;
}


- (IBAction)queryDidEndOnExit:(id)sender {
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"showResult" sender:self];
}

- (void)setRecognizeButtonDefault
{
    [self.recognizeButton setTintColor:buttonTintDefault];
    [self.recognizeButton setTitle:recognizeLabelTextDefault forState:UIControlStateNormal];
    self.recognizingProgress.hidden = YES;
    [self.recognizingProgress stopAnimating];
}

- (void)setRecognizeButtonSelected
{
    [self.recognizeButton setTintColor:buttonTintSelected];
    [self.recognizeButton setTitle:recogniziLabelTextSelected forState:UIControlStateNormal];
    self.recognizingProgress.hidden = NO;
    [self.recognizingProgress startAnimating];
}

- (IBAction)search:(id)sender {
    /*
    // 画像認識を停止する
    self.captureSwitch.on = NO;
    [self.recognizeView stopCapture];
    self.recognizeView.hidden = YES;
    [self setRecognizeButtonDefault];
    self.recognizeButton.enabled = NO;
     */
    
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
        [self setRecognizeButtonSelected];
    } else {
        [self setRecognizeButtonDefault];
    }
}

- (IBAction)switch_capture:(id)sender {
    self.recognizeButton.enabled = self.captureSwitch.on;
    
    if (self.captureSwitch.on) {
        NSLog(@"start capturing");
        NSError* error = nil;
        [self.recognizeView startCapture:&error];
        if (error) {
            NSLog(@"%@", error);
            self.captureSwitch.on = NO;
        }
    } else {
        NSLog(@"stop capturing");
        [self.recognizeView stopCapture];
        [self setRecognizeButtonDefault];
    }
    self.recognizeView.hidden = !self.captureSwitch.on;
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
        [self performSegueWithIdentifier:@"showResult" sender:self];
    } else {
        NSLog(@"結果なし");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"結果なし"
                              message:@"検索結果はありませんでした。"
                              delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    [self setRecognizeButtonDefault];
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
    [self setRecognizeButtonDefault];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

@end
