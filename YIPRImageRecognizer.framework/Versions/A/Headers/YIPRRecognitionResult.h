//
//  YIPRRecognitionResult.h
//  YIPRImageRecognizer
//
//  Created by rtanaka
//  Copyright (c) 2013 Yahoo Japan Corp. All rights reserved.
//

/**
 * 画像認識結果の一つのエントリの情報を保持します
 */
@interface YIPRRecognitionResult : NSObject

@property(nonatomic, assign) int imageID;

			     /** 距離 */
@property(nonatomic, assign) double distance;

			     /** 幅 */
@property(nonatomic, assign) int width;

			     /* 高さ */
@property(nonatomic, assign) int height;

			     /** 画像URL */
@property(nonatomic, strong) NSString* imageURL;

			     /** 詳細URL */
@property(nonatomic, strong) NSString* clickURL;

			     /** サムネール画像URL */
@property(nonatomic, strong) NSString* thumbnailURL;

			     /** タイトル */
@property(nonatomic, strong) NSString* title;

			     /** タグ */ 
@property(nonatomic, strong) NSString* tags;

			     /** 外部ID */
@property(nonatomic, strong) NSString* extID;

			     /** 登録時刻 */
@property(nonatomic, strong) NSString* time;

			     /** 特徴点座標 */
@property(nonatomic, strong) NSMutableArray* featurePoints; /* NSPoint Array */

			     /** 物体領域座標 */
@property(nonatomic, strong) NSMutableArray* objectRegion;  /* NSPoint Array */

- (NSString*)description;

@end
