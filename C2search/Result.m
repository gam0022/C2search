//
//  Result.m
//  C2search
//
//  Created by gam0022 on 2013/11/20.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "Result.h"

@implementation Result

-(id)initWithParams: (NSString*)name shop:(NSString*)shop description:(NSString*)description price:(NSInteger)price URL:(NSString*)URL imageURL:(NSString*)imageURL rate:(CGFloat)rate
{
    self.name = name;
    self.shop = shop;
    self.description = description;
    self.price = price;
    self.itemURL = [NSURL URLWithString:URL];
    self.imageURL = [NSURL URLWithString:imageURL];
    self.rate = rate;
    self.hls = [[HLSColor alloc]initWithHue:360 lightness:0 saturation:0];// 非同期処理で上書きされるまでのダミー
    return self;
}

@end