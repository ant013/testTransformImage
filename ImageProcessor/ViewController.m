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

    IPImage *origImage;                              //contain main original image
    TransformImageService *collection;               //sharedInstance of array all transformed images
    NSMutableArray *transformingIndexes;             //contain indexes elements which progress need to change

}

@end

@implementation ViewController

#pragma mark controller methods

- (void)viewDidLoad {

    [super viewDidLoad];
    collection = [TransformImageService sharedInstance];
    transformingIndexes = [[NSMutableArray alloc] init];

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

// method starts when starts progress, using index of action images and repaint progressBars on it;
- (void) ReloadProgressDelegate {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while ([self->transformingIndexes count]) {
            
            NSMutableArray *toRemove = [[NSMutableArray alloc] init];
            NSMutableArray *indexes;

            @synchronized(self->transformingIndexes) {
                indexes = [NSMutableArray arrayWithArray:self->transformingIndexes];
            }
            
            for (NSIndexPath *index in indexes) {

                IPTransformImage *image = [self->collection objectAtIndex:(NSUInteger)index.row];
                dispatch_sync(dispatch_get_main_queue(),^{
                    if ([image transformAction]) {


                            IPCollectionViewCell *cell = nil;
                            cell = (IPCollectionViewCell*)[[self transformedCollectionView] cellForItemAtIndexPath:index];
                            if (cell) [[cell activityProgress] setProgress:[image transformProgress] animated:  NO];

                    } else {

                            [toRemove addObject:index];
                            if ([self->collection count]>index.item)
                                [[self transformedCollectionView] reloadItemsAtIndexPaths:@[index]];
                    }
                });

            }
            if ([toRemove count] > 0) {
                @synchronized(self->transformingIndexes) {
                    [self->transformingIndexes removeObjectsInArray:toRemove];
                }
            }
        }
    });
}


- (IBAction)transform:(id)sender {

    if (origImage) {

        NSUInteger tag = (NSUInteger) [sender tag];

        IPImage *img = [[IPImage alloc] initWithRaw:origImage];

        [collection addObject:img];
        [collection transformLatsObject:tag];
        [[self transformedCollectionView] reloadData];


        NSIndexPath *index = [NSIndexPath indexPathForItem:(NSInteger)([collection count]-1) inSection:0];
        
        @synchronized(transformingIndexes) {
            [transformingIndexes addObject:index];
        }
        
        if ([transformingIndexes count]==1) [self ReloadProgressDelegate];

        [[self transformedCollectionView] reloadData];

    }
}

- (IBAction)tapImageCollection:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save into gallery",@"Use as Original",@"Remove from collection", nil];
    actionSheet.tag = [sender tag];
    [actionSheet showInView:self.view];

}

// After delete some already transformed image, we need decrease all images indexes in delegate wich > this
- (void) deleteImageFromCollectionAtIndex:(NSUInteger)indexImage {
    [collection removeObjectAtIndex:indexImage];
    @synchronized (transformingIndexes) {
        if ([transformingIndexes count]>0) {
            for (NSUInteger i=0 ; i<[transformingIndexes count] ; i++) {
                NSIndexPath *index = [transformingIndexes objectAtIndex:i];
                if ( index.item > indexImage) {
                    NSIndexPath *newIndex = [NSIndexPath indexPathForItem:(index.item-1) inSection:0];
                    [transformingIndexes replaceObjectAtIndex:i withObject:newIndex];
                }
            }
        }
    }
    [[self transformedCollectionView] reloadData];
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
            [origImage imageRelease];
            origImage = [[IPImage alloc] initWithRaw:[collection objectAtIndex:indexImage]];
            [self originalImageView].image = [origImage makeImageFromRaw];
            break;
        case 2:
            [self deleteImageFromCollectionAtIndex:indexImage];
            break;

    }
}



#pragma mark Collection Delegates


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return (NSInteger)[collection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"transformedImage";

    IPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setTag:indexPath.row];
    IPTransformImage *currentImage = [collection objectAtIndex:(NSUInteger)indexPath.row];

    @synchronized (currentImage) {
    if ([currentImage transformAction]) {
            [cell transformedImage].hidden = YES;
            [cell actionButton].hidden = YES;
            [cell activityProgress].hidden = NO;
    } else {
        [cell transformedImage].hidden = NO;
        [cell actionButton].hidden = NO;
        [cell activityProgress].hidden = YES;

        [cell transformedImage].image = [currentImage makeImageFromRaw];
        [cell actionButton].tag = indexPath.row;
    }
    }
    return cell;

}




@end
