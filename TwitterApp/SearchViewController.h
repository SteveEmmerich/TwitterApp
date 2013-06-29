//
//  SearchViewController.h
//  TwitterApp
//
//  Created by Steve  Emmerich on 6/29/13.
//  Copyright (c) 2013 Steve  Emmerich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController<UITextViewDelegate>
@property (nonatomic, copy) NSString *query;
@end
