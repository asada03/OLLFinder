//
//  CaseViewController.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 02/06/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "CaseViewController.h"

@interface CaseViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;
@property (weak, nonatomic) IBOutlet UILabel *algLabel;

@end

@implementation CaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.caseImageView.image = [UIImage imageNamed:self.ollCase.file_name];
    self.algLabel.text = self.ollCase.algorithm;
    self.algLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
