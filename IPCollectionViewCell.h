//
//  IPCollectionViewCell.h
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 30.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPCollectionViewCell : UICollectionViewCell
{
    NSTimer *progressTimer;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *transformedImage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIProgressView *activityProgress;

@property (weak, nonatomic) UICollectionView *collectionView;

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
