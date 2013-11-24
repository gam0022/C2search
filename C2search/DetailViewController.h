//
//  DetailViewController.h
//  C2search
//
//  Created by gam0022 on 2013/11/22.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSURL *itemURL;
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

@end
