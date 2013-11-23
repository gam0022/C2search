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

@property NSString *name;
@property NSString *description;
@property NSURL *itemURL;
@property NSInteger price;
@property NSURL *imageURL;
@property UIImage  *image;
@property NSString *shop;
@property HLSColor *hls;

-(id)initWithParams: (NSString*)name description:(NSString*)description price:(NSInteger)price URL:(NSString*)URL imageURL:(NSString*)imageURL shop:(NSString*)shop;
@end
