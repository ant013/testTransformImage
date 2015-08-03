//
//  TransformImageService.h
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 01.08.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "IPTransformImage.h"

@interface TransformImageService : NSObject
{
    NSMutableArray *transformImages;
}

+(id)sharedInstance;

-(void)addObject:(IPImage *)image;
-(void)removeObjectAtIndex:(NSUInteger)index;

-(IPTransformImage *)objectAtIndex:(NSUInteger)index;
-(IPTransformImage *)lastObject ;

-(IPImage *)objectAtIndexWithoutTransform:(NSUInteger)index;

-(NSUInteger)indexOfObject:(IPTransformImage *)object;
-(NSUInteger)count;

-(BOOL)transformLatsObject:(NSUInteger)type;

@end


