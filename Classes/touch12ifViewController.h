//
//  touch12ifViewController.h
//  touch12if
//
//  Created by Elvis Pfützenreuter on 8/29/11.
//  Copyright 2011 Elvis Pfützenreuter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface touch12ifViewController : UIViewController <UIWebViewDelegate, GADBannerViewDelegate> {
    SystemSoundID audio_id, audio2_id;
    NSInteger click;
    NSInteger separator;
    IBOutlet UIWebView *html;
    BOOL splash_fadedout;
    BOOL iphone5;
    double pheight;
    double pwidth;
}

- (void) playClick;
- (BOOL) webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request 
  navigationType:(UIWebViewNavigationType)navigationType;

@property (weak, nonatomic) IBOutlet GADBannerView *adView;

@end

