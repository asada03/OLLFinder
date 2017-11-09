//
//  ImageButton.m
//  OLL Finder
//
//  Created by Vortex on 04/06/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "ImageButton.h"
@interface ImageButton ()
{
    CGFloat originalHeight;
    CGFloat originalWidth;
}
@end

@implementation ImageButton
    
-(void)setType:(NSString *)type
{
    _type = type;
    
    self.hidden = NO;
    [self setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", type]] forState:UIControlStateNormal];
    
}
    
-(NSLayoutConstraint *)heightConstraint
{
    if (!_heightConstraint)
    {
        for (NSLayoutConstraint *constraint in self.constraints) {
            if ([constraint.identifier isEqualToString:@"height"]) {
                _heightConstraint = constraint;
                originalHeight = _heightConstraint.constant;
                //_heightConstraint.constant = 5;
                break;
            }
        }
    }
    
    return _heightConstraint;
}
    
-(NSLayoutConstraint *)widthConstraint
{
    if (!_widthConstraint)
    {
        for (NSLayoutConstraint *constraint in self.constraints) {
            if ([constraint.identifier isEqualToString:@"width"]) {
                _widthConstraint = constraint;
                originalWidth = _widthConstraint.constant;
                break;
            }
        }
    }
    return _widthConstraint;
}
    
-(void) imageSelected
{
    CGFloat offset = originalWidth * .1;
    self.alpha = 1;
    
    self.heightConstraint.constant = originalHeight + offset;
    self.widthConstraint.constant = originalWidth + offset;
}

-(void) imageNotSelected
{
    CGFloat offset = originalWidth * .1;
    self.alpha = .65;
    
    self.heightConstraint.constant = originalHeight - offset;
    self.widthConstraint.constant = originalWidth - offset;
 
    self.enabled = YES;
}

-(void) imageNormal
{
    self.alpha = 1;
    self.heightConstraint.constant = originalHeight;
    self.widthConstraint.constant = originalWidth;
    
    self.enabled = YES;
    self.hidden = NO;
}

-(void) imageDisabled
{
    [self imageNotSelected];
    self.enabled = NO;
}
    
-(void) imageHidden
{
    [self imageNormal];
    self.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
