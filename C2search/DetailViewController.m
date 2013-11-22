//
//  DetailViewController.m
//  C2search
//
//  Created by gam0022 on 2013/11/22.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

- (void)viewDidLoad
{
    if (self.detailItem) {
        self.myWebView.scalesPageToFit = YES;
        NSURL *url = self.detailItem;
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [self.myWebView loadRequest:req];
    }
}

@end
