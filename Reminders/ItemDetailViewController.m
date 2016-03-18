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
    BOOL _datePickerVisible;
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
    
    [self updateDueDateLabel];
    self.dueDateLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
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
    if (section == 0 && _datePickerVisible) {
        return 3;
    }else{
        return [super tableView:tableView numberOfRowsInSection:section];
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
    
    [self.item scheduleNotification];

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
        [self hideDatePicker];
        
    }else if(indexPath.section == 1 && indexPath.row == 2) {
        [self choosePhotoFromLibrary];
        [self hideDatePicker];
        
    }else if(indexPath.section == 1 && indexPath.row == 0){
        self.editPhotoSwitch.on = !self.editPhotoSwitch.on;
        [self hideDatePicker];
        
    }else if(indexPath.section == 1 && indexPath.row == 3){
        ImageViewController *controller = [[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:nil];
        if (_image != nil) {
            [controller showFullImageInViewController:self withImage:_image];
        }else{
            [controller showFullImageInViewController:self withImage:[self.item photoImage]];
        }
        [self hideDatePicker];
        
    }else if(indexPath.section == 0 && indexPath.row == 1){
        if (!_datePickerVisible) {
            [self showDatePicker];
        }else{
            [self hideDatePicker];
        }
        
    }else if(indexPath.section == 0 && indexPath.row == 0){
        self.reminderSwitchControl.on = !self.reminderSwitchControl.on;
    }
        
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 3 && self.imageView.hidden) {
        return 0.0;
    }else if(indexPath.section == 0 && indexPath.row == 2){
        return 217.0f;
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
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = self.editPhotoSwitch.on;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
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

- (void)showDatePicker
{
    _datePickerVisible = YES;
    
    NSIndexPath *indexPathDateRow = [NSIndexPath indexPathForRow:1 inSection:0];
    
    NSIndexPath *indexPathDatePicker = [NSIndexPath indexPathForRow:2 inSection:0];
    
    self.dueDateLabel.textColor = self.tableView.tintColor;
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPathDatePicker] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:@[indexPathDateRow] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    UITableViewCell *datePickerCell = [self.tableView cellForRowAtIndexPath:indexPathDatePicker];
    
    UIDatePicker *datePicker = (UIDatePicker *)[datePickerCell viewWithTag:100];
    
    [datePicker setDate:_dueDate animated:NO];
}

- (void)hideDatePicker
{
    if (_datePickerVisible) {
        _datePickerVisible = NO;
        
        NSIndexPath *indexPathDateRow = [NSIndexPath indexPathForRow:1 inSection:0];
        
        NSIndexPath *indexPathDatePicker = [NSIndexPath indexPathForRow:2 inSection:0];
        
        self.dueDateLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPathDateRow] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView deleteRowsAtIndexPaths:@[indexPathDatePicker] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DatePickerCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.f, 216.f)];
            datePicker.tag = 100;
            [cell.contentView addSubview:datePicker];
            
            [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            
        }
        return cell;
        
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView
indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        return [super tableView:tableView indentationLevelForRowAtIndexPath:newIndexPath];
    }else{
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (void)dateChanged:(UIDatePicker *)datePicker
{
    _dueDate = datePicker.date;
    [self updateDueDateLabel];
}

@end
