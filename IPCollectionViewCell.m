//
//  IPCollectionViewCell.m
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 30.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "IPCollectionViewCell.h"


@implementation IPCollectionViewCell

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if ([keyPath isEqualToString:@"transformProgress"]) {
        float progress = [[change objectForKey:@"new"] floatValue];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[self activityProgress] setProgress:progress animated:true];

            if (progress==1.0f) [[self collectionView] reloadData];
        });
    }
}

@end
