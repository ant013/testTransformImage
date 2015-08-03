//
//  IPImage.h
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 29.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface IPImage : NSObject

@property unsigned char* imageRawData;                //pointer on array RGB colors pixels

@property size_t imageWidth;                               //width and height of image
@property size_t imageHeight;
@property size_t bytesPerPixel;                      //how many bytes need for RGBA pixel
@property size_t bitsPerComponent;                   //how many bits in one color component

- (id)init:(UIImage *)image;                     //init object with image
- (id)initWithRaw:(IPImage *)imageRaw;           //init object with another object (copy all)
- (void)imageRelease;                                 // free memory after malloc


- (void)setImage:(UIImage *)image;               //put image into object's (area in memory with RGB pixels
- (UIImage *) makeImageFromRaw;                  //create image from area in memory

@end
