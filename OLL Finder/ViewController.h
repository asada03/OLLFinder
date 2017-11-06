//
//  ViewController.h
//  OLL Finder
//
//  Created by Vortex on 28/02/15.
//  Copyright (c) 2015 Andres Sada Govela. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;


@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, GADInterstitialDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@end

