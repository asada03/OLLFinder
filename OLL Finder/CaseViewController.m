//
//  CaseViewController.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 02/06/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "CaseViewController.h"
#import "CaseTableViewCell.h"
#import "PlayButton.h"
#import "VideoViewController.h"

@interface CaseViewController ()
{
    NSArray *currentAlgorithms;
    NSInteger selectedAlg;
}
@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;
@property (weak, nonatomic) IBOutlet UILabel *algLabel;
@property (weak, nonatomic) IBOutlet UITableView *algTable;
@property (weak, nonatomic) IBOutlet PlayButton *playButton;

@end

@implementation CaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.ollCase.algorithms count] == 1)
        self.algTable.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];

    [self initImage];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initImageWithAlg:(Algorithm *)alg animated:(BOOL)animated
{
    self.caseImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", self.ollCase.uid]];
    self.algLabel.text = alg.algorithm;
    self.algLabel.adjustsFontSizeToFitWidth = YES;
    
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, .5 * M_PI * [alg.rotations integerValue]);
    
    [UIView animateWithDuration:(animated ? 0.7 : 0.0) animations:^(){
        self.caseImageView.transform = transform;
    }];
    
    self.playButton.hidden = ([alg.videos count] == 0);
    self.playButton.algorithm = alg;
}

- (void)initImage
{
    [self initImageWithAlg:self.ollCase.main animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    currentAlgorithms = [self.ollCase.algorithms allObjects];
    return [currentAlgorithms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CaseCell"];
    Algorithm *ollAlg = currentAlgorithms[indexPath.row];
    
    cell.caseImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", self.ollCase.uid]];
    cell.caseImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.algorithmLabel.text = ollAlg.algorithm;
    cell.algorithmLabel.adjustsFontSizeToFitWidth = YES;
    cell.rotations = [ollAlg.rotations integerValue];
    cell.isMain = [ollAlg isEqual:self.ollCase.main];
    cell.hasVideo = [ollAlg.videos count] > 0;
    cell.playButton.algorithm = ollAlg;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedAlg == indexPath.row)
    {
        self.ollCase.main = currentAlgorithms[indexPath.row];
        [self initImage];
        [self.algTable reloadData];
    }
    else
    {
        [self initImageWithAlg:currentAlgorithms[indexPath.row] animated:YES];
    }
    selectedAlg = indexPath.row;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toVideoView"])
    {
        VideoViewController *videoView = segue.destinationViewController;
        PlayButton *button = sender;
        
        videoView.algorithm = button.algorithm;
    }

}

@end
