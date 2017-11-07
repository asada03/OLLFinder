//
//  CaseViewController.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 02/06/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "CaseViewController.h"
#import "CaseTableViewCell.h"
#import "VideoViewController.h"

@interface CaseViewController ()
{
    NSArray *currentAlgorithms;
    NSInteger selectedAlg;
    Video *video;
    CGFloat pvOriginalWidth, pvOriginalHeight;
    BOOL viewLoaded;
    BOOL playerLarge;
}
@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;
@property (weak, nonatomic) IBOutlet UILabel *algLabel;
@property (weak, nonatomic) IBOutlet UITableView *algTable;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayButton;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorTopConstraint;

@end

@implementation CaseViewController

- (void)setOllCase:(OLLCase *)ollCase
{
    _ollCase = ollCase;
    
    NSLog(@"oll case:%@", ollCase.uid);
    
    if (viewLoaded)
        [self initImage];
    [self.algTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    BOOL flag;
//    NSError *setCategoryError = nil;
//    flag = [audioSession setCategory:AVAudioSessionCategoryPlayback
//                               error:&setCategoryError];
    self.playerView.delegate = self;
    
    //self.algTable.backgroundColor = [UIColor clearColor];
    pvOriginalWidth = self.playerViewWidth.constant;
    pvOriginalHeight = self.playerViewHeight.constant;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];

    [self initImage];
    viewLoaded = YES;
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
    self.authorLabel.text = alg.video ? alg.video.author : @"";
    
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, .5 * M_PI * [alg.rotations integerValue]);
    
    [UIView animateWithDuration:(animated ? 0.7 : 0.0) animations:^(){
        self.caseImageView.transform = transform;
    }];
    
    [self.playerView stopVideo];
    
    self.videoPlayButton.hidden = YES;
    [self setPlayerSize:2];
    
    video = alg.video;
    NSLog(@"Adding video:%@", video);
    if (video)
    {
        NSDictionary *playersVars = @{@"playsinline" : @1,
                                      @"autoplay" : @0,
                                      @"showinfo" : @0,
                                      };
        
        NSLog(@"Will load vide:%@",video);
        [self.playerView loadWithVideoId:video.vidId playerVars:playersVars];
    }
    else
    {
        [self setPlayerSize:0];
        self.videoPlayButton.hidden = YES;
    }
}

- (void)initImage
{
    self.algTable.hidden = ([self.ollCase.algorithms count] == 1);

    if (self.ollCase)
        [self initImageWithAlg:self.ollCase.main animated:NO];
}

- (void) playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime
{
    if (playTime < [video.start floatValue] ||
        playTime > [video.start floatValue] + [video.duration floatValue])
    {
        NSLog(@"looping at:%f vs:%f", playTime - [video.start floatValue], [video.duration floatValue]);
        [self.playerView seekToSeconds:[video.start floatValue] allowSeekAhead:YES];
    }
}

- (void) playerViewDidBecomeReady:(YTPlayerView *)playerView{
    self.videoPlayButton.hidden = NO;
    self.playerView.hidden = YES;
    //[self.playerView seekToSeconds:[video.start floatValue] allowSeekAhead:YES];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStatePlaying:
            [self setPlayerSize:1];
            [self.playerView seekToSeconds:[video.start floatValue] allowSeekAhead:YES];
            break;
        case kYTPlayerStatePaused:
            break;
        default:
            break;
    }
}

- (void) setPlayerSize:(int)type
{
    [self.view layoutIfNeeded];
    
    switch (type) {
        case 0:
            self.playerViewHeight.constant = 0;
            self.playerView.hidden = YES;
            break;
            
        case 1:
            self.playerViewWidth.constant = self.view.frame.size.width;
            self.playerViewHeight.constant = self.playerViewWidth.constant * 9 / 16;
            self.authorTopConstraint.constant = -(_authorLabel.frame.size.height);
            self.playerView.hidden = NO;
            playerLarge = YES;
            break;
            
        case 2:
            self.playerViewWidth.constant = pvOriginalWidth;
            self.playerViewHeight.constant = pvOriginalHeight;
            self.authorTopConstraint.constant = 0;
            self.playerView.hidden = NO;
            playerLarge = NO;
            break;
            
        default:
            break;
    }

    self.authorLabel.hidden = YES;
    [UIView animateWithDuration:.7
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         self.authorLabel.hidden = NO;
                     }];

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
    if (cell.isMain) selectedAlg = indexPath.row;
    cell.hasVideo = (ollAlg.video != nil);
    cell.authorLabel.text = ollAlg.video ? ollAlg.video.author : @"";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedAlg == indexPath.row)
    {
        self.ollCase.main = currentAlgorithms[indexPath.row];
        if (playerLarge) [self initImage];
        [self.algTable reloadData];
        [self.delegate mainAlgChanged];

    }
    else
    {
        [self initImageWithAlg:currentAlgorithms[indexPath.row] animated:YES];
    }
    selectedAlg = indexPath.row;
    [self.playerView stopVideo];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"toVideoView"])
//    {
//    }
//
//}

#pragma mark - Actions

- (IBAction)playButtonPressed:(UIButton *)sender {
    [self.playerView playVideo];
    self.videoPlayButton.hidden = YES;
    self.playerView.hidden = NO;
}
@end
