//
//  YIPRImageRecognizeView.h
//  YIPRImageRecognizer
//
//  Created by kmorimot
//  Copyright (c) 2013 Yahoo Japan Corp. All rights reserved.
//

#include "TargetConditionals.h"
#if !TARGET_IPHONE_SIMULATOR
#define HAS_AVF
#endif

#import <UIKit/UIKit.h>
#ifdef HAS_AVF
#import <AVFoundation/AVFoundation.h>
#endif

@protocol YIPRImageRecognizeDelegate;

/**
 * YIPRImageRecognizeViewは、カメラからの入力をもとにその表示と認識処理を行います
 */
@interface YIPRImageRecognizeView : UIView
#ifdef HAS_AVF
<AVCaptureVideoDataOutputSampleBufferDelegate>
#endif

/**
 * 認識完了時のデリゲート
 */
@property (nonatomic, weak) id<YIPRImageRecognizeDelegate> delegate;

/**
 * 画面上の切り取る領域を設定します。
 * デフォルトでは画面中央から正方形になるような矩形を切り取ります。
 */
@property (nonatomic) CGRect cropFrame;

/**
 * リクエスト画像の1辺の長さ(ピクセル)を設定します。
 * デフォルトでは変更しないことを推奨します。
 */
@property (nonatomic) NSInteger imageSize;

/**
 * リクエスト用アプリケーションID
 */
@property (nonatomic, strong) NSString* applicationID;

/**
 * アプリケーション名
 */
@property (nonatomic, strong) NSString* applicationName;

/**
 * アプリケーションのバージョン
 */
@property (nonatomic, strong) NSString* applicationVersion;

/**
 * 端末ID
 */
@property (nonatomic, strong) NSString* clientID;

/**
 * 最大リトライ数
 */
@property (nonatomic) NSInteger maxRetryCount;

/**
 * 認識状態のフラグ
 */
@property (nonatomic, readonly) BOOL recognizing;

/**
 * コンストラクタ
 *
 * @param aDecoder  NSCoder
 * @param url       画像認識APIのURL
 * 
 * @return YIPRImageRecognizeViewのインスタンス
 */
- (id)initWithCoder:(NSCoder *)aDecoder url:(NSString*)url;
/**
 * コンストラクタ
 *
 * @param frame  viewサイズ
 * @param url    画像認識APIのURL
 *
 * @return YIPRImageRecognizeViewのインスタンス
 */
- (id)initWithFrame:(CGRect)frame url:(NSString*)url;

/**
 * カメラのキャプチャを開始します
 *
 * @param error  キャプチャ開始時のエラー(nilの場合は正常終了)
 */
- (void)startCapture:(NSError**)error;
/**
 * カメラのキャプチャを終了します
 */
- (void)stopCapture;

/**
 * 認識を開始します
 *
 * @param error  認識開始時のエラー(nilの場合は正常終了)
 */
- (void)startRecognize:(NSError**)error;
/**
 * 認識を終了します
 */
- (void)stopRecognize;

@end

@protocol YIPRImageRecognizeDelegate <NSObject>

/**
 * 認識成功時に呼び出されます。
 * 
 * @param view デリゲートメソッドを呼び出したインスタンス
 * @param result 認識結果
 */
- (void)yiprDidImageRecognition:(YIPRImageRecognizeView*)view didRecognitionResult:(NSMutableArray*)result;
/**
 * 認識失敗時に呼び出されます。
 *
 * @param view  デリゲートメソッドを呼び出したインスタンス
 * @param error 認識時エラー
 */
- (void)yiprFailedImageRecognition:(YIPRImageRecognizeView*)view error:(NSError*)error;

@end
