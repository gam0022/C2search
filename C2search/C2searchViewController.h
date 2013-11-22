//
//  C2searchViewController.h
//  C2search
//
//  Created by gam0022 on 2013/11/15.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultViewController.h"
#import <YIPRImageRecognizer/YIPRImageRecognizer.h>

@interface C2searchViewController : UIViewController <UITextFieldDelegate,YIPRImageRecognizeDelegate>

@property (weak, nonatomic) IBOutlet UITextField *queryText;
@property (nonatomic, strong) YIPRImageRecognizeView* recognizeView;
@property (weak, nonatomic) IBOutlet UIButton *recognizeButton;

@property (nonatomic) BOOL capturing;

- (IBAction)recognize:(id)sender;
- (IBAction)switch_capture:(id)sender;

@end
