//
//  TweetViewController.h
//  TwitterApp
//
//  Created by Steve  Emmerich on 6/29/13.
//  Copyright (c) 2013 Steve  Emmerich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewController : UIViewController

//@property (nonatomic, copy) NSString *query;
@property (nonatomic, copy) NSString *tweet;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@end
