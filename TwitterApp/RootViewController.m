//
//  RootViewController.m
//  TwitterApp
//
//  Created by Steve  Emmerich on 6/29/13.
//  Copyright (c) 2013 Steve  Emmerich. All rights reserved.
//

#import "RootViewController.h"
#import "SearchViewController.h"

@implementation RootViewController

- (BOOL)shoudAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma === Text field delegate methods ===
#pragma mark - 

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text)
    {
        NSLog(textField.text);
        //printf((const char*)textField.text);
        [self performSegueWithIdentifier:@"SegueSearchView" sender:textField];
        
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark === Segue ===
#pragma mark - 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueSearchView"])
    {
        UITextField *textField = sender;
        SearchViewController *viewController = segue.destinationViewController;
        viewController.query = [NSString stringWithFormat:@"%@", textField.text];
        NSLog(viewController.query);
    }
}

@end
