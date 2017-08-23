//
//  CaseTableViewCell.h
//  OLL Finder
//
//  Created by Vortex on 01/03/15.
//  Copyright (c) 2015 Andres Sada Govela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayButton.h"

@interface CaseTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *caseImage;
@property (strong, nonatomic) IBOutlet UILabel *algorithmLabel;
@property (weak, nonatomic) IBOutlet UILabel *algNumLabel;
@property (weak, nonatomic) IBOutlet PlayButton *playButton;

@property (nonatomic) NSInteger rotations;
@property (nonatomic) BOOL isMain;
@property (nonatomic) BOOL hasVideo;

@end
