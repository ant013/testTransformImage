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

-(void)addObject:(IPImage *)image {

    IPTransformImage *transformImage = [[IPTransformImage alloc] init];

    transformImage.imageRawData = image.imageRawData;
    transformImage.imageWidth = image.imageWidth;
    transformImage.imageHeight = image.imageHeight;
    transformImage.bytesPerPixel = image.bytesPerPixel;
    transformImage.bitsPerComponent = image.bitsPerComponent;
    transformImage.transformAction = NO;
    transformImage.transformName = @"NoTransform";
    transformImage.transformProgress = 0.0f;

    [transformImages addObject:transformImage];

}

-(void)removeObjectAtIndex:(NSUInteger)index {

    if (index<[transformImages count]) [transformImages removeObjectAtIndex:index];

}

-(IPTransformImage *)objectAtIndex:(NSUInteger)index {

    if (index<[transformImages count]) return [transformImages objectAtIndex:index];

    return nil;
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
-(NSUInteger)count {
    return [transformImages count];
}

-(BOOL)transformObjectAtIndex:(NSUInteger)index type:(NSUInteger)type {

    IPTransformImage *workImage = [transformImages objectAtIndex:index];

//    [workImage setTransformAction:YES];
    NSLog(@"%d",workImage.transformAction);
    //    workImage.timerProcess =

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

        NSTimeInterval delayInterval = 0.1f;
        NSInteger time = rand()%10 + 1;
        float intervalPerPercent = (float) delayInterval/time;

        while (workImage.transformProgress < 1.0f) {
            NSLog(@"%f",workImage.transformProgress);
            float newProgress = workImage.transformProgress + intervalPerPercent;
            [workImage setTransformProgress:newProgress];
            [NSThread sleepForTimeInterval: delayInterval];
        }

        workImage.transformAction = NO;
        workImage.transformProgress = 1.0f;

    return YES;
}
-(BOOL)transformLatsObject:(NSUInteger)type {


    IPTransformImage *workImage = [self objectAtIndex:([transformImages count]-1)];

    [workImage setTransformAction:YES];
//    NSLog(@"%d",workImage.transformAction);
    //    workImage.timerProcess =

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
        NSInteger time = rand()%10 + 1;
        float intervalPerPercent = (float) delayInterval / time;
        float progress = 0.0f;

        while (workImage.transformProgress < 1.0f) {
            NSLog(@"%f",workImage.transformProgress);
            progress +=intervalPerPercent;
            [workImage setValue:[NSNumber numberWithFloat:progress] forKey:@"transformProgress"];
//            workImage.transformProgress += intervalPerPercent;
            [NSThread sleepForTimeInterval: delayInterval];

        }

        workImage.transformAction = NO;
        workImage.transformProgress = 1.0f;

    });
    
    return YES;
}

@end

