//
//  IPTransformImage.m
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 01.08.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "IPTransformImage.h"

@implementation IPTransformImage

@synthesize transformAction;
@synthesize transformName;
@synthesize transformProgress;

#pragma mark - transforms

- (void)transformImageWithGrayScale {

    NSUInteger imageSize = self.imageWidth * self.imageHeight * self.bytesPerPixel;
    for (int byteIndex = 0 ; byteIndex < imageSize ; byteIndex += self.bytesPerPixel)
    {
        int outputColor = (self.imageRawData[byteIndex] + self.imageRawData[byteIndex+1] +
                           self.imageRawData[byteIndex+2]) / 3;

        for (int swap = 0 ; swap < (self.bytesPerPixel - 1) ; swap++) {
            self.imageRawData[byteIndex+swap] = (unsigned char) outputColor;
        }
    }

}

- (void)transformImageWithInvertColor {

    NSUInteger imageSize = self.imageWidth * self.imageHeight * self.bytesPerPixel;
    for (int byteIndex = 0 ; byteIndex < imageSize ; byteIndex += self.bytesPerPixel)
    {
        for (int swap = 0 ; swap < (self.bytesPerPixel - 1) ; swap++) {
            self.imageRawData[byteIndex+swap] = 255 - self.imageRawData[byteIndex+swap];
        }
    }

}

- (void)transformImageWithMirrorView {

    for (NSUInteger row = 0 ; row < self.imageHeight ; row++) {
        for (NSUInteger col = 0 ; col < ((self.imageWidth-1) / 2) ; col++) {
            NSUInteger firstIndex = row * self.imageWidth * self.bytesPerPixel + col * self.bytesPerPixel;
            NSUInteger lastIndex = row * self.imageWidth * self.bytesPerPixel + (self.imageWidth-1) * self.bytesPerPixel - col * self.bytesPerPixel;
            for (NSUInteger swap = 0 ; swap < self.bytesPerPixel ; swap++) {
                unsigned char swapColor = self.imageRawData[firstIndex+swap];
                self.imageRawData[firstIndex+swap] = self.imageRawData[lastIndex+swap];
                self.imageRawData[lastIndex+swap] = swapColor;
            }
        }
    }
}

- (void)transformImageWithHalfMirrorView {

    int countPixels = (self.imageWidth/2) + (self.imageWidth % 2);

    for (NSUInteger row = 0 ; row < self.imageHeight ; row++) {
        for (NSUInteger col = 0 ; col < countPixels ; col++) {
            NSUInteger firstIndex = row * self.imageWidth * self.bytesPerPixel + col * self.bytesPerPixel;
            NSUInteger lastIndex = row * self.imageWidth * self.bytesPerPixel + (self.imageWidth-1) * self.bytesPerPixel - col * self.bytesPerPixel;
            for (NSUInteger swap = 0 ; swap < self.bytesPerPixel ; swap++) {
                self.imageRawData[lastIndex+swap] = self.imageRawData[firstIndex+swap];
            }
        }
    }
}

- (void)transformImageWithRotate90 {

    unsigned char *newImageRawData = malloc(self.imageWidth * self.imageHeight * self.bytesPerPixel);
    for (NSUInteger row = 0 ; row < self.imageHeight ; row++) {
        for (NSUInteger col = 0 ; col < self.imageWidth ; col++) {
            NSUInteger index = (row * self.imageWidth * self.bytesPerPixel + col * self.bytesPerPixel);
            NSUInteger newIndex = (col) * self.imageHeight * self.bytesPerPixel + (self.imageHeight-row-1) * self.bytesPerPixel;
            for (NSUInteger swap = 0 ; swap < self.bytesPerPixel ; swap++) {
                newImageRawData[newIndex+swap] = self.imageRawData[index+swap];
            }
        }
    }
    size_t swap = self.imageWidth;
    self.imageWidth = self.imageHeight;
    self.imageHeight = swap;

    free(self.imageRawData);
    self.imageRawData = newImageRawData;
    
}

@end
