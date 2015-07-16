//
//  DetailViewController.m
//  Reminders
//
//  Created by 陈旭 on 6/5/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "Item.h"
#import "ImageViewController.h"

@interface ItemDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *editPhotoSwitch;

@end

@implementation ItemDetailViewController
{
    UIImage *_image;
    UIImagePickerController *_imagePicker;
    NSDate *_dueDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allowEditPhoto = NO;
    self.editPhotoSwitch.on = self.allowEditPhoto;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if ([self.item hasPhoto]) {
        UIImage *existingImage = [self.item photoImage];
        if (existingImage != nil) {
            //The call to if (existingImage != nil) is a bit of defensive programming.
            [self showImage:existingImage];
        }
    }
    
    if (self.item.dueDate != nil) {
        self.reminderSwitchControl.on = self.item.shouldRemind;
        _dueDate = self.item.dueDate;
    }else{
        self.reminderSwitchControl.on = NO;
        _dueDate = [NSDate date];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// when enter background, shun down the imagePicker.
- (void)applicationDidEnterBackground
{
    if (_imagePicker != nil) {
        [self dismissViewControllerAnimated:NO completion:nil]; _imagePicker = nil;
    }
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
        return 2;
    }
}

#pragma mark - Action

- (IBAction)done:(id)sender
{
    //don't forget init

    if (_image != nil) {
        if (![self.item hasPhoto]) {
            self.item.photoId = @([Item nextPhotoId]);
        }
        
        NSData *data = UIImageJPEGRepresentation(_image, 1.0);
        NSError *error;
        if (![data writeToFile:[self.item photoPath] options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error writing file: %@", error);
        }
    }
    
    self.allowEditPhoto = self.editPhotoSwitch.on;

    [self.delegate itemDetailViewController:self didFinishEditingItem:self.item];
    
    self.item.shouldRemind = self.reminderSwitchControl.on;
    self.item.dueDate = _dueDate;
}

- (IBAction)cancel:(id)sender
{
    [self.delegate itemDetailViewControllerDidCancel:self];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        [self takePhoto];
        
    }else if(indexPath.section == 1 && indexPath.row == 2) {
        [self choosePhotoFromLibrary];
        
    }else if(indexPath.section == 1 && indexPath.row == 0){
        self.editPhotoSwitch.on = !self.editPhotoSwitch.on;
        
    }else if(indexPath.section == 1 && indexPath.row == 3){
        ImageViewController *controller = [[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:nil];
        if (_image != nil) {
            [controller showFullImageInViewController:self withImage:_image];
        }else{
            [controller showFullImageInViewController:self withImage:[self.item photoImage]];
        }
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

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }else{
        return tableView.sectionHeaderHeight;
    }
}


#pragma mark - Add photo

- (void)takePhoto
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = self.editPhotoSwitch.on;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = self.editPhotoSwitch.on;
    [self presentViewController:_imagePicker animated:YES completion:nil];
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
    
    _imagePicker = nil;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _imagePicker = nil;
}

#pragma mark - Date picker

- (void)updateDueDateLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    self.dueDateLabel.text = [formatter stringFromDate:_dueDate];
}

@end
