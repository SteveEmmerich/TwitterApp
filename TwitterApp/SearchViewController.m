//
//  SearchViewController.m
//  TwitterApp
//
//  Created by Steve  Emmerich on 6/29/13.
//  Copyright (c) 2013 Steve  Emmerich. All rights reserved.
//

#import "SearchViewController.h"
#import "TweetViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

typedef NS_ENUM(NSUInteger, UYLTwitterSearchState)
{
    UYLTwitterSearchStateLoading,
    UYLTwitterSearchStateNotFound,
    UYLTwitterSearchStateRefused,
    UYLTwitterSearchStateFailed
};


@interface SearchViewController ()

@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *buffer;
@property (nonatomic,strong) NSMutableArray *results;
@property (nonatomic,strong) ACAccountStore *accountStore;
@property (nonatomic,assign) UYLTwitterSearchState searchState;

@end

@implementation SearchViewController

- (ACAccountStore *)accountStore
{
    if (_accountStore == nil)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (NSString *)searchMessageForState:(UYLTwitterSearchState)state
{
    switch (state)
    {
            case UYLTwitterSearchStateLoading:
                return @"Loading...";
                break;
            case UYLTwitterSearchStateNotFound:
                return @"No results found";
                break;
            case UYLTwitterSearchStateRefused:
                return @"Twitter Access Refused";
                break;
            default:
                return @"Not Available";
                break;
    }
}

- (IBAction)refreshSearchResults
{
    [self cancelConnection];
    [self loadQuery];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refreshSearchResults) forControlEvents:UIControlEventValueChanged];
    self.title = self.query;
  //  NSLog(self.title);
    [self loadQuery];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelConnection];
}
- (void)dealloc
{
    [self cancelConnection];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
#pragma mark - 
#pragma === UITableViewDataSource Delegates ==
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [self.results count];
    return count > 0 ? count : 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ResultsCellIdentifier = @"ResultCell";
    static NSString *LoadCellIdentifier = @"LoadingCell";
    
    NSUInteger count = [self.results count];
    if ((count == 0) && (indexPath.row == 0))
    {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadCellIdentifier];
        cell.textLabel.text = [self searchMessageForState:self.searchState];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ResultsCellIdentifier];
    NSDictionary *tweet = (self.results)[indexPath.row];
    cell.textLabel.text = tweet[@"text"];
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"TweetPush"])
    {
        UITextView *textView = sender;
      //  NSLog(textView.text);
        TweetViewController *viewController = segue.destinationViewController;
        NSString* temp = [NSString stringWithFormat:@"%@", textView.text];
        //NSLog(temp);
        viewController.tweet = temp;
       // NSLog(viewController.tweet);
    }
    //NSLog(segue.identifier);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row & 1)
    {
        cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
}
#pragma mark - 
#pragma mark === Private methods ===
#pragma mark - 

#define RESULTS_PERPAGE @"100"

-(void)loadQuery
{
    self.searchState = UYLTwitterSearchStateLoading;
    NSLog(self.query);
    NSString *encodedQuery = [self.query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:accountType options:NULL completion:^(BOOL granted, NSError *error)
    {
        if (granted)
        {
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
            NSDictionary *parameters = @{@"count" : RESULTS_PERPAGE, @"q" : encodedQuery};
            
            SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:parameters];
            
            NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
            slRequest.account = [accounts lastObject];
            NSURLRequest *request = [slRequest preparedURLRequest];
            dispatch_async(dispatch_get_main_queue(), ^{ self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            });
            
        }
        else
        {
            self.searchState = UYLTwitterSearchStateRefused;
            dispatch_async(dispatch_get_main_queue(), ^{[self.tableView reloadData]; });
        }
    }];
   
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.buffer = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)conection didReceiveData:(NSData *)data
{
    [self.buffer appendData:data];

}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    
    NSError *jsonParsingError = nil;
    NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:self.buffer options:0 error:&jsonParsingError];
    
    self.results = jsonResults[@"statuses"];
    if ([self.results count] == 0)
    {
        NSArray *errors = jsonResults[@"errors"];
        if ([errors count])
        {
            self.searchState = UYLTwitterSearchStateFailed;
        }
        else
        {
            self.searchState = UYLTwitterSearchStateNotFound;
        }
    }
    self.buffer = nil;
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    self.buffer = nil;
    [self.refreshControl endRefreshing];
    self.searchState = UYLTwitterSearchStateFailed;
    
    [self handleError:error];
    [self.tableView reloadData];
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)cancelConnection
{
    if (self.connection != nil)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.connection cancel];
        self.connection = nil;
        self.buffer = nil;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

//#pragma mark - Table view delegate

//-// (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
    // Navigation logic may go here. Create and push another view controller.
    /*
  //   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] //initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
//}

@end
