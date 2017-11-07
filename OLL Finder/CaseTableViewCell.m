//
//  CaseTableViewCell.m
//  OLL Finder
//
//  Created by Vortex on 01/03/15.
//  Copyright (c) 2015 Andres Sada Govela. All rights reserved.
//

#import "CaseTableViewCell.h"

@interface CaseTableViewCell()
{
    CGFloat defaultStarWidth;
    CGFloat defaultVideoWidth;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerWidthConstraint;

@end

@implementation CaseTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRotations:(NSInteger)rotations
{
    _rotations = rotations;
    
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, .5 * M_PI * rotations);
    self.caseImage.transform = transform;

}

- (void)setIsMain:(BOOL)isMain
{
    _isMain = isMain;
    
    defaultStarWidth = MAX (defaultStarWidth, self.starWidthConstraint.constant);
    self.starWidthConstraint.constant = isMain ? defaultStarWidth : 0;
}

- (void)setHasVideo:(BOOL)hasVideo
{
    _hasVideo = hasVideo;
    
    defaultVideoWidth = MAX (defaultVideoWidth, self.playerWidthConstraint.constant);
    self.playerWidthConstraint.constant = hasVideo ? defaultVideoWidth : 0;
}
@end
