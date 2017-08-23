//
//  VideoViewController.h
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 21/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Algorithm+CoreDataProperties.h"
#import "Video+CoreDataProperties.h"
#import "YTPlayerView.h"

@interface VideoViewController : UIViewController <YTPlayerViewDelegate>

@property (nonatomic, weak) Algorithm *algorithm;
@end
