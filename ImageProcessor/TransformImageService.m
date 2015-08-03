//
//  TransformImageService.m
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 01.08.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "TransformImageService.h"

@implementation TransformImageService

+ (instancetype)sharedInstance
{
    static TransformImageService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TransformImageService alloc] init];
        sharedInstance->transformImages = [[NSMutableArray alloc] init];
    });
    return sharedInstance;
}

#pragma mark manipulate actions

-(void)addObject:(IPImage *)image {

    IPTransformImage *transformImage = [[IPTransformImage alloc] init];

    transformImage.imageRawData = image.imageRawData;
    transformImage.imageWidth = image.imageWidth;
    transformImage.imageHeight = image.imageHeight;
    transformImage.bytesPerPixel = image.bytesPerPixel;
    transformImage.bitsPerComponent = image.bitsPerComponent;
    transformImage.transformAction = YES;
    transformImage.transformName = @"NoTransform";
    transformImage.transformProgress = 0.0f;

    [transformImages addObject:transformImage];

}

-(void)removeObjectAtIndex:(NSUInteger)index {

    if (index<[transformImages count]) [transformImages removeObjectAtIndex:index];

}

#pragma mark get methods

-(IPTransformImage *)objectAtIndex:(NSUInteger)index {

    if (index<[transformImages count]) return [transformImages objectAtIndex:index];

    return nil;
}
-(IPTransformImage *)lastObject {

    return [transformImages lastObject];
}


-(IPImage *)objectAtIndexWithoutTransform:(NSUInteger)index {

    IPImage *image = [[IPTransformImage alloc] init];

    image.imageRawData = [[transformImages objectAtIndex:index] imageRawData];
    image.imageWidth = [[transformImages objectAtIndex:index] imageWidth];
    image.imageHeight = [[transformImages objectAtIndex:index] imageHeight];
    image.bytesPerPixel = [[transformImages objectAtIndex:index] bytesPerPixel];
    image.bitsPerComponent = [[transformImages objectAtIndex:index] bitsPerComponent];

    return image;

}

#pragma mark index and count

-(NSUInteger)indexOfObject:(IPTransformImage *)object {

    return [transformImages indexOfObjectIdenticalTo:object];
}

-(NSUInteger)count {
    return [transformImages count];
}

#pragma mark transforming methods

-(BOOL)transformLatsObject:(NSUInteger)type {


    IPTransformImage *workImage = [self objectAtIndex:([transformImages count]-1)];
    [workImage setTransformAction:YES];

    switch (type) {
        case 1:
            workImage.transformName = @"Rotate";
            [workImage transformImageWithRotate90];
            break;
        case 2:
            workImage.transformName = @"Mirror";
            [workImage transformImageWithMirrorView];
            break;
        case 3:
            workImage.transformName = @"Half Mirror";
            [workImage transformImageWithHalfMirrorView];
            break;
        case 4:
            workImage.transformName = @"Gray Scale";
            [workImage transformImageWithGrayScale];
            break;
        case 5:
            workImage.transformName = @"Invert";
            [workImage transformImageWithInvertColor];
            break;
        default:
            return NO;
            break;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSTimeInterval delayInterval = 0.1f;
        NSInteger time = rand()%29 + 1;
        float intervalPerPercent = (float) delayInterval / time;
 
        while ([workImage transformProgress]<1.0f) {
            workImage.transformProgress += intervalPerPercent;
            [NSThread sleepForTimeInterval: delayInterval];
        }
        workImage.transformProgress = 1.0f;
        [workImage setTransformAction:NO];
    });

    return YES;
}

@end

