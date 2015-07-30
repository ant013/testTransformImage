//
//  IPImageList.h
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 30.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPImage.h"


@interface IPImageList : NSObject

@property (strong, nonatomic) NSMutableArray *imageList;

-(id) init;

@end
