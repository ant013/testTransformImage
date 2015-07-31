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

@interface ViewController ()
{
    IPImage *origImage;
    NSMutableArray *transformedImages;
}

@end

@implementation ViewController

#pragma mark controller methods

- (void)viewDidLoad {
    [super viewDidLoad];
    transformedImages = [[NSMutableArray alloc] init];
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


#pragma mark timer and selector for ProcessView

- (void)showActivityProgress {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSTimer *progressTimer;
        progressTimer = [[NSTimer alloc] init];

        NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndex:[self->transformedImages count]];
        IPCollectionViewCell *cell = (IPCollectionViewCell *)[[self transformedCollectionView] cellForItemAtIndexPath:indexPath];

    //    [cell activityProgress].hidden = NO;

//        progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
//                                                         target:self
//                                                       selector:@selector(timerProgressChange:)
//                                                       userInfo:nil
//                                                        repeats:YES];
        NSUInteger delayTime =0;//= rand() % 9 + 1;
        while (delayTime<10) {
            [cell activityProgress].progress += 0.1f;
//            [[self transformedCollectionView] reloadItemsAtIndexPaths:@[indexPath]];
            [[self transformedCollectionView] reloadData];
            sleep(1);
            delayTime++;
        }
        //sleep(delayTime);
        [[self->transformedImages lastObject] setInProgress:NO];
//        NSLog(@"yepii delfault thread!");
        [cell activityProgress].hidden = YES;

    });
}

- (void)timerProgressChange:(NSTimer *)timer {

    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndex:[transformedImages count]];
    IPCollectionViewCell *cell = (IPCollectionViewCell *)[[self transformedCollectionView] cellForItemAtIndexPath:indexPath];
    NSLog(@"yepii");
    [cell activityProgress].progress += 0.01f;

    if ([cell activityProgress].progress == 1.0f) {
        [timer invalidate];
//        [cell transformedImage].hidden = NO;
//        [self actionButton].hidden = NO;
    }
}



#pragma mark action for images

- (IBAction)transform:(id)sender {

    if (origImage) {

        IPImage *img = [[IPImage alloc] initWithRaw:origImage];
        [img setInProgress:YES];
        [self->transformedImages addObject:img];

        [[self transformedCollectionView] reloadData];

        [self showActivityProgress];
        [[self transformedCollectionView] reloadData];

        switch ([sender tag]) {
            case 1: [img transformImageWithRotate90];
                break;
            case 2: [img transformImageWithMirrorView];
                break;
            case 3: [img transformImageWithHalfMirrorView];
                break;
            case 4: [img transformImageWithGrayScale];
                break;
            case 5: [img transformImageWithInvertColor];
                break;
        };



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
            UIImage *image = [[transformedImages objectAtIndex:indexImage] makeImageFromRaw];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
            break;
        case 1:
            origImage = [[IPImage alloc] initWithRaw:[transformedImages objectAtIndex:indexImage]];
            [self originalImageView].image = [origImage makeImageFromRaw];
            break;
        case 2:
            [transformedImages removeObjectAtIndex:indexImage];
            break;

    }

    [[self transformedCollectionView] reloadData];

}



#pragma mark Collection Delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return (NSInteger)[transformedImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"transformedImage";

    IPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    IPImage *currentImage = [transformedImages objectAtIndex:(NSUInteger)indexPath.row];

    if (![currentImage inProgress]) {
        cell.transformedImage.image = [currentImage makeImageFromRaw];
        cell.actionButton.tag = indexPath.row;
    } else {

    }
//        if ([currentImage inProgress]) {
//        currentImage.inProgress = [cell showActivityProgress:YES];
//        cell set = @"inProgress";
//    }
    return cell;

}




@end
