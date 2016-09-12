//
//  touch12ifAppDelegate.h
//  touch12if
//
//  Created by Elvis Pfützenreuter on 8/29/11.
//  Copyright 2011 Elvis Pfützenreuter. All rights reserved.
//

#import <UIKit/UIKit.h>

@class touch12ifViewController;

@interface touch12ifAppDelegate : NSObject <UIApplicationDelegate>;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) touch12ifViewController *viewController;

@end

