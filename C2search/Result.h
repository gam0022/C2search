//
//  Result.h
//  C2search
//
//  Created by gam0022 on 2013/11/20.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Result : NSObject

@property NSString *name;
@property NSString *description;
@property NSURL *itemURL;
@property NSInteger price;
@property NSURL *imageURL;
@property UIImage  *image;

-(id)initWithParams: (NSString*)name description:(NSString*)description price:(NSInteger)price URL:(NSString*)URL imageURL:(NSString*)imageURL;
@end
