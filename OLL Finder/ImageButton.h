//
//  ImageButton.h
//  OLL Finder
//
//  Created by Vortex on 04/06/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageButton : UIButton

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSString *type;

-(void) imageSelected;
-(void) imageNotSelected;
-(void) imageNormal;
-(void) imageDisabled;
-(void) imageHidden;

@end
