//
//  ViewController.h
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 29.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *originalImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *transformedCollectionView;
@property (nonatomic) UIImagePickerController *imagePickerController;

- (IBAction)openImageFromLibrary:(id)sender;
- (IBAction)transform:(id)sender;
- (IBAction)tapImageCollection:(id)sender;


@end

