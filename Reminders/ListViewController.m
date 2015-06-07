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


@interface ListViewController ()


@end

@implementation ListViewController
{
    List *_list;
    NSIndexPath *_editingIndexPath;
    BOOL _isEditing;
    CGFloat _editingRowHeight;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
    item1.text = @"text1";
    item1.isChecked = NO;
    Item *item2 = [[Item alloc] init];
    item2.text = @"//if put these lines in viewDidLoad, then self.tableview.frame.size will not work//if put these lines in viewDidLoad, then self.tableview.frame.size will not work";
    item2.isChecked = YES;
    
    [_list.items addObject:item1];
    [_list.items addObject:item2];
    
    [self updateNameLabel];
    [self updateItemsCountLabel];
    [self updateDoneOrEditButtonTitle];
    
    //tap anywhere below the existing rows will insert a new row
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(insertOneRow:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
}

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
    }else{
        Item *item = [[Item alloc] init];
        item.text = @"";
        item.isChecked = NO;
        [_list.items addObject:item];
        
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        ItemCell *newCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:newIndexPath];
        [newCell.textView becomeFirstResponder];
    }
}

- (void)updateNameLabel
{
    self.nameLabel.text = _list.name;
}

- (void)updateItemsCountLabel
{
    [_list countUncheckedItems];
    
    if (_list.uncheckedItemsCount > 0) {
        self.itemsCountLabel.text = [NSString stringWithFormat:@"%ld items", (long)_list.uncheckedItemsCount];
    }else{
        self.itemsCountLabel.text = @"No items";
    }
}

- (void)updateDoneOrEditButtonTitle
{
    if (_isEditing) {
        [self.doneOrEditButton setTitle:@"Done" forState:UIControlStateNormal];
    }else{
        [self.doneOrEditButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

- (IBAction)clickCheckButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    ItemCell *cell = (ItemCell *)button.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Item *item = _list.items[indexPath.row];
    
    if (!_isEditing) {
        [item toggleChecked];
        [self configureCheckButtonForCell:cell withItem:item];
        [self updateItemsCountLabel];
    }
}

- (IBAction)doneOrEdit:(id)sender
{
    //finish edit
    if (_isEditing) {
        [self finishEditing];
    
    //begin edit
    }else{
        _isEditing = YES;
    }
    
    [self updateDoneOrEditButtonTitle];
}

- (void)finishEditing
{
    //invoke textViewDidEndEditing:
    [self.tableView endEditing:YES];
}

//open ItemDetailViewController programmatically
- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemNavigationController"];
//    ItemDetailViewController *controller = (ItemDetailViewController *)navigationController.topViewController;
//    
//    controller.delegate = self;
//    Checklist *checklist = self.dataModel.lists[indexPath.row];
//    controller.checklistToEdit = checklist;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (void)configureCheckButtonForCell:(ItemCell *)cell
                           withItem:(Item *)item
{

    if (item.isChecked) {
        [cell.checkButton setImage:[UIImage imageNamed:@"RadioButtonSelected"] forState:UIControlStateNormal];
    }else{
        [cell.checkButton setImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
    }
    
    cell.checkButton.imageEdgeInsets = UIEdgeInsetsMake((cell.checkButton.frame.size.height - 44.0) / 2.0 + 8.0, 8, (cell.checkButton.frame.size.height - 44.0) / 2.0 + 8.0, 8);
    
    NSLog(@"%f", cell.checkButton.frame.size.height );
    //the distance between button edge and image edge

    //cell.checkButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);

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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textView.scrollEnabled = NO;
    
    cell.textView.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UITextViewDelegate

//click a row and begin editing
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //the first time editing
    if (!_isEditing) {
        _isEditing = YES;
        [self updateDoneOrEditButtonTitle];
    }
    
    //the first time editing or change editing row
    ItemCell *cell = (ItemCell *)textView.superview.superview;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    _editingIndexPath = [self.tableView indexPathForCell:cell];
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
    
    _isEditing = NO;
    _editingIndexPath = nil;
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

//- (void)textViewDidChange:(UITextView *)textView
//{
//    //CGFloat oldHeight = textView.frame.size.height;
//    CGFloat fixedWidth = textView.frame.size.width;
//    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, CGFLOAT_MAX)];
//    CGRect newFrame = textView.frame;
//    newFrame.size = CGSizeMake(fixedWidth, newSize.height);
//    textView.frame = newFrame;
//    
//    //    ItemCell *cell = (ItemCell *)textView.superview.superview;
//    //    CGRect cellFrame = cell.frame;
//    //    cellFrame.size.height = textView.frame.size.height;
//    //    cell.frame = cellFrame;
//    //
//    //    _editingRowHeight = cellFrame.size.height;
//    //    [self.tableView beginUpdates];
//    //    [self.tableView endUpdates];
//}

//- (CGFloat)tableView:(UITableView *)tableView
//heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //    if (indexPath.row == _editingIndexPath.row) {
//    //        NSLog(@"test1");
//    //        NSLog(@"height %f", _editingRowHeight);
//    //        NSLog(@"row %ld", _editingIndexPath.row);
//    //        return _editingRowHeight;
//    //
//    //    }else{
//    //        NSLog(@"test2");
//    //        //return UITableViewAutomaticDimension;
//    //        return 44.0f;
//    //    }
//    NSLog(@"test2");
//    NSLog(@"row %ld",indexPath.row);
//    //return UITableViewAutomaticDimension;
//    return 44.0f;
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
