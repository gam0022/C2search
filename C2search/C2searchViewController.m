//
//  C2searchViewController.m
//  C2search
//
//  Created by gam0022 on 2013/11/15.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "C2searchViewController.h"
#import "ResultViewController.h"

@interface C2searchViewController ()

@end

@implementation C2searchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.queryText.delegate = self;
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
    [self performSegueWithIdentifier:@"ResultSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ResultSegue"]) {
        //遷移先のViewControllerインスタンスを取得
        ResultViewController *rvc = segue.destinationViewController;
        NSString *query = self.queryText.text;
        rvc.query = query;
    }
}


@end
