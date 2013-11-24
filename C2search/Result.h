//
//  Result.h
//  C2search
//
//  Created by gam0022 on 2013/11/20.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLSColor.h"

@interface Result : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shop;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSURL *itemURL;
@property (nonatomic) NSInteger price;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage  *image;
@property (nonatomic) CGFloat reviewRate;// [0 5]
@property (nonatomic) NSInteger reviewCount;
@property (nonatomic, strong) HLSColor *hls;

-(id)initWithParams: (NSString*)name shop:(NSString*)shop description:(NSString*)description price:(NSInteger)price URL:(NSString*)URL imageURL:(NSString*)imageURL reviewRate:(CGFloat)reviewRate reviewCount:(NSInteger)reviewCount;
@end
