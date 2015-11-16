//
//  RWTMasterViewController.m
//  ScaryBugs
//
//  Created by Jorge Jordán Arenas on 04/02/14.
//
//

#import "RWTMasterViewController.h"
#import "RWTDetailViewController.h"
#import "RWTScaryBugDoc.h"
#import "RWTAppDelegate.h"

#import "test.h"

@interface RWTMasterViewController () {
  NSMutableArray *_objects;
}

@property (strong)UISearchDisplayController* searchDisplayController;

@property (strong) NSArray *searchResults;
@end

@implementation RWTMasterViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItem = addButton;
  
  self.title = @"Notebook";
  
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                            target:self action:@selector(addTapped:)];
  
  [self createSearchBar];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  for(int i = 0; i < sizeof(dummy_data) / sizeof(dummy_data[0]); ++i) {
    NSLog(@"%@", @(dummy_data[i]));
  }
}

- (void)createSearchBar {
  if (self.tableView && !self.tableView.tableHeaderView) {
    UISearchBar *searchBar = [[UISearchBar alloc] init] ;
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                     contentsController:self];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.delegate = self;
    searchBar.frame = CGRectMake(0, 0, 0, 38);
    self.tableView.tableHeaderView = searchBar;
  }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
  NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
  self.searchResults = [self.bugs filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
  [self filterContentForSearchText:searchString
                             scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                    objectAtIndex:[self.searchDisplayController.searchBar
                                                   selectedScopeButtonIndex]]];
  
  return YES;
}

- (void)insertNewObject:(id)sender
{
  if (!_objects) {
    _objects = [[NSMutableArray alloc] init];
  }
  [_objects insertObject:[NSDate date] atIndex:0];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
  // fetch the object at the row being moved
  RWTScaryBugDoc *r = [self.bugs objectAtIndex:fromIndexPath.row];
  
  // remove the original from the data structure
  [self.bugs removeObjectAtIndex:fromIndexPath.row];
  
  // insert the object at the target row
  [self.bugs insertObject:r atIndex:toIndexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 71;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return [self.searchResults count];
    
  } else {
    return [self.bugs count];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"MyBasicCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  RWTScaryBugDoc *bug = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    bug = [self.searchResults objectAtIndex:indexPath.row];
  } else {
    bug = [self.bugs objectAtIndex:indexPath.row];
  }
  
  cell.textLabel.text = bug.title;
  cell.imageView.image = bug.thumbImage;
  cell.detailTextLabel.text = bug.location;
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Return NO if you do not want the specified item to be editable.
  return tableView == self.tableView;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (tableView == self.tableView) {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      [_bugs removeObjectAtIndex:indexPath.row];
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
  }
}


-(void)didMoveToParentViewController:(UIViewController *)parent{
  [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  RWTDetailViewController *detailController = segue.destinationViewController;
  [detailController setItemIndex: self.tableView.indexPathForSelectedRow.row];
}

- (void)addTapped:(id)sender {
  RWTScaryBugDoc *newDoc = [[RWTScaryBugDoc alloc] initWithTitle:@"New Note" rating:0 imagePath:nil audioPath:nil location: nil];
  [_bugs addObject:newDoc];
  
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_bugs.count-1 inSection:0];
  NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:YES];
  
  [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
  [self performSegueWithIdentifier:@"MySegue" sender:self];
}

@end
