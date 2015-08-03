//
//  IPTransformImage.h
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 01.08.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "IPImage.h"

@interface IPTransformImage : IPImage

@property BOOL transformAction;                 //YES - if object is transforming now
@property float transformProgress;              //progress of object transforming
@property NSString *transformName;              //name of transform action

-(void)transformImageWithGrayScale;
-(void)transformImageWithInvertColor;
-(void)transformImageWithMirrorView;
-(void)transformImageWithRotate90;
-(void)transformImageWithHalfMirrorView;

@end
