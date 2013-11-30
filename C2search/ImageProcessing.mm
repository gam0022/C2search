//
//  ImageProcessing.mm
//  C2search
//
//  Created by gam0022 on 2013/11/23.
//  Copyright (c) 2013年 gam0022. All rights reserved.
//

#import "ImageProcessing.h"

@implementation ImageProcessing

-(HLSColor*)getHLSColorFromUIImage: (UIImage*)image
{
    HLSColor *color = [[HLSColor alloc]initWithHue:360 lightness:0 saturation:0];
    
    @try {
        cv::Mat avg(1,1,CV_32FC3), hls(1,1,CV_32FC3);
        avg = [self getAverageDot:[self cvMatFromUIImage:image]];
        cv::cvtColor(avg, hls, CV_BGR2HLS);
        cv::Vec3b dot = hls.at<cv::Vec3b>(0,0);
        color.hue = dot[0] * 2;
        color.lightness = dot[1];
        color.saturation = dot[2];
        return color;
    }
    @catch (NSException *exception) {
        NSLog(@"OpenCVでの画像処理中にエラー: %@", exception);
        return color;
    }
}

-(UIImage*)gouseiImage:(UIImage*)sourceImage
          composeImage:(UIImage*)composeImage
                 width:(float)width
                height:(float)height
{
    
    // グラフィックスコンテキストを作る
    CGSize size = { width, height };
    UIGraphicsBeginImageContext(size);
    
    //元画像を描画
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [sourceImage drawInRect:rect];
    
    //重ね合わせる画像を描画
    rect.origin = CGPointMake(width*0.7, height*0.7);
    rect.size = CGSizeMake(width*0.3, height*0.3);
    [composeImage drawInRect:rect];
    
    // 描画した画像を取得する
    UIImage* shrinkedImage;
    shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return shrinkedImage;
    
}

-(cv::Mat)getAverageDot: (cv::Mat)src
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
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
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
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
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
                                        cvMat.step[0],                            //bytesPerRow
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