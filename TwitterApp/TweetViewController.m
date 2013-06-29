//
//  TweetViewController.m
//  TwitterApp
//
//  Created by Steve  Emmerich on 6/29/13.
//  Copyright (c) 2013 Steve  Emmerich. All rights reserved.
//

#import "TweetViewController.h"

@interface TweetViewController ()

@end

@implementation TweetViewController
@synthesize tweet;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self displayTweet];
	// Do any additional setup after loading the view.
}

- (void)displayTweet
{
    
    //UITextView *view = self.view.subviews[0];
    //NSLog(view.attributedText);
    textView.text = self.tweet;
    //self.textView.text = self.tweet;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
