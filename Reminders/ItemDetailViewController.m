//
//  DetailViewController.m
//  Reminders
//
//  Created by 陈旭 on 6/5/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "ItemDetailViewController.h"

@interface ItemDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *editPhotoSwitch;

@end

@implementation ItemDetailViewController
{
    UIImage *_image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allowEditPhoto = NO;
    self.editPhotoSwitch.on = self.allowEditPhoto;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 4;
    }else{
        return 1;
    }
}

#pragma mark - Action

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self takePhoto];
    }else if(indexPath.section == 1 && indexPath.row == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self choosePhotoFromLibrary];
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 3 && self.imageView.hidden) {
        return 0.0;
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Add photo

- (void)takePhoto
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = self.editPhotoSwitch.on;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = self.editPhotoSwitch.on;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.hidden = NO;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.editPhotoSwitch.on) {
        _image = info[UIImagePickerControllerEditedImage];
    }else{
        _image = info[UIImagePickerControllerOriginalImage];
    }
    [self showImage:_image];
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
