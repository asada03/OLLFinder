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
    BOOL originalFrameSet;
}
@property (nonatomic) CGRect originalFrame;
@end

@implementation ImageButton

-(void)setType:(NSString *)type
    {
        _type = type;
        
        self.hidden = NO;
        [self setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", type]] forState:UIControlStateNormal];
        
    }
    
-(CGRect)originalFrame
{
    if (!originalFrameSet)
    {
        _originalFrame = self.frame;
        originalFrameSet = YES;
    }
    return _originalFrame;
}

-(void) imageSelected
{
    CGFloat offset = self.originalFrame.size.width * .1;
    self.alpha = 1;
    
    self.frame = CGRectMake( self.originalFrame.origin.x - (offset / 2), self.originalFrame.origin.y - (offset / 2), self.originalFrame.size.width + offset, self.originalFrame.size.height + offset);

}

-(void) imageNotSelected
{
    CGFloat offset = self.originalFrame.size.width * .1;
    self.alpha = .75;
    
    self.frame = CGRectMake( self.originalFrame.origin.x + (offset / 2), self.originalFrame.origin.y + (offset / 2), self.originalFrame.size.width - offset, self.originalFrame.size.height - offset);
 
    self.enabled = YES;
}

-(void) imageNormal
{
    self.alpha = 1;
    self.frame = self.originalFrame;
    
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
    [self imageNotSelected];
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
