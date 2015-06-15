//
//  ListViewController.m
//  Reminders
//
//  Created by 陈旭 on 5/28/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "ListViewController.h"
#import "List.h"
#import "ItemCell.h"
#import "Item.h"
#import "ItemDetailViewController.h"
#import "UIImage+Resize.h"

static CGFloat const DefaltRowHeight = 44.0f;
static CGFloat const DetailButtonWidth = 40.0f;
static CGFloat const checkButtonWidth = 43.0f;
static CGFloat const imageViewWidth = 43.0f;

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate,UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *headView;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemsCountLabel;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *completedBarButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *ListsBarButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneOrEditButton;

- (IBAction)clickCheckButton:(id)sender;
- (IBAction)doneOrEdit:(id)sender;
- (IBAction)hideOrShowCompletedItems:(id)sender;

@end

@implementation ListViewController
{
    List *_list;
    BOOL _isItemEditing;
    NSIndexPath *_editingIndexPath;
    CGFloat _editingRowHeight;
    CGFloat _notEditingTextViewWidth;
    BOOL _isListEditing;
    BOOL _isCompletedItemsHidden;
}

#pragma mark - init and load

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //add a seperator at the top of the table view and seperate the top view with the table view
    //if put these lines in viewDidLoad, then self.tableview.frame.size will not work
    CGRect seperatorFrame = CGRectMake(15, self.tableView.frame.origin.y - 1, self.view.bounds.size.width, 1);
    UIView *seperatorView = [[UIView alloc] initWithFrame:seperatorFrame];
    seperatorView.backgroundColor = [self.tableView separatorColor];
    [self.view addSubview:seperatorView];
    
    CGRect statusViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    UIView *statusView = [[UIView alloc] initWithFrame:statusViewFrame];
    statusView.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //change the background color of status bar to black
    CGRect statusViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    UIView *statusView = [[UIView alloc] initWithFrame:statusViewFrame];
    statusView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusView];
    
    UINib *ItemCell = [UINib nibWithNibName:@"ItemCell" bundle:nil];
    [self.tableView registerNib:ItemCell forCellReuseIdentifier:@"ItemCell"];
    
    _list = [[List alloc] init];
    _list.name = @"Study";
    _list.uncheckedItemsCount = 1;
    _list.items = [[NSMutableArray alloc] initWithCapacity:10];
    
    Item *item1 = [[Item alloc] init];
    item1.text = @"ifAn assertion is raised if you return nil” means that returning nil instead of a valid UITableViewCell object will crash the app on purpose because you’re doing something you’re not supposed to. An assertion is a special debugging tool that is used to check rpose because you’re doing something you’re not supposed to. An assertion is a special debugging tool that is used to check";
    item1.isChecked = NO;
    item1.photoId = @-1;
    [_list.items addObject:item1];
    
    Item *item3 = [[Item alloc] init];
    item3.text = @"ifAn is raised if you retur";
    item3.isChecked = NO;
    item3.photoId = @-1;
    [_list.items addObject:item3];
    
    Item *item2 = [[Item alloc] init];
    item2.text = @"ifAn assertion is raised if you return nil” means that returning nil instead of a valid UITableViewCell object will crash the app on purpose because you’re doing something you’re not supposed to. An assertion is a special debugging tool that is used to check rpose because you’re doing something you’re not supposed to. An assertion is a special debugging tool that is used to check";
    item2.isChecked = YES;
    item2.photoId = @-1;
    [_list.items addObject:item2];
    
    [self updateNameLabel];
    [self updateItemsCountLabel];
    [self updateDoneOrEditButtonTitle];
    
    //tap anywhere below the existing rows will insert a new row
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(insertOneRow:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    //hide the empty rows
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //in editing row status, change the left button from delete to select
    [self.tableView setAllowsMultipleSelectionDuringEditing:YES];
    
    //scroll to the bottom of a UITableView before the view appears
    if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height );
        [self.tableView setContentOffset:offset animated:YES];
    }
    
    //Add a empty area at the bottom of tableview
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, DefaltRowHeight, 0.0);
    
    [self updateCompletedBarButtonTitle];
}

#pragma mark - update label and button title

- (void)updateNameLabel
{
    self.nameLabel.text = _list.name;
}

- (void)updateItemsCountLabel
{
    [_list countUncheckedItems];
    
    if (_list.uncheckedItemsCount == 1){
        self.itemsCountLabel.text = NSLocalizedString(@"1 item", @"");
    }else if (_list.uncheckedItemsCount > 1){
        self.itemsCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld items", @""), (long)_list.uncheckedItemsCount];
    }else{
        self.itemsCountLabel.text = NSLocalizedString(@"No item", @"");
    }
}

- (void)updateDoneOrEditButtonTitle
{
    if (_isItemEditing) {
        self.doneOrEditButton.title = NSLocalizedString(@"Done", @"");
        self.doneOrEditButton.tintColor = self.view.tintColor;
    }else if(_isListEditing){
        // Update the delete button's title, based on how many items are selected
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        if (selectedRows.count == 0)
        {
            self.doneOrEditButton.title = NSLocalizedString(@"Done", @"");
            self.doneOrEditButton.tintColor = self.view.tintColor;
        }
        else
        {
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Delete(%d)",@""), selectedRows.count];
            self.doneOrEditButton.title = title;
            self.doneOrEditButton.tintColor = [UIColor redColor];
        }

    }else{
        self.doneOrEditButton.title = NSLocalizedString(@"Edit", @"");
        self.doneOrEditButton.tintColor = self.view.tintColor;
    }
    
    // in not editing status, Disable the edit button if there's nothing to edit.
    if (!_isListEditing && [_list.items count] == 0) {
        self.doneOrEditButton.enabled = NO;
    }else{
        self.doneOrEditButton.enabled = YES;
    }
}

- (NSString *)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    if (selectedRows.count == 0)
    {
        return NSLocalizedString(@"Done", @"");
    }
    else
    {
        return [NSString stringWithFormat:NSLocalizedString(@"Delete(%d)",@""), selectedRows.count];
    }
}

- (void)updateCompletedBarButtonTitle
{
    if (_isItemEditing || _isListEditing) {
        self.completedBarButton.title = @"";
    }else if(_isCompletedItemsHidden) {
        self.completedBarButton.title = NSLocalizedString(@"Show completed", @"");
    }else{
        self.completedBarButton.title = NSLocalizedString(@"Hide completed", @"");
    }
}

#pragma mark - Action

- (void)insertOneRow:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[_list.items count] inSection:0];
    Item *lastItem = [_list.items lastObject];
    
    if (indexPath) {
        // tap was on existing row
        return;
    }else if([lastItem.text isEqualToString:@""]){
        return;
    }else if(_isListEditing){
        //when editing list, cannot add a new row
        return;
    }else{
        Item *item = [[Item alloc] init];
        item.text = @"";
        item.isChecked = NO;
        item.photoId = @-1;
        [_list.items addObject:item];
        
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self updateItemsCountLabel];
        ItemCell *newCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:newIndexPath];
        [newCell.textView becomeFirstResponder];
    }
}

- (IBAction)doneOrEdit:(id)sender
{
    //finish item edit
    if (_isItemEditing) {
        _isItemEditing = NO;
        [self finishEditing];
        
    //begin list edit
    }else if(!_isListEditing){
        _isListEditing = YES;
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
        
    //finish list edit and delete the selected rows
    }else{
        _isListEditing = NO;
        [self deleteMultipleRows];
        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
    }
    
    [self updateDoneOrEditButtonTitle];
    [self updateCompletedBarButtonTitle];
}

- (void)finishEditing
{
    //invoke textViewDidEndEditing:
    [self.tableView endEditing:YES];
}

- (IBAction)clickCheckButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    ItemCell *cell = (ItemCell *)button.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Item *item = _list.items[indexPath.row];
    
    if (!_isItemEditing) {
        [item toggleChecked];
        [self configureCheckButtonForCell:cell withItem:item];
        [self updateItemsCountLabel];
    }
}

- (void)deleteMultipleRows
{
    // Delete what the user selected.
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    BOOL deleteSpecificRows = selectedRows.count > 0;
    if (deleteSpecificRows)
    {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            //delete photo
            Item *item = _list.items[selectionIndex.row];
            [item removePhotoFile];
            
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        // Delete the objects from our data model.
        [_list.items removeObjectsAtIndexes:indicesOfItemsToDelete];
        
        // Tell the tableView that we deleted the objects
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateItemsCountLabel];
    }
}

- (IBAction)hideOrShowCompletedItems:(id)sender
{
    if (!_isItemEditing && !_isListEditing) {
        if (_isCompletedItemsHidden) {
            _isCompletedItemsHidden = NO;
        }else{
            _isCompletedItemsHidden = YES;
        }
        [self updateCompletedBarButtonTitle];
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDataSource

- (void)configureCheckButtonForCell:(ItemCell *)cell
                           withItem:(Item *)item
{
    if (item.isChecked) {
        [cell.checkButton setImage:[UIImage imageNamed:@"RadioButtonSelected"] forState:UIControlStateNormal];
        cell.textView.textColor = [UIColor grayColor];
    }else{
        [cell.checkButton setImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
        cell.textView.textColor = [UIColor blackColor];
    }
    
//    if (_isCompletedItemsHidden) {
//        cell.checkButton.hidden = YES;
//    }else{
//        cell.checkButton.hidden = NO;
//    }
    
    //the distance between button edge and image edge
    cell.checkButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
}

- (void)configureTextForCell:(ItemCell *)cell
                    withItem:(Item *)item
{
    cell.textView.text = item.text;
}

- (void)configureImageForCell:(ItemCell *)cell
                     withItem:(Item *)item
{
    UIImage *image = nil;
    if ([item hasPhoto]) {
        image = [item photoImage];
        if (image != nil) {
            image = [image resizedImageWithBounds:CGSizeMake(43, 43)];
        }
    }
    cell.photoImageView.image = image;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_list.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemCell *cell = (ItemCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    Item *item = _list.items[indexPath.row];
    
    [self configureCheckButtonForCell:cell withItem:item];
    [self configureTextForCell:cell withItem:item];
    [self configureImageForCell:cell withItem:item];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (_isListEditing) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        //make textview unselectable while cell selectable
        cell.textView.userInteractionEnabled = NO;
        cell.showsReorderControl =YES;  //我们添加一个重新排序控件
        //hide the check button
        cell.checkButton.hidden = YES;
        cell.checkButtonWidthConstraint.constant = 0.0;

    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textView.userInteractionEnabled = YES;
        cell.showsReorderControl = NO;
        //show the check button
        cell.checkButton.hidden = NO;
        cell.checkButtonWidthConstraint.constant = checkButtonWidth;
    }
    
    //解决换行时候行往上跳的问题
    cell.textView.scrollEnabled = NO;
    
    cell.textView.delegate = self;
    
    //Ellipsis at the end of UITextView for truncate text, 省略号
    cell.textView.textContainer.maximumNumberOfLines = 0;
    cell.textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //make the text vertical center
    cell.textView.contentInset = UIEdgeInsetsMake(3, 0, 0, 0);
    
    //hide cell
    if (_isCompletedItemsHidden && item.isChecked) {
        cell.hidden = YES;
    }else{
        cell.hidden = NO;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isListEditing) {
        return indexPath;
    }else{
        return nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        
        ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
        
        controller.delegate = self;
        
        controller.item = sender;
    }
}

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Item *item = _list.items[indexPath.row];
    [self performSegueWithIdentifier:@"EditItem" sender:item];
    NSLog(@"row: %ld", (long)indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:_editingIndexPath]) {
        if (_editingRowHeight < DefaltRowHeight) {
            return DefaltRowHeight;
        }else{
            return _editingRowHeight;
        }
    }else{
        //hide completed rows
        if (_isCompletedItemsHidden){
            Item *item = _list.items[indexPath.row];
            if (item.isChecked) {
                return 0.0f;
            }
        }
        return DefaltRowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateDoneOrEditButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateDoneOrEditButtonTitle];
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id object = [_list.items objectAtIndex:sourceIndexPath.row];
    [_list.items removeObjectAtIndex:sourceIndexPath.row];
    [_list.items insertObject:object atIndex:destinationIndexPath.row];
}

#pragma mark - Swipe to Delete and the “More” button

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSArray *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"More" , @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        // maybe show an action sheet with more options
        Item *item = _list.items[indexPath.row];
        [self performSegueWithIdentifier:@"EditItem" sender:item];
    }];
    moreAction.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete" , @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        //delete photo
        Item *item = _list.items[indexPath.row];
        [item removePhotoFile];
        
        //delete object
        [_list.items removeObjectAtIndex:indexPath.row];

        //delete row
        NSArray *indexPaths = @[indexPath];
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateDoneOrEditButtonTitle];
        [self updateItemsCountLabel];
    }];
    
    return @[deleteAction, moreAction];
}

#pragma mark - UITextViewDelegate

//click a row and begin editing
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //the first time editing
    if (!_isItemEditing) {
        _isItemEditing = YES;
        [self updateDoneOrEditButtonTitle];
        _notEditingTextViewWidth = textView.frame.size.width;
    }
    
    //the first time editing or change editing row
    ItemCell *cell = (ItemCell *)textView.superview.superview;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    //hide imageView
    cell.photoImageView.hidden = YES;
    cell.photoImageViewWidthConstraint.constant = 0.0;

    //dynamic height
    _editingIndexPath = [self.tableView indexPathForCell:cell];
    CGFloat fixedWidth = _notEditingTextViewWidth - DetailButtonWidth + imageViewWidth;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, CGFLOAT_MAX)];
    CGFloat newHeight = newSize.height;
    if (newSize.height > DefaltRowHeight) {
        [self textViewFitForContent:textView withFixedWidth:fixedWidth withNewHeight:newHeight];
        _editingRowHeight = newHeight;
        [self cellFitForTextView:textView];
    }
    
    [self performSelector:@selector(setCursorToEndOfTextView:) withObject:textView afterDelay:0.01];
    [self updateCompletedBarButtonTitle];
}

//change from one row editing to another row or finish editing
- (void)textViewDidEndEditing:(UITextView *)textView
{
    ItemCell *cell = (ItemCell *)textView.superview.superview;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //show imageView
    cell.photoImageView.hidden = NO;
    cell.photoImageViewWidthConstraint.constant = imageViewWidth;

    Item *item = _list.items[_editingIndexPath.row];
    
    if ([textView.text length] == 0) {
        //new text is empty
        if ([textView.text length] == 0) {
            //old text is also empty
            [_list.items removeObject:item];
            [self.tableView deleteRowsAtIndexPaths:@[_editingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self updateItemsCountLabel];
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }else{
            //old text is not empty
            [self.tableView reloadRowsAtIndexPaths:@[_editingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else{
        //new text is not empty
        if (![textView.text isEqualToString:item.text]) {
            //new text is not equal to old text
            item.text = textView.text;
            [self.tableView reloadRowsAtIndexPaths:@[_editingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    //dynamic height
    _isItemEditing = NO;
    _editingIndexPath = nil;
    _editingRowHeight = 0.0f;
    
    CGFloat fixedWidth = _notEditingTextViewWidth;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, CGFLOAT_MAX)];
    CGFloat newHeight = newSize.height;
    if (newSize.height > DefaltRowHeight) {
        [self textViewFitForContent:textView withFixedWidth:fixedWidth withNewHeight:newHeight];
        [self cellFitForTextView:textView];
    }
    
    //Ellipsis at the end of UITextView for truncate text
    textView.textContainer.maximumNumberOfLines = 0;
    textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self updateCompletedBarButtonTitle];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [self finishEditing];
        [self updateDoneOrEditButtonTitle];
        return NO;//don't insert return into textView.text
        
    }else if (text != nil){
        [textView.text stringByReplacingCharactersInRange:range withString:text];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //dynamic height
    CGFloat fixedWidth = _notEditingTextViewWidth - DetailButtonWidth + imageViewWidth;
    CGFloat oldHeight = textView.frame.size.height;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, CGFLOAT_MAX)];
    CGFloat newHeight = newSize.height;
    if (newHeight > DefaltRowHeight){
        //when text rows > 1
        [self textViewFitForContent:textView withFixedWidth:fixedWidth withNewHeight:newHeight];
        _editingRowHeight = newHeight;
        [self cellFitForTextView:textView];
    }else if (newHeight < DefaltRowHeight && oldHeight - DefaltRowHeight > 1.0f){
        //when text rows from 2 to 1, and not the first row
        //[self textViewFitForContent:textView withFixedWidth:fixedWidth withNewHeight:newHeight];
        _editingRowHeight = DefaltRowHeight;
        [self cellFitForTextView:textView];
    }
}

//when content change, we should adjust the height for the textView to fit it
- (void)textViewFitForContent:(UITextView *)textView
               withFixedWidth:(CGFloat)fixedWidth
                withNewHeight:(CGFloat)newHeight
{
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fixedWidth, newHeight);
    textView.frame = newFrame;
}

- (void)cellFitForTextView:(UITextView *)textView
{
    ItemCell *cell = (ItemCell *)textView.superview.superview;
    CGRect cellFrame = cell.frame;
    cellFrame.size.height = textView.frame.size.height;
    cell.frame = cellFrame;
    
    //fix the scoll down and up problem!
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)setCursorToEndOfTextView:(UITextView *)textView
{
    //you can change first parameter in NSMakeRange to wherever you want the cursor to move
    textView.selectedRange = NSMakeRange([textView.text length], 0);
}

#pragma mark - keep keyboard not hidden editing text
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, DefaltRowHeight, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - ItemDetailViewControllerDelegate method

- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishEditingItem:(Item *)item
{
    NSInteger index = [_list.items indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    ItemCell *cell = (ItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [self configureImageForCell:cell withItem:item];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemDetailViewControllerDidCancel:(ItemDetailViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
