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
    _name = name;
    _description = description;
    _price = price;
    _itemURL = [NSURL URLWithString:URL];
    _imageURL = [NSURL URLWithString:imageURL];
    NSData *data = [NSData dataWithContentsOfURL:_imageURL];
    _image = [[UIImage alloc] initWithData:data];
    _shop = shop;
    return self;
}

@end