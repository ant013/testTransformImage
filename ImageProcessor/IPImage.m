//
//  IPImage.m
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 29.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "IPImage.h"

@implementation IPImage

@synthesize imageRawData;                //pointer on array RGB colors pixels

@synthesize imageWidth;                               //Width and Height of image
@synthesize imageHeight;
@synthesize bytesPerPixel;                      //how many bytes need for RGBA pixel
@synthesize bitsPerComponent;                   //how many bits in one color component


#pragma mark - Lifecycle

- (id)init:(UIImage *)image {

    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    imageWidth = CGImageGetWidth(imageRef);
    imageHeight = CGImageGetHeight(imageRef);
    bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    bytesPerPixel = CGImageGetBitsPerPixel(imageRef)/bitsPerComponent;
    imageRawData = malloc(imageWidth * imageHeight * bytesPerPixel);
    if (!imageRawData)
    {
        CGColorSpaceRelease( colorSpace );
        return nil;
    }


    NSUInteger bytesPerRow = bytesPerPixel * imageWidth;

    CGContextRef context = CGBitmapContextCreate(imageRawData, imageWidth, imageHeight,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (!context)
    {
        CGColorSpaceRelease( colorSpace );
        return nil;
    }

    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), imageRef);

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    return self;
}

- (id)initWithRaw:(IPImage *)imageRaw {

    imageWidth = imageRaw.imageWidth;
    imageHeight = imageRaw.imageHeight;
    bytesPerPixel = imageRaw.bytesPerPixel;
    bitsPerComponent = imageRaw.bitsPerComponent;

    free(imageRawData);

    NSUInteger imageSize = imageWidth * imageHeight * bytesPerPixel;
    imageRawData = malloc(imageSize);

    unsigned char *pointer = imageRaw.imageRawData;
    for (NSUInteger index = 0 ; index < imageSize ; index++) imageRawData[index]=pointer[index];

    return self;
}

- (void)imageRelease {

    free(imageRawData);
}

#pragma mark set methods


//put image into object's (area in memory with RGB pixels
- (void)setImage:(UIImage *)image {

    CGImageRef imageRef = [image CGImage];

    imageWidth = CGImageGetWidth(imageRef);
    imageHeight = CGImageGetHeight(imageRef);

    free (imageRawData);
    imageRawData = malloc(imageWidth * imageHeight * bytesPerPixel);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bytesPerRow = bytesPerPixel * imageWidth;

    CGContextRef context = CGBitmapContextCreate(imageRawData, imageWidth, imageHeight,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), imageRef);

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
}

//create image from area in memory
- (UIImage *)makeImageFromRaw {

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bytesPerRow = bytesPerPixel * imageWidth;

    CGContextRef context = CGBitmapContextCreate(imageRawData, imageWidth, imageHeight,
                                              bitsPerComponent, bytesPerRow, colorSpace,
                                              kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGImageRef imageRef = CGBitmapContextCreateImage (context);
    UIImage *rawImage = [UIImage imageWithCGImage:imageRef];

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    return rawImage;

}

@end
