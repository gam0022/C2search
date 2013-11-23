//
//  Result.m
//  C2search
//
//  Created by gam0022 on 2013/11/20.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "Result.h"

@implementation Result

-(id)initWithParams: (NSString*)name description:(NSString*)description price:(NSInteger)price URL:(NSString*)URL imageURL:(NSString*)imageURL shop:(NSString*)shop
{
    self.name = name;
    self.description = description;
    self.price = price;
    self.itemURL = [NSURL URLWithString:URL];
    self.imageURL = [NSURL URLWithString:imageURL];
    self.shop = shop;
    self.hls = [[HLSColor alloc]initWithHue:360 lightness:0 saturation:0];// 非同期処理で上書きされるまでのダミー
    return self;
}

@end