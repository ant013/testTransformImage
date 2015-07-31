//
//  IPImage.m
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 29.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "IPImage.h"

@implementation IPImage

#pragma mark - Lifecycle

- (id)init:(UIImage *)image {

    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    width = CGImageGetWidth(imageRef);
    height = CGImageGetHeight(imageRef);
    bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    bytesPerPixel = CGImageGetBitsPerPixel(imageRef)/bitsPerComponent;
    imageRawData = malloc(width * height * bytesPerPixel);
    if (!imageRawData)
    {
        CGColorSpaceRelease( colorSpace );
        return nil;
    }


    NSUInteger bytesPerRow = bytesPerPixel * width;

    CGContextRef context = CGBitmapContextCreate(imageRawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (!context)
    {
        CGColorSpaceRelease( colorSpace );
        return nil;
    }

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    return self;
}
- (id)initWithRaw:(IPImage *)imageRaw {

    width = imageRaw.getWidth;
    height = imageRaw.getHeight;
    bytesPerPixel = imageRaw.getBytesPerPixel;
    bitsPerComponent = imageRaw.getBitsPerComponent;

    NSUInteger imageSize = width * height * bytesPerPixel;
    imageRawData = malloc(imageSize);

    unsigned char *pointer = imageRaw.getImageRawData;
    for (NSUInteger index = 0 ; index < imageSize ; index++) imageRawData[index]=pointer[index];

    return self;
}

- (void)dealloc {

    if (imageRawData) free (imageRawData);
}

#pragma mark - transforms

- (void)transformImageWithGrayScale {

    NSUInteger imageSize = width * height * bytesPerPixel;
    for (int byteIndex = 0 ; byteIndex < imageSize ; byteIndex += bytesPerPixel)
    {
        int outputColor = (imageRawData[byteIndex] + imageRawData[byteIndex+1] +
                           imageRawData[byteIndex+2]) / 3;

        for (int swap = 0 ; swap < (bytesPerPixel - 1) ; swap++) {
            imageRawData[byteIndex+swap] = (unsigned char) outputColor;
        }
    }
    
}

- (void)transformImageWithInvertColor {

    NSUInteger imageSize = width * height * bytesPerPixel;
    for (int byteIndex = 0 ; byteIndex < imageSize ; byteIndex += bytesPerPixel)
    {
        for (int swap = 0 ; swap < (bytesPerPixel - 1) ; swap++) {
            imageRawData[byteIndex+swap] = 255 - imageRawData[byteIndex+swap];
        }
    }
    
}

- (void)transformImageWithMirrorView {

    for (NSUInteger row = 0 ; row < height ; row++) {
        for (NSUInteger col = 0 ; col < ((width-1) / 2) ; col++) {
            NSUInteger firstIndex = row * width * bytesPerPixel + col * bytesPerPixel;
            NSUInteger lastIndex = row * width * bytesPerPixel + (width-1) * bytesPerPixel - col * bytesPerPixel;
            for (NSUInteger swap = 0 ; swap < bytesPerPixel ; swap++) {
                unsigned char swapColor = imageRawData[firstIndex+swap];
                imageRawData[firstIndex+swap] = imageRawData[lastIndex+swap];
                imageRawData[lastIndex+swap] = swapColor;
            }
        }
    }    
}

- (void)transformImageWithHalfMirrorView {

    int countPixels = (width/2) + (width % 2);

    for (NSUInteger row = 0 ; row < height ; row++) {
        for (NSUInteger col = 0 ; col < countPixels ; col++) {
            NSUInteger firstIndex = row * width * bytesPerPixel + col * bytesPerPixel;
            NSUInteger lastIndex = row * width * bytesPerPixel + (width-1) * bytesPerPixel - col * bytesPerPixel;
            for (NSUInteger swap = 0 ; swap < bytesPerPixel ; swap++) {
                imageRawData[lastIndex+swap] = imageRawData[firstIndex+swap];
            }
        }
    }
}

- (void)transformImageWithRotate90 {

    unsigned char *newImageRawData = malloc(width * height * bytesPerPixel);
    for (NSUInteger row = 0 ; row < height ; row++) {
        for (NSUInteger col = 0 ; col < width ; col++) {
            NSUInteger index = (row * width * bytesPerPixel + col * bytesPerPixel);
            NSUInteger newIndex = (col) * height * bytesPerPixel + (height-row-1) * bytesPerPixel;
            for (NSUInteger swap = 0 ; swap < bytesPerPixel ; swap++) {
                newImageRawData[newIndex+swap] = imageRawData[index+swap];
            }
        }
    }
    size_t swap = width;
    width = height;
    height = swap;

    free(imageRawData);
    imageRawData = newImageRawData;

}

#pragma mark get methods

@synthesize inProgress;

- (size_t)getWidth {
    return width;
}

- (size_t)getHeight {
    return height;
}

- (size_t)getBytesPerPixel {
    return bytesPerPixel;
}

- (size_t)getBitsPerComponent {
    return bitsPerComponent;
}

- (unsigned char*)getImageRawData {
    return imageRawData;
}

#pragma mark set methods


- (void)setImage:(UIImage *)image {

    CGImageRef imageRef = [image CGImage];

    width = CGImageGetWidth(imageRef);
    height = CGImageGetHeight(imageRef);

    imageRawData = nil;
    imageRawData = malloc(width * height * bytesPerPixel);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bytesPerRow = bytesPerPixel * width;

    CGContextRef context = CGBitmapContextCreate(imageRawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
}

- (UIImage *)makeImageFromRaw {

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bytesPerRow = bytesPerPixel * width;

    CGContextRef context = CGBitmapContextCreate(imageRawData, width, height,
                                              bitsPerComponent, bytesPerRow, colorSpace,
                                              kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGImageRef imageRef = CGBitmapContextCreateImage (context);
    UIImage *rawImage = [UIImage imageWithCGImage:imageRef];

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    return rawImage;

}

@end
