//
//  touch12ifViewController.m
//  touch12if
//
//  Created by Elvis Pfützenreuter on 8/29/11.
//  Copyright 2011 Elvis Pfützenreuter. All rights reserved.
//

// FIXME teste primeira orientação em devs reais, teste ipad
// FIXME screenshot, pub

#import "touch12ifViewController.h"

@interface touch12ifViewController ()

@end

@implementation touch12ifViewController

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
        [prefs registerDefaults:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInt: 1], @"click", nil]];
        [prefs registerDefaults:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInt: 0], @"comma", nil]];
        [prefs registerDefaults:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInt: -1], @"separator", nil]];
        click = [prefs integerForKey: @"click"];
        long old_comma = [prefs integerForKey: @"comma"];
        separator = [prefs integerForKey: @"separator"];
        if (separator < 0) {
            // upgrade or first run
            separator = old_comma ? 1 : 0;
            [prefs setInteger: separator forKey: @"separator"];
        }
    }
    return self;
}

- (void) playClick
{
    AudioServicesPlaySystemSound(audio_id);
}

- (void) playClickOff
{
    AudioServicesPlaySystemSound(audio2_id);
}
 
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView { 
    [super loadView];
    
    {
    NSURL *aurl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"] isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(aurl), &audio_id);
    }
    
    {
    NSURL *aurl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"clickoff" ofType:@"wav"] isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(aurl), &audio2_id);
    }
}

- (BOOL) getSB: (BOOL) is_vertical {
	BOOL hide_bar = is_vertical;
	if (iphone5) {
		// iPhone5 proportions ask the opposite logic
		hide_bar = !hide_bar;
	}
    return hide_bar;
};

- (void) defaultsChanged:(NSNotification *)notification {
    // Get the user defaults
    NSLog(@"Defaults changed");
    NSUserDefaults *prefs = (NSUserDefaults *)[notification object];
    click = [prefs integerForKey: @"click"];
    separator = [prefs integerForKey: @"separator"];
    [self performSelectorOnMainThread: @selector(setSeparator) withObject: nil waitUntilDone: NO];
}

- (void) setSeparator {
    NSString *sep_cmd = [NSString stringWithFormat: @"ios_separator(%ld);", (long) separator];
    [html stringByEvaluatingJavaScriptFromString: sep_cmd];
}

- (void) loadPage
{
    [[UIApplication sharedApplication] setStatusBarHidden: [self getSB: NO]];
    NSString *name = @"index";
    if (iphone5) {
        name = @"index5";
    }
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"html"] isDirectory:NO];
    [html loadRequest:[NSURLRequest requestWithURL:url]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
    html = [[UIWebView alloc] initWithFrame:webFrame];
	html.autoresizesSubviews = YES;
    html.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    html.scalesPageToFit = YES;
    html.delegate = self;
    [self.view addSubview:html];
    html.alpha = 0.0;
    */
    
    html.scrollView.scrollEnabled = NO;
    html.scrollView.bounces = NO;
    
    [html setBackgroundColor: [UIColor colorWithRed:41.0/255.0 green:39.0/255.0 blue:40.0/255.0 alpha:1.0]];
    self.view.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:39.0/255.0 blue:40.0/255.0 alpha:1.0];
    // [html setAlpha: 0.01];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(orientationChanged:)
                                                 name: @"UIDeviceOrientationDidChangeNotification" object: nil];
    
    splash_fadedout = NO;

    pheight = [UIScreen mainScreen].bounds.size.height;
    pwidth = [UIScreen mainScreen].bounds.size.width;
    if (pwidth > pheight) {
        // make sure we get the portrait-wise height
        pheight = [UIScreen mainScreen].bounds.size.width;
        pwidth = [UIScreen mainScreen].bounds.size.height;
    }

    NSLog(@"Screen size: %f", pheight);
    iphone5 = pheight >= 568;

    [self performSelector:@selector(adlayout)
               withObject: self
               afterDelay: 0];
 
    [self loadPage];
}

- (void) adlayout
{
    self.adView.adUnitID = @"ca-app-pub-3940256099942544/6300978111";

    self.adView.rootViewController = self;
    self.adView.delegate = self;
    self.adView.adSize = kGADAdSizeLargeBanner;

    GADRequest* request =[GADRequest request];
    request.testDevices = @[ kGADSimulatorID, @"cf014d9155ec42042d965fcc6e1578f2" ];
    [self.adView loadRequest: request];
    
    // 'pheight' is the width in landscape mode
    float wavailable = 0.435 * pheight;
    NSLog(@"Width: %f for ad: %f", pheight, wavailable);
    float scaleFactor = wavailable / 320.0;
    self.adView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    CGRect frame = self.adView.frame;
    frame.origin.x = pheight - 320 * scaleFactor;
    frame.origin.y = 0;
    // frame.size.width = 320;
    // frame.size.height = 100;
    self.adView.frame = frame;
    
    [self.adView setNeedsLayout];
    [self.adView layoutIfNeeded];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"adViewDidReceivAd");
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"didFailToReceiveAdWithError %@", [error description]);
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    NSLog(@"adViewWillPresentScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    NSLog(@"adViewDidDismissScreen");
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    NSLog(@"adViewWillLeaveApplication");
}

- (void) orientationChanged: (NSNotification *) object
{
    // UIDeviceOrientation o = [UIDevice currentDevice].orientation;
}

- (void) fade_in {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.0];
    [html setAlpha:1.00];
    [UIView commitAnimations];
    NSLog(@"    alpha animated (fade_in)");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setSeparator];
    if (splash_fadedout)
        return;
    splash_fadedout = YES;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.0];
    [html setAlpha:1.00];
    [UIView commitAnimations];
    NSLog(@"    alpha animated (load)");
    if (click)
        [self playClick];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(defaultsChanged:)  
                   name:NSUserDefaultsDidChangeNotification
                 object:nil];
}

- (BOOL) webView:(UIWebView *)view 
shouldStartLoadWithRequest:(NSURLRequest *)request 
  navigationType:(UIWebViewNavigationType)navigationType {
    
	NSString *requestString = [[request URL] absoluteString];
	NSArray *components = [requestString componentsSeparatedByString:@":"];
    
	if ([(NSString *)[components objectAtIndex:0] isEqualToString:@"touch12if"] &&
                    [components count] > 1) {
		if ([(NSString *)[components objectAtIndex:1] isEqualToString:@"click"]) {
            if (click)
                [self playClick];
		} else if ([(NSString *)[components objectAtIndex:1] isEqualToString:@"tclick"]) {
            click = (click ? 0 : 1);
            NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger: click forKey: @"click"];
            if (click)
                [self playClick];
            else 
                [self playClickOff];
		} else if ([(NSString *)[components objectAtIndex:1] isEqualToString:@"comma0"]) {
            separator = 0;
            NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger: separator forKey: @"separator"];
            if (click)
                [self playClick];
		} else if ([(NSString *)[components objectAtIndex:1] isEqualToString:@"comma1"]) {
            separator = 1;
            NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger: separator forKey: @"separator"];
            if (click)
                [self playClick];
        } else if ([(NSString *)[components objectAtIndex:1] isEqualToString:@"comma2"]) {
            separator = 2;
            NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
            [prefs setInteger: separator forKey: @"separator"];
            if (click)
                [self playClick];
        }
 		return NO;
 	}

	return YES;
}


// Override to allow orientations other than the default portrait orientation.
// IOS5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
        return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
                (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

@end
