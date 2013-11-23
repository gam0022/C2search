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
    NSData *data = [NSData dataWithContentsOfURL:self.imageURL];
    self.image = [[UIImage alloc] initWithData:data];
    
    cv::Mat avg(1,1,CV_32FC3), hls(1,1,CV_32FC3);
    avg = [self getAverageDot:[self cvMatFromUIImage:self.image]];
    cv::cvtColor(avg, hls, CV_BGR2HLS);
    cv::Vec3b dot = hls.at<cv::Vec3b>(0,0);
    self.hls = [[HLSColor alloc]initWithHue:dot[0]*2 lightness:dot[1] saturation:dot[2]];
    NSLog(@"hls: %d", dot[0]*2);
    
    _shop = shop;
    return self;
}

- (cv::Mat)getAverageDot: (cv::Mat)src
{
    cv::Mat m1, m2;
    cv::reduce(src, m1, 0, CV_REDUCE_AVG);
    cv::reduce(m1, m2, 1, CV_REDUCE_AVG);
    return m2;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end