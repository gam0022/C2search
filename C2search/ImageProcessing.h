//
//  ImageProcessing.h
//  C2search
//
//  Created by gam0022 on 2013/11/23.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLSColor.h"

@interface ImageProcessing : NSObject
-(HLSColor*)getHLSColorFromUIImage: (UIImage*)image;
@end
