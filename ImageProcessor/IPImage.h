//
//  IPImage.h
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 29.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


              //how many bits in one color component

@interface IPImage : NSObject
{
    unsigned char* imageRawData;                //pointer on array RGB colors pixels
    size_t width;                               //width and height of image
    size_t height;
    size_t bytesPerPixel;                      //how many bytes need for RGBA pixel
    size_t bitsPerComponent;                   //how many bits in one color component
}

-(id)init:(UIImage *)image;
-(id)initWithRaw:(IPImage *)imageRaw;
-(void)dealloc;

-(void)transformImageWithGrayScale;
-(void)transformImageWithInvertColor;
-(void)transformImageWithMirrorView;
-(void)transformImageWithRotate90;
-(void)transformImageWithHalfMirrorView;

-(size_t)getWidth;
-(size_t)getHeight;
-(size_t)getBytesPerPixel;
-(size_t)getBitsPerComponent;
-(unsigned char*)getImageRawData;

-(void)setImage:(UIImage *)image;
-(UIImage *) makeImageFromRaw;

@end
