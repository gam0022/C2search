//
//  HLSColor.m
//  C2search
//
//  Created by gam0022 on 2013/11/23.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "HLSColor.h"

@implementation HLSColor

-(id)initWithHue: (NSInteger)hue lightness:(NSInteger)lightness saturation:(NSInteger)saturation
{
    self.hue = hue;
    self.lightness = lightness;
    self.saturation = saturation;
    return self;
}

@end
