//
//  VideoViewController.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 21/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "VideoViewController.h"
#import "YTPlayerView.h"


@interface VideoViewController ()
{
    Video *video;
}
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.playerView.delegate = self;
    
    NSDictionary *playersVars = @{@"playsinline" : @0,
                                  @"autoplay" : @1,
                                  @"showinfo" : @0,
                                  };
    
    [self.playerView loadWithVideoId:self.algorithm.video.vidId playerVars:playersVars];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) playerViewDidBecomeReady:(YTPlayerView *)playerView{
    [self.playerView seekToSeconds:[video.start floatValue] allowSeekAhead:YES];
    [self.playerView playVideo];

}

- (void) playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime
{
    if (playTime > [video.start floatValue] + [video.duration floatValue])
    {
        [self.playerView seekToSeconds:[video.start floatValue] allowSeekAhead:YES];
    }
}
- (IBAction)speedAction:(UIButton *)sender {
    [self.playerView setPlaybackRate:.25];
    [self.playerView seekToSeconds:[video.start floatValue] allowSeekAhead:YES];
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
