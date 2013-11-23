//
//  HLSColor.h
//  C2search
//
//  Created by gam0022 on 2013/11/23.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLSColor : NSObject

@property NSInteger hue;//        [0 360]
@property NSInteger lightness;//  [0 255]
@property NSInteger saturation;// [0 255]

-(id)initWithHue: (NSInteger)hue lightness:(NSInteger)lightness saturation:(NSInteger)saturation;

@end
