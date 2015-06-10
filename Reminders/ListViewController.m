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

static CGFloat const DefaltRowHeight = 44.0f;
static CGFloat const DetailButtonWidth = 40.0f;

@interface ListViewController ()


@end

@implementation ListViewController
{
    List *_list;
    BOOL _isItemEditing;
    NSIndexPath *_editingIndexPath;
    CGFloat _editingRowHeight;
    CGFloat _notEditingTextViewWidth;
    BOOL _isListEditing;
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
    item1.isChecked = YES;
    [_list.items addObject:item1];
    
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
}

#pragma mark - update

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
        [self.doneOrEditButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    }else if(_isListEditing){
        [self.doneOrEditButton setTitle:[self updateDeleteButtonTitle] forState:UIControlStateNormal];
    }else{
        [self.doneOrEditButton setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
    }
    
    // in not editing status, Disable the edit button if there's nothing to edit.
    if (!_isListEditing && [_list.items count] == 0) {
        self.doneOrEditButton.enabled = NO;
    }else{
        self.doneOrEditButton.enabled = YES;
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
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        // Delete the objects from our data model.
        [_list.items removeObjectsAtIndexes:indicesOfItemsToDelete];
        
        // Tell the tableView that we deleted the objects
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateItemsCountLabel];
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
    
    //the distance between button edge and image edge
    cell.checkButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
}

- (void)configureTextForCell:(ItemCell *)cell
                    withItem:(Item *)item
{
    cell.textView.text = item.text;
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
    [self configureCheckButtonForCell:cell withItem:_list.items[indexPath.row]];
    [self configureTextForCell:cell withItem:_list.items[indexPath.row]];

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //解决换行时候行往上跳的问题
    cell.textView.scrollEnabled = NO;
    
    if (_isListEditing) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        //make textview unselectable while cell selectable
        cell.textView.userInteractionEnabled = NO;
        cell.checkButton.hidden = YES;
        cell.showsReorderControl =YES;  //我们添加一个重新排序控件
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textView.userInteractionEnabled = YES;
        cell.checkButton.hidden = NO;
        cell.showsReorderControl = NO;
    }
    
    cell.textView.delegate = self;
    
    //Ellipsis at the end of UITextView for truncate text
    cell.textView.textContainer.maximumNumberOfLines = 0;
    cell.textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    
    
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

-(void)openItemDetailViewControllerWithIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemNavigationController"];
    //    ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
    //
    //    controller.delegate = self;
    //    Checklist *checklist = self.dataModel.lists[indexPath.row];
    //    controller.checklistToEdit = checklist;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}


- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self openItemDetailViewControllerWithIndexPath:indexPath];
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
        [self openItemDetailViewControllerWithIndexPath:indexPath];
    }];
    moreAction.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete" , @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //delete a row
        [_list.items removeObjectAtIndex:indexPath.row];
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
    
    //dynamic height
    _editingIndexPath = [self.tableView indexPathForCell:cell];
    CGFloat fixedWidth = _notEditingTextViewWidth - DetailButtonWidth;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, CGFLOAT_MAX)];
    CGFloat newHeight = newSize.height;
    if (newSize.height > DefaltRowHeight) {
        [self textViewFitForContent:textView withFixedWidth:fixedWidth withNewHeight:newHeight];
        _editingRowHeight = newHeight;
        [self cellFitForTextView:textView];
    }
    
    [self performSelector:@selector(setCursorToEndOfTextView:) withObject:textView afterDelay:0.01];
    

}

//change from one row editing to another row or finish editing
- (void)textViewDidEndEditing:(UITextView *)textView
{
    ItemCell *cell = (ItemCell *)textView.superview.superview;
    cell.accessoryType = UITableViewCellAccessoryNone;
    Item *item = _list.items[_editingIndexPath.row];
    
    if ([cell.textView.text isEqualToString:@""]) {
        //new text is empty
        if ([item.text isEqualToString:@""]) {
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
        if (![cell.textView.text isEqualToString:item.text]) {
            //new text is not equal to old text
            item.text = cell.textView.text;
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
    CGFloat fixedWidth = _notEditingTextViewWidth - DetailButtonWidth;
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
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + DefaltRowHeight, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, DefaltRowHeight, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
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
