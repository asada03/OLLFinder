//
//  CaseViewController.h
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 02/06/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLLCase+CoreDataProperties.h"
#import "Algorithm+CoreDataProperties.h"
#import "Video+CoreDataProperties.h"
#import "YTPlayerView.h"

@interface CaseViewController : UIViewController <YTPlayerViewDelegate>
@property (weak, nonatomic) OLLCase *ollCase;

@end
