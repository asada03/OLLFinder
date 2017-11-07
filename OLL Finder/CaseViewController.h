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

@protocol CaseVCDelegate <NSObject>

// Called when the peripheral receives a new subscriber.
- (void) mainAlgChanged;

@end

@interface CaseViewController : UIViewController <YTPlayerViewDelegate>
@property (weak, nonatomic) OLLCase *ollCase;

@property(nonatomic, assign) id<CaseVCDelegate> delegate;

@end
