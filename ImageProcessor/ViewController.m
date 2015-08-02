//
//  ViewController.m
//  ImageProcessor
//
//  Created by Anton Stavnichiy on 29.07.15.
//  Copyright (c) 2015 Anton Stavnichiy. All rights reserved.
//

#import "ViewController.h"
#import "IPImage.h"
#import "IPCollectionViewCell.h"
#import "TransformImageService.h"

@interface ViewController ()
{
    IPImage *origImage;
    TransformImageService *collection;
    
}

@end

@implementation ViewController

#pragma mark controller methods

- (void)viewDidLoad {

    [super viewDidLoad];
    collection = [TransformImageService sharedInstance];
    [self transformedCollectionView].delegate = self;
    [self transformedCollectionView].dataSource = self;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark choose photo with ImagePicker

- (IBAction)openImageFromLibrary:(id)sender {

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;

    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];


    if (!origImage) {
        origImage = [[IPImage alloc] init:image];
    } else {
        [origImage setImage:image];
    }

    [self originalImageView].image = [origImage makeImageFromRaw];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save into gallery."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    [alert show];
}



#pragma mark action for images

- (IBAction)transform:(id)sender {

    if (origImage) {

        NSUInteger tag = (NSUInteger) [sender tag];

        IPImage *img = [[IPImage alloc] initWithRaw:origImage];

        [collection addObject:img];
        [self.transformedCollectionView reloadData];

        [collection transformLatsObject:tag];



        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            IPTransformImage *workImage = [self->collection lastObject];
            [workImage setTransformAction:YES];
            NSTimeInterval delayInterval = 0.1f;
            NSInteger time = rand()%10 + 1;
            float intervalPerPercent = (float) delayInterval / time;
            float progress = 0.0f;

            while ([self->collection objectAtIndex:[self->collection indexOfObject:workImage]].transformProgress < 1.0f) {
                progress +=intervalPerPercent;
//                [workImage setValue:[NSNumber numberWithFloat:progress] forKey:@"transformProgress"];
                workImage.transformProgress += intervalPerPercent;


                dispatch_sync(dispatch_get_main_queue(),^{

                    NSUInteger ind = [self->collection indexOfObject:workImage];
                    NSIndexPath *index = [NSIndexPath indexPathForItem:(NSInteger)ind inSection:0];

                    IPCollectionViewCell *cell = nil;
                    while (!cell) {
                        cell = (IPCollectionViewCell*)[[self transformedCollectionView] cellForItemAtIndexPath:index];
                    }
                    NSLog(@"I got it!");
                    [[cell activityProgress] setProgress:progress animated:YES];
//
                });
                [NSThread sleepForTimeInterval: delayInterval];

            }
            
            [workImage setTransformAction:NO];
            [[self transformedCollectionView] reloadData];

        });

        [[self transformedCollectionView] reloadData];



    }
}

- (IBAction)tapImageCollection:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save into gallery",@"Use as Original",@"Remove from collection", nil];
    actionSheet.tag = [sender tag];
    [actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSUInteger indexImage = (NSUInteger) [actionSheet tag];

    switch (buttonIndex) {
        case 0: {
            UIImage *image = [[collection objectAtIndex:indexImage] makeImageFromRaw];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
            break;
        case 1:
            origImage = [[IPImage alloc] initWithRaw:[collection objectAtIndex:indexImage]];
            [self originalImageView].image = [origImage makeImageFromRaw];
            break;
        case 2:
            [collection removeObjectAtIndex:indexImage];
            break;

    }

    [[self transformedCollectionView] reloadData];

}



#pragma mark Collection Delegates


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return (NSInteger)[collection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"transformedImage";

    IPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    IPTransformImage *currentImage = [collection objectAtIndex:(NSUInteger)indexPath.row];
    if ([currentImage transformAction]) {

    } else {
        [cell transformedImage].image = [currentImage makeImageFromRaw];
        [cell actionButton].tag = indexPath.row;
        [cell activityProgress].hidden = YES;
    }
    return cell;

}




@end
