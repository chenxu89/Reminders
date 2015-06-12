//
//  DetailViewController.m
//  Reminders
//
//  Created by 陈旭 on 6/5/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "ItemDetailViewController.h"

@interface ItemDetailViewController ()<UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView1;

- (IBAction)done:(id)sender;

@end

@implementation ItemDetailViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44.0;
    // Automatic dimensions to tell the table view to use dynamic height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Disable scrolling inside the text view so we enlarge to fitted size
    self.textView1.scrollEnabled = NO;
    self.textView1.delegate = self;
    
    self.textView1.text = @"Next create a custom UITableViewCell xib file and setup constraints to layout the UITextView. I have basically just wrapped the UITextView in constraints with zero constant to the container view as seen below. Next  create a custom UITableViewCell xib file and setup constraints to layout the UITextView. I have basically just wrapped the UITextView in constraints with zero constant to the container view as seen ew. I have basically just wrapped the UITextView in constraints with zero constant to the container view as seen ew.asically just wrapped the UITextView in constraints with zero constant to the container view as seen ew. I have basically just wrapped the UITextView in constraints with zero constant to the container view as seen ew.";
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.textView1 becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - Action

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize size = textView.bounds.size;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
    if (size.height != newSize.height) {
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        
        UITableViewCell *cell = (UITableViewCell *)[[self.textView1 superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}


//#pragma mark - keep keyboard not hidden editing text
//- (void)keyboardWillShow:(NSNotification*)aNotification
//{
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    self.textView1.contentInset = contentInsets;
//    self.textView1.scrollIndicatorInsets = contentInsets;
//}
//
//- (void)keyboardWillHide:(NSNotification*)aNotification
//{
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
//    self.tableView.contentInset = contentInsets;
//    self.tableView.scrollIndicatorInsets = contentInsets;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
