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
        NSLog(@"%@",[change objectForKey:@"new"]);
        [[self activityProgress] setProgress:[[change objectForKey:@"new"] floatValue] animated:true];
    }

}

@end
