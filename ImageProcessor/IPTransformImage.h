//
//  IPTransformImage.h
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 01.08.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "IPImage.h"

@interface IPTransformImage : IPImage

@property BOOL transformAction;
@property NSString *transformName;
@property float transformProgress;
@property NSTimer *timerProcess;

-(void)transformImageWithGrayScale;
-(void)transformImageWithInvertColor;
-(void)transformImageWithMirrorView;
-(void)transformImageWithRotate90;
-(void)transformImageWithHalfMirrorView;

@end
