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

//@property NSMutableArray *transformImages;

+(id)sharedInstance;

-(void)removeObjectAtIndex:(NSUInteger)index;
-(void)addObject:(IPImage *)image;

-(IPTransformImage *)objectAtIndex:(NSUInteger)index;
-(IPImage *)objectAtIndexWithoutTransform:(NSUInteger)index;
-(NSUInteger)count;


-(BOOL)transformObjectAtIndex:(NSUInteger)index type:(NSUInteger)type;
-(BOOL)transformLatsObject:(NSUInteger)type;

//-(NSNumber *)objectProgressAtIndex:(NSUInteger)index;
//-(void)setObjectProgressAtIndex:(NSUInteger)index progress:(NSNumber *)progress;

@end
